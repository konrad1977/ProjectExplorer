//
//  CodeAnalyser.swift
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

public struct CodeAnalyser {

	public init () {}

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
			.flatMap {
				analyseSourcefile(filename, filedata: $0, filetype: filetype)
			}
	}

	private func createFileInfo(_ path: String) -> IO<Fileinfo> {
		let fileUrl = URL(fileURLWithPath: path)
		let filetype = Filetype(extension: fileUrl.pathExtension)
		let filename = fileUrl.lastPathComponent
		return analyzeSourceFile(path: path, filename: filename, filetype: filetype)
	}

	private func analyzeSubpaths(_ paths: [String]) -> IO<[Fileinfo]> {
		IO { paths
			.map(createFileInfo)
			.map { $0.unsafeRun() }
		}
	}

	private func createLanguageSummary(_ fileInfo: [Fileinfo]) -> IO<([LanguageSummary], [Statistics])> {

		let filteredListFor = filterered(fileInfo)

		let summary = zip(
			createSummaryForLanguage(.swift, fileInfo: filteredListFor(.swift).unsafeRun()),
			createSummaryForLanguage(.kotlin, fileInfo: filteredListFor(.kotlin).unsafeRun()),
			createSummaryForLanguage(.objectiveC, fileInfo: filteredListFor(.objectiveC).unsafeRun()),
			createSummaryForLanguage(.all, fileInfo: fileInfo)
		).map { swift, kotlin, objc, all in
			[swift, kotlin, objc, all]
		}.unsafeRun()

		return IO { (summary, LanguageSummary.statistics(from: summary)) }
	}

	private func createSummaryForLanguage(_ filetype: Filetype, fileInfo: [Fileinfo]) -> IO<LanguageSummary> {

		guard fileInfo.count > 0
		else { return IO { .empty } }

		let (classes, structs, enums, interfaces, functions, lines, imports, extensions) =
			fileInfo.reduce(into: (0, 0, 0, 0, 0, 0, 0, 0)) { acc, fileInfo in
			acc.0 += fileInfo.classes
			acc.1 += fileInfo.structs
			acc.2 += fileInfo.enums
			acc.3 += fileInfo.interfaces
			acc.4 += fileInfo.functions
			acc.5 += fileInfo.linecount
			acc.6 += fileInfo.imports
			acc.7 += fileInfo.extensions
		}
		return IO {
			LanguageSummary(
				classes: classes,
				structs: structs,
				enums: enums,
				interfaces: interfaces,
				functions: functions,
				imports: imports,
				extensions: extensions,
				linecount: lines,
				filecount: fileInfo.count,
				filetype: filetype
			)
		}
	}

	private func filterered(_ info: [Fileinfo]) -> (Filetype) -> IO<[Fileinfo]> {
		return { filetype in IO { info.filter { $0.filetype == filetype } } }
	}

	private func createStartPath(path: String) -> IO<String> {
		return IO { path }
	}
}

// MARK: - Public
extension CodeAnalyser {

	public func analyseSourcefile(
		_ filename: String,
		filedata: String.SubSequence,
		filetype: Filetype
	) -> IO<Fileinfo> {

		zip(
			IO(filename),
			SourceFileAnalysis.countClasses(filetype: filetype)(filedata),
			SourceFileAnalysis.countStructs(filetype: filetype)(filedata),
			SourceFileAnalysis.countEnums(filetype: filetype)(filedata),
			SourceFileAnalysis.countInterfaces(filetype: filetype)(filedata),
			SourceFileAnalysis.countFunctions(filetype: filetype)(filedata),
			SourceFileAnalysis.countImports(filetype: filetype)(filedata),
			SourceFileAnalysis.countExtensions(filetype: filetype)(filedata),
			SourceFileAnalysis.countLinesIn(sourceFile: filedata),
            IO(filetype)
		)
		.map(Fileinfo.init)
	}

	public func start(startPath: String) -> IO<[Fileinfo]> {
		createStartPath(path: startPath)
			.flatMap(subdirectoriesFromPath)
			.flatMap(analyzeSubpaths)
	}

	public func start(startPath: String) -> IO<([LanguageSummary], [Statistics])> {
		self.start(startPath: startPath)
			.flatMap(createLanguageSummary)
	}
}
