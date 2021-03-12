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

struct CodeAnalyser {

    private func lineSeparator(color: TerminalColor = .accentColor) -> IO<Void> {
        printRepeatingCharacter("—", count: 35, color: color)
    }

	private func startProgramWithMessage(_ message: String) -> IO<Void> {
		IO { message.textColor(.accentColor) }
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
			createSummaryForLanguage(.swift, fileInfo: fileInfo).flatMap(printSummaryFor),
			createSummaryForLanguage(.kotlin, fileInfo: fileInfo).flatMap(printSummaryFor),
			createSummaryForLanguage(.objectiveC, fileInfo: fileInfo).flatMap(printSummaryFor),
            outputTotalSummary(fileInfo),
            lineSeparator()
		).map { _ in }
	}

    private func printRepeatingCharacter(_ char: Character, count: Int, color: TerminalColor = .accentColor) -> IO<Void> {
		IO { print(String(repeating: char, count: count).textColor(color)) }
	}

	private func createSummaryForLanguage(_ filetype: Filetype, fileInfo: [Fileinfo]) -> IO<LanguageSummary> {

		guard fileInfo.count > 0
		else { return IO { .empty } }

		let (classes, structs, enums, interfaces, functions, lines) = fileInfo.reduce(
			into: (0, 0, 0, 0, 0, 0)) { acc, fileInfo in
			acc.0 += fileInfo.classes
			acc.1 += fileInfo.structs
			acc.2 += fileInfo.enums
			acc.3 += fileInfo.interfaces
			acc.4 += fileInfo.functions
			acc.5 += fileInfo.linecount
		}
		return IO {
			LanguageSummary(
				classes: classes,
				structs: structs,
				enums: enums,
				interfaces: interfaces,
				functions: functions,
				linecount: lines,
				filecount: fileInfo.count,
				filetype: filetype
			)
		}
	}

	private func printSummaryFor(_ language: LanguageSummary) -> IO<Void> {

		guard language.filetype != .none
		else { return IO { } }

		return IO {
				let width = 35
				Console.output(language.filetype.description, color: .white, lineWidth: width)
				Console.output("classes:", data: language.classes, color: .classColor, width: width)
				Console.output("\(language.filetype.structs.trimEnd):", data: language.structs, color: .structColor, width: width)
				Console.output("\(language.filetype.enums.trimEnd):", data: language.enums, color: .enumColor, width: width)
				Console.output("functions:", data: language.functions, color: .functionColor, width: width)
				Console.output("\(language.filetype.interfaces.trimEnd):", data: language.interfaces, color: .interfaceColor, width: width)
				Console.output("files:", data: language.filecount, color: .fileColor, width: width)
				Console.output("lines:", data: language.linecount, color: .lineColor, width: width)

			if language.filetype != .all {
				print("\r")
			}
        }
	}

	private func createFilteredFileInfo(_ info: [Fileinfo]) -> (Filetype) -> IO<(Filetype, [Fileinfo])> {
		return { filetype in IO { (filetype, info.filter { $0.filetype == filetype }) } }
	}

    private func outputTotalSummary(_ fileInfo: [Fileinfo]) -> IO<Void> {
        zip(
			createSummaryForLanguage(.all, fileInfo: fileInfo).flatMap(printSummaryFor),
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
				let rounding = Rounding.decimals(1)
                let swiftPercent = rounding(Double(swift.count) / Double(totalFiles) * 100).unsafeRun()
                let kotlinPercent = rounding(Double(kotlin.count) / Double(totalFiles) * 100).unsafeRun()
                let objcPercent =  rounding(Double(objc.count) / Double(totalFiles) * 100).unsafeRun()

                if swiftPercent > 0 {
					print("Swift: ".textColor(.languageColor) + "\(swiftPercent) %".textColor(.accentColor))
                }
                if kotlinPercent > 0 {
					print("Kotlin: ".textColor(.languageColor) + "\(kotlinPercent) %".textColor(.accentColor))
                }
                if objcPercent > 0 {
					print("Objective-C: ".textColor(.languageColor) + "\(objcPercent) %".textColor(.accentColor))
                }
            }
        }
	}
}

// MARK: - Public
extension CodeAnalyser {

	private func createStartPath(path: String) -> () -> IO<String> {
		return { IO { path } }
	}

	func start(startPath: String) -> IO<Void> {
		startProgramWithMessage("Analyzing current path. Stand by...")
			.flatMap(createStartPath(path: startPath))
			.flatMap(subdirectoriesFromPath)
			.flatMap(analyzeSubpaths)
			.flatMap(summary)
	}
}
