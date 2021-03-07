//
//  Program.swift
//  Projectexplorer
//
//  Created by Mikael Konradsson on 2021-03-07.
//

import Foundation

enum TerminalColor: String {
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

private func printWithColor(_ color: TerminalColor, _ text: String) {
	print(color.rawValue + text + TerminalColor.reset.rawValue)
}

extension Predicate where A == String {
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
		return IO { path }
	}
	
	private func subdirectoriesFromPath(_ path: String) -> IO<[String]> {
		guard let paths = try? FileManager.default
				.subpathsOfDirectory(atPath: path)
				.filter(Predicate.supportedFiletypes.contains)
		
		else { return IO { [] } }
		return IO { paths }
	}
	
	private func analyzeSubpaths(_ paths: [String]) -> IO<[Fileinfo]> {
		IO { paths
			.map(analyzePath)
			.map { $0.unsafeRun() }
			.sorted(by: { $0.filename < $1.filename })
		}
	}
	
	private func startProgramWithMessage(_ message: String) -> IO<Void> {
		IO { printWithColor(.yellow, message) }
	}
	
	private func analyzePath(_ path: String) -> IO<Fileinfo> {
		let (linecount, comments) = fileFromPath(path)
			.flatmap {
				zip(
					linecountForSourceFile($0),
					commentInSourceFile($0)
				)
			}.unsafeRun()
		
		let url = URL(fileURLWithPath: path)
		let filetype = Filetype(extension: url.pathExtension)
		let filename = url.deletingPathExtension().lastPathComponent
		
		return IO {
			Fileinfo(
				filename: filename,
				linecount: linecount,
				comments: comments,
				filetype: filetype
			)
		}
	}
	
	private func fileFromPath(_ path: String) -> IO<String.SubSequence> {
		guard let file = try? String(contentsOfFile: path, encoding: .ascii)[...]
		else { return IO { "" } }
		
		return IO { file }
	}
	
	private func linecountForSourceFile(_ sourceFile: String.SubSequence) -> IO<Int> {
		IO { sourceFile.components(separatedBy: .newlines).count }
	}
	
	private func commentInSourceFile(_ sourceFile: String.SubSequence) -> IO<Int> {
		let comments = sourceFile
			.components(separatedBy: "//").count
			+
			sourceFile.components(separatedBy: "/*").count
		return IO { comments }
	}
	
	private func summary(_ fileInfos: [Fileinfo]) -> IO<Void> {
		zip(
			//outputFilelist(fileInfos),
			repeatString("⎻", count: 75),
			outputProjectSummary(fileInfos),
			repeatString("⎼", count: 75)
		).map { _ in }
	}
	
	private func repeatString(_ char: Character, count: Int) -> IO<Void> {
		IO { printWithColor(.yellow, String(repeating: char, count: count)) }
	}
	
	private func outputFilelist(_ infos: [Fileinfo]) -> IO<Void> {
		IO {
			infos.forEach {
				let lineCount = "\(TerminalColor.red.rawValue + "\($0.linecount)" + TerminalColor.reset.rawValue)"
				print("\($0.filename):\(lineCount)")
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
			
			let lineCount = "\(filetype.description) files: \(TerminalColor.red.rawValue + "\(totalFiles)" + TerminalColor.reset.rawValue)"
			let separator = "\(TerminalColor.yellow.rawValue + " • " + TerminalColor.reset.rawValue)"
			let codeLines = "lines: \(TerminalColor.red.rawValue + "\(totalLines)" + TerminalColor.reset.rawValue)"
			let comments = "comments: \(TerminalColor.red.rawValue + "\(totalComments)" + TerminalColor.reset.rawValue)"
			print("[\(lineCount)\(separator)\(codeLines)\(separator)\(comments)]")
		}
	}
	
	private func fileInfoFor(filetype: Filetype, info: [Fileinfo]) -> IO<(Filetype, [Fileinfo])> {
		IO { (filetype, info.filter { $0.filetype == filetype }) }
	}
	
	private func outputProjectSummary(_ fileInfo: [Fileinfo]) -> IO<Void> {
		
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
	
	func start() -> IO<Void> {
		startProgramWithMessage("Analyzing current path. Stand by...")
			.flatmap(executablePath)
			.flatmap(subdirectoriesFromPath)
			.flatmap(analyzeSubpaths)
			.flatmap(summary)
	}
}
