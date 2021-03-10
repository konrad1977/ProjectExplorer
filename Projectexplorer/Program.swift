//
//  Program.swift
//  Projectexplorer
//
//  Created by Mikael Konradsson on 2021-03-07.
//

import Foundation

fileprivate extension Predicate where A == String {
	static var supportedFiletypes = Predicate {
		$0.hasSuffix(".swift") ||
		$0.hasSuffix(".m") ||
		$0.hasSuffix(".h") ||
		$0.hasSuffix(".kt") ||
		$0.hasSuffix(".ktm") ||
		$0.hasSuffix(".kts")
	}
}

struct Program {

    private func lineSeparator(color: TerminalForegroundColor = .blue) -> IO<Void> {
        printRepeatingCharacter("—", count: 28, color: color)
    }

	private func startProgramWithMessage(_ message: String) -> IO<Void> {
		IO { message.textColor(.yellow) }
	}

	private func executablePath() -> IO<String> {
        #if DEBUG
            print(FileManager.default.currentDirectoryPath)
        #endif
		return IO { FileManager.default.currentDirectoryPath }
	}

	private func subdirectoriesFromPath(_ path: String) -> IO<[String]> {
		guard let paths = try? FileManager.default
				.subpathsOfDirectory(atPath: path)
				.filter(Predicate.supportedFiletypes.contains)
		else { return IO { [] } }

		return IO { paths }
	}

	private func sourceFile(for path: String) -> IO<String.SubSequence> {
		guard let file = try? String(contentsOfFile: path, encoding: .ascii)[...]
		else { return IO { "" } }

		return IO { file }
	}

	private func analyzeSourceFile(path: String, filename: String, filetype: Filetype) -> IO<Fileinfo> {
		sourceFile(for: path)
			.flatMap { source in
				zip(
					IO<String>.pure(filename),
					SourceFileAnalysis.countClasses(filetype: filetype)(source),
					SourceFileAnalysis.countStructs(filetype: filetype)(source),
					SourceFileAnalysis.countEnums(filetype: filetype)(source),
					SourceFileAnalysis.countInterfaces(filetype: filetype)(source),
					SourceFileAnalysis.countFunctions(filetype: filetype)(source),
                    SourceFileAnalysis.countLinesIn(sourceFile: source),
					IO<Filetype>.pure(filetype)
				)
				.map(Fileinfo.init)
			}
	}

	private func createFileInfo(_ path: String) -> IO<Fileinfo> {
		let fileUrl = URL(fileURLWithPath: path)
		let filetype = Filetype(extension: fileUrl.pathExtension)
		let filename = fileUrl.deletingPathExtension().lastPathComponent
		return analyzeSourceFile(path: path, filename: filename, filetype: filetype)
	}

	private func analyzeSubpaths(_ paths: [String]) -> IO<[Fileinfo]> {
		IO { paths.map(createFileInfo).map { $0.unsafeRun() } }
	}

	private func summary(_ fileInfo: [Fileinfo]) -> IO<Void> {
		zip(
			outputLanguageSummary(for: .swift)(fileInfo),
			outputLanguageSummary(for: .kotlin)(fileInfo),
			outputLanguageSummary(for: .objectiveC)(fileInfo),
            outputTotalSummary(fileInfo),
            lineSeparator()
		).map { _ in }
	}

    private func printRepeatingCharacter(_ char: Character, count: Int, color: TerminalForegroundColor = .blue) -> IO<Void> {
		IO { print(String(repeating: char, count: count).textColor(color)) }
	}

	private func printSummaryFor(_ filetype: Filetype, fileInfo: [Fileinfo]) -> IO<Void> {

		guard fileInfo.count > 0
		else { return IO { } }

		let (classes, structs, enums, interfaces, functions, lines) = fileInfo.reduce(
			into: (0, 0, 0, 0, 0, 0)) { acc, fileInfo in
			acc.0 += fileInfo.classes
			acc.1 += fileInfo.structs
			acc.2 += fileInfo.enums
			acc.3 += fileInfo.interfaces
			acc.4 += fileInfo.functions
			acc.5 += fileInfo.linecount
		}

        return lineSeparator().flatMap {
            IO {

				let repeatingLength = 28 - filetype.description.count
				let title = filetype.description + String(repeating: " ", count: repeatingLength)
				print(title.backgroundColor(.white) )
				print("files :" + "\(fileInfo.count)".textColor(.blue))
				print("lines :" + "\(lines)".textColor(.red))
				print("classes :" + "\(classes)".textColor(.green))
				print("\(filetype.structs):" + " \( structs)".textColor(.green))
				print("\(filetype.enums) :" + "\(enums)".textColor(.cyan))
				print("functions :" + "\(functions)".textColor(.white))
				print("\(filetype.interfaces) : " + "\(interfaces)".textColor(.yellow))
            }
        }
	}

	private func createFilteredFileInfo(_ info: [Fileinfo]) -> (Filetype) -> IO<(Filetype, [Fileinfo])> {
		return { filetype in IO { (filetype, info.filter { $0.filetype == filetype }) } }
	}

    private func outputTotalSummary(_ fileInfo: [Fileinfo]) -> IO<Void> {
        zip(
			printSummaryFor(.all, fileInfo: fileInfo),
            printPercentSummary(fileInfo)
        ).map { _ in }
    }

	private func printPercentSummary(_ fileInfo: [Fileinfo]) -> IO<Void> {

        guard fileInfo.isEmpty == false
        else { return IO<Void> {} }

		let filterFilesFor = createFilteredFileInfo(fileInfo)
		let (_, swift) = filterFilesFor(.swift).unsafeRun()
		let (_ ,kotlin) = filterFilesFor(.kotlin).unsafeRun()
		let (_, objc) = filterFilesFor(.objectiveC).unsafeRun()

        let totalFiles = swift.count + kotlin.count + objc.count

        guard totalFiles > 0
        else { return IO<Void> {} }

        return lineSeparator().flatMap {
            IO {
				let rounding = roundToDecimals(1)
                let swiftPercent = rounding(Double(swift.count) / Double(totalFiles) * 100).unsafeRun()
                let kotlinPercent = rounding(Double(kotlin.count) / Double(totalFiles) * 100).unsafeRun()
                let objcPercent =  rounding(Double(objc.count) / Double(totalFiles) * 100).unsafeRun()

                if swiftPercent > 0 {
					print("Swift :" + "\(swiftPercent)".textColor(.red) + "%")
                }
                if kotlinPercent > 0 {
					print("Kotlin :" + "\(kotlinPercent)".textColor(.red) + "%")
                }
                if objcPercent > 0 {
					print("Objective-C :" + "\(objcPercent)".textColor(.red) + "%")
                }
            }
        }
	}

    private func outputLanguageSummary(for filetype: Filetype ) -> ([Fileinfo]) -> IO<Void> {
		return { fileInfo in
			createFilteredFileInfo(fileInfo)(filetype)
				.flatMap(printSummaryFor)
		}
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
		IO { print("Total time: " + "\(time)".textColor(.red) + " seconds") }
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
				.flatMap(executablePath)
				.flatMap(subdirectoriesFromPath)
				.flatMap(analyzeSubpaths)
				.flatMap(summary)
		}
		.flatMap(roundToDecimals(2))
		.flatMap(outputTimemeasure)
	}
}
