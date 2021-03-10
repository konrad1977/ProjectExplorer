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
		$0.hasSuffix(".h") ||
		$0.hasSuffix(".kt") ||
		$0.hasSuffix(".ktm") ||
		$0.hasSuffix(".kts")
	}
}

struct Program {

    private func lineSeparator(color: TerminalColor = .blue) -> IO<Void> {
        repeatString("—", count: 24, color: color)
    }

	private func startProgramWithMessage(_ message: String) -> IO<Void> {
		IO { print(textWithColor(.yellow, message)) }
	}

	private func executablePath() -> IO<String> {
        #if DEBUG
            print(FileManager.default.currentDirectoryPath)
        #endif
        return IO<String>.pure(FileManager.default.currentDirectoryPath)
	}

	private func subdirectoriesFromPath(_ path: String) -> IO<[String]> {
		guard let paths = try? FileManager.default
				.subpathsOfDirectory(atPath: path)
				.filter(Predicate.supportedFiletypes.contains)

		else { return IO { [] } }
		return IO { paths }
	}

	private func analyzeSourceFile(path: String, filename: String, filetype: Filetype) -> IO<Fileinfo> {
		sourceFile(for: path)
			.flatmap { source in
				zip(
					SourceFileAnalysis.countClasses(filetype: filetype)(source),
					SourceFileAnalysis.countStructs(filetype: filetype)(source),
					SourceFileAnalysis.countEnums(filetype: filetype)(source),
					SourceFileAnalysis.countInterfaces(filetype: filetype)(source),
					SourceFileAnalysis.countFunctions(filetype: filetype)(source),
                    SourceFileAnalysis.countLinesIn(sourceFile: source)
				).map { classes, structs, enums, interfaces, functions, lines in
					Fileinfo(
						filename: filename,
						classes: classes,
						structs: structs,
						enums: enums,
						interfaces: interfaces,
						functions: functions,
						linecount: lines,
						filetype: filetype
					)
				}
			}
	}

	private func createFileInfo(_ path: String) -> IO<Fileinfo> {
		let fileUrl = URL(fileURLWithPath: path)
		let filetypes = Filetype(extension: fileUrl.pathExtension)
		let filename = fileUrl.deletingPathExtension().lastPathComponent
		return analyzeSourceFile(path: path, filename: filename, filetype: filetypes)
	}

	private func analyzeSubpaths(_ paths: [String]) -> IO<[Fileinfo]> {
		IO { paths
			.map(createFileInfo)
			.map { $0.unsafeRun() }
			.sorted(by: { $0.filename < $1.filename })
		}
	}

	private func sourceFile(for path: String) -> IO<String.SubSequence> {
		guard let file = try? String(contentsOfFile: path, encoding: .ascii)[...]
		else { return IO { "" } }

		return IO { file }
	}

	private func summary(_ fileInfo: [Fileinfo]) -> IO<Void> {
		zip(
            outputLanguageSummary(for: .swift, fileInfo),
            outputLanguageSummary(for: .kotlin, fileInfo),
            outputLanguageSummary(for: .objectiveC, fileInfo),
            outputTotalSummary(fileInfo),
            lineSeparator()
		).map { _ in }
	}

    private func repeatString(_ char: Character, count: Int, color: TerminalColor = .blue) -> IO<Void> {
		IO { print(textWithColor(color, String(repeating: char, count: count))) }
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

		let (classes, structs, enums, interfaces, functions, lines) = fileInfo.reduce(
			into: (0, 0, 0, 0, 0, 0)) { acc, fileInfo in
			acc.0 += fileInfo.classes
			acc.1 += fileInfo.structs
			acc.2 += fileInfo.enums
			acc.3 += fileInfo.interfaces
			acc.4 += fileInfo.functions
			acc.5 += fileInfo.linecount
		}

        return lineSeparator().flatmap {
            IO {
                print(textWithColor(.red, filetype.description))
                print("files : \(textWithColor(.yellow, fileInfo.count))")
                print("lines : \(textWithColor(.red, lines))")
                print("classes : \(textWithColor(.blue, classes))")
                print("\(filetype.structs): \(textWithColor(.green, structs))")
                print("\(filetype.enums) : \(textWithColor(.cyan, enums))")
                print("functions : \(textWithColor(.white, functions))")
                print("\(filetype.interfaces) : \(textWithColor(.yellow, interfaces))")
            }
        }
	}

	private func fileInfoFor(filetype: Filetype, info: [Fileinfo]) -> IO<(Filetype, [Fileinfo])> {
		IO { (filetype, info.filter { $0.filetype == filetype }) }
	}

    private func outputTotalSummary(_ fileInfo: [Fileinfo]) -> IO<Void> {
        zip(
            summaryOutputForFiletype(.all, fileInfo: fileInfo),
            outputPercentage(fileInfo)
        ).map { _ in }
    }

	private func outputPercentage(_ fileInfo: [Fileinfo]) -> IO<Void> {

        guard fileInfo.isEmpty == false
        else { return IO<Void> {} }

		let (_, swift) = fileInfoFor(filetype: .swift, info: fileInfo).unsafeRun()
		let (_ ,kotlin) = fileInfoFor(filetype: .kotlin, info: fileInfo).unsafeRun()
		let (_, objc) = fileInfoFor(filetype: .objectiveC, info: fileInfo).unsafeRun()

        let totalFiles = swift.count + kotlin.count + objc.count

        guard totalFiles > 0
        else { return IO<Void> {} }

        return lineSeparator().flatmap {
            IO {
                let swiftPercent = roundToDecimals(1)(Double(swift.count) / Double(totalFiles) * 100).unsafeRun()
                let kotlinPercent = roundToDecimals(1)(Double(kotlin.count) / Double(totalFiles) * 100).unsafeRun()
                let objcPercent =  roundToDecimals(1)(Double(objc.count) / Double(totalFiles) * 100).unsafeRun()

                if swiftPercent > 0 {
                    print("Swift : \(textWithColor(.yellow, swiftPercent.rounded())) %")
                }
                if kotlinPercent > 0 {
                    print("Kotlin : \(textWithColor(.yellow, kotlinPercent)) %")
                }
                if objcPercent > 0 {
                    print("Objective-C : \(textWithColor(.yellow, objcPercent)) %")
                }
            }
        }
	}

    private func outputLanguageSummary(for filetype: Filetype, _ fileInfo: [Fileinfo]) -> IO<Void> {
        fileInfoFor(filetype: filetype, info: fileInfo)
        .flatmap(summaryOutputForFiletype)
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
		IO { print("Total time: \(textWithColor(.red, time)) seconds") }
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
		.flatmap(outputTimemeasure)
	}
}
