
import Foundation

let swiftImports = """
import Foundation
import UIKit
"""

let extensions = """
extension String: Error {}
extension String: Error {}
extension String: Error {}
"""

let classes = """
class MyClass{}
enum UI {}
class myclass{}
"""

let functions = """
func update() {}
class MyClass {}
static func staticUpdate() {}
private func privateUpdate() {}
enum MyEnum {}
class MyClass {}
"""

let fullFile = """
//
//  CodeAnalyser.swift
//  Projectexplorer
//
//  Created by Mikael Konradsson on 2021-03-07.
//

import Foundation

fileprivate extension Predicate where A == String {}

enum SomeEnum { }

public struct CodeAnalyser {
	public init () {}
	private func subdirectoriesFromPath(_ path: String) -> IO<[String]> {}
	private func sourceFile(for path: String) -> IO<String.SubSequence> {}
	private func analyzeSourceFile(path: String, filename: String, filetype: Filetype) -> IO<Fileinfo> {}
	private func createFileInfo(_ path: String) -> IO<Fileinfo> {}
	private func analyzeSubpaths(_ paths: [String]) -> IO<[Fileinfo]> {}
	private func createLanguageSummary(_ fileInfo: [Fileinfo]) -> IO<([LanguageSummary], [Statistics])> {}
	private func createSummaryForLanguage(_ filetype: Filetype, fileInfo: [Fileinfo]) -> IO<LanguageSummary> {}
	private func filterered(_ info: [Fileinfo]) -> (Filetype) -> IO<[Fileinfo]> {}
	private func createStartPath(path: String) -> IO<String> {}
}

// MARK: - Public
extension CodeAnalyser {
	public func analyseSourcefile(}
	public func start(startPath: String) -> IO<([LanguageSummary], [Statistics])> {}
}
"""
