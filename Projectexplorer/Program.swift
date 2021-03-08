//
//  Program.swift
//  Projectexplorer
//
//  Created by Mikael Konradsson on 2021-03-07.
//

import Foundation

fileprivate enum TerminalColor: String {
	case reset = "\u{001B}[0;0m"
	case black = "\u{001B}[0;30m"
	case red = "\u{001B}[0;31m"
	case green = "\u{001B}[0;32m"
	case yellow = "\u{001B}[0;33m"
	case blue = "\u{001B}[0;34m"
	case magenta = "\u{001B}[0;35m"
	case cyan = "\u{001B}[0;36m"
	case white = "\u{001B}[0;37m"
}

private func textWithColor(_ color: TerminalColor, _ text: String) -> String {
	color.rawValue + text + TerminalColor.reset.rawValue
}

private func textWithColor(_ color: TerminalColor, _ any: Any) -> String {
	color.rawValue + "\(any)" + TerminalColor.reset.rawValue
}

fileprivate extension Predicate where A == String {
	static var supportedFiletypes = Predicate {
		$0.hasSuffix(".swift") ||
			$0.hasSuffix(".m") ||
			$0.hasSuffix(".cpp") ||
			$0.hasSuffix(".mm") ||
			$0.hasSuffix(".c") ||
			$0.hasSuffix(".kt") ||
			$0.hasSuffix(".ktm") ||
			$0.hasSuffix(".kts")
	}
}

struct Program {

	private func executablePath() -> IO<String> {
		guard let path = Bundle.main.resourcePath
		else { return IO { "" } }
		print(path)
		return IO { path }
	}

	private func subdirectoriesFromPath(_ path: String) -> IO<[String]> {
		guard let paths = try? FileManager.default
				.subpathsOfDirectory(atPath: path)
				.filter(Predicate.supportedFiletypes.contains)

		else { return IO { [] } }
		return IO { paths }
	}

	private func createFileInfo(_ path: String) -> IO<Fileinfo> {

		let (linecount, comments) = fileInfoCounting(path)
			.unsafeRun()

		return IO {
			URL(fileURLWithPath: path)
		}.map { url in
			Fileinfo(
				filename: url.deletingPathExtension().lastPathComponent,
				linecount: linecount,
				comments: comments,
				filetype: Filetype(extension: url.pathExtension)
			)
		}
	}

	private func analyzeSubpaths(_ paths: [String]) -> IO<[Fileinfo]> {
		IO { paths
			.map(createFileInfo)
			.map { $0.unsafeRun() }
			.sorted(by: { $0.filename < $1.filename })
		}
	}

	private func startProgramWithMessage(_ message: String) -> IO<Void> {
		IO { print(textWithColor(.yellow, message)) }
	}

	private func fileInfoCounting(_ path: String) -> IO<(Int, Int)> {
		sourceFile(for: path)
		.flatmap { source in
			zip(
				countLinesIn(sourceFile:source),
				countCommentIn(sourceFile:source)
			)
		}
	}

	private func sourceFile(for path: String) -> IO<String.SubSequence> {
		guard let file = try? String(contentsOfFile: path, encoding: .ascii)[...]
		else { return IO { "" } }

		return IO { file }
	}

	private func countLinesIn(sourceFile: String.SubSequence) -> IO<Int> {
		IO { sourceFile.components(separatedBy: .newlines).count }
	}

	private func countCommentIn(sourceFile: String.SubSequence) -> IO<Int> {
		let comments = sourceFile
			.components(separatedBy: "//").count
			+
			sourceFile.components(separatedBy: "/*").count
		return IO { comments }
	}

	private func summary(_ fileInfos: [Fileinfo]) -> IO<Void> {
		zip(
			repeatString("⎻", count: 75),
			outputLanguageSpecificSummary(fileInfos),
			repeatString("⎼", count: 75),
            outputTotalSummary(fileInfos),
            repeatString("⎼", count: 75)
		).map { _ in }
	}

	private func repeatString(_ char: Character, count: Int) -> IO<Void> {
		IO { print(textWithColor(.yellow, String(repeating: char, count: count))) }
	}

	private func outputFilelist(_ infos: [Fileinfo]) -> IO<Void> {
		IO {
			infos.forEach {
				print("\($0.filename): + \(textWithColor(.red, $0.linecount))")
			}
		}
	}

	private func summaryOutputForFiletype(_ filetype: Filetype, fileInfo: [Fileinfo]) -> IO<Void> {

		guard fileInfo.count > 0
		else { return IO { } }

		let totalFiles = fileInfo.count
		let (totalLines, totalComments) = fileInfo.reduce(into: (0, 0)) { acc, fileInfo in
			acc.0 += fileInfo.linecount
			acc.1 += fileInfo.comments
		}

		return IO {
			let lineCount = "\(filetype.description) files: \(textWithColor(.red, totalFiles))"
			let separator = textWithColor(.yellow, " • ")
			let codeLines = "lines: \(textWithColor(.red, totalLines))"
			let comments = "comments: \(textWithColor(.red, totalComments))"
			print("[\(lineCount + separator + codeLines + separator + comments)]")
		}
	}

	private func fileInfoFor(filetype: Filetype, info: [Fileinfo]) -> IO<(Filetype, [Fileinfo])> {
		IO { (filetype, info.filter { $0.filetype == filetype }) }
	}

    private func outputTotalSummary(_ fileInfo: [Fileinfo]) -> IO<Void> {
        summaryOutputForFiletype(.all, fileInfo: fileInfo)
    }

	private func outputLanguageSpecificSummary(_ fileInfo: [Fileinfo]) -> IO<Void> {

		let cFiles =
			fileInfoFor(filetype: .c, info: fileInfo)
			.flatmap(summaryOutputForFiletype)

		let cppFiles =
			fileInfoFor(filetype: .cpp, info: fileInfo)
			.flatmap(summaryOutputForFiletype)

		let swiftFiles =
			fileInfoFor(filetype: .swift, info: fileInfo)
			.flatmap(summaryOutputForFiletype)

		let objcFiles =
			fileInfoFor(filetype: .objectiveC, info: fileInfo)
			.flatmap(summaryOutputForFiletype)

		let kotlinFiles =
			fileInfoFor(filetype: .kotlin, info: fileInfo)
			.flatmap(summaryOutputForFiletype)

		return zip(
			cFiles,
			swiftFiles,
			objcFiles,
			cppFiles,
			kotlinFiles
		).map { _ in }
	}

	private func calculateTime(block: @escaping () -> IO<Void>) -> IO<Double> {
		IO {
			let start = DispatchTime.now()
			block().unsafeRun()
			let end = DispatchTime.now()
			let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds
			return Double(nanoTime) / 1_000_000_000
		}
	}

	private func outputTimemeasure(time: Double) -> IO<Void> {
		IO {
			print("Total time: \(textWithColor(.green, time)) seconds")
		}
	}

	private func roundToDecimals(_ places: Double) -> (Double) -> IO<Double> {
		return { value in
			IO<Double> {
				let divisor = pow(10.0, Double(places))
				return (value * divisor).rounded() / divisor
			}
		}
	}
}

// MARK: - Public
extension Program {
	func start() -> IO<Void> {
		calculateTime {
			startProgramWithMessage("Analyzing current path. Stand by...")
				.flatmap(executablePath)
				.flatmap(subdirectoriesFromPath)
				.flatmap(analyzeSubpaths)
				.flatmap(summary)
		}
		.flatmap(roundToDecimals(2))
		.flatmap(outputTimemeasure(time:))
	}
}
