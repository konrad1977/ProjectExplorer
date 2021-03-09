//
//  SwiftAnalysis.swift
//  pinfo
//
//  Created by Mikael Konradsson on 2021-03-08.
//

import Foundation

enum SourceFileAnalysis {

	static func countFunctions(filetype: Filetype) -> (String.SubSequence) -> IO<Int> {
		{ str in IO { str.components(separatedBy: filetype.functions).count - 1} }
	}

	static func countInterfaces(filetype: Filetype) -> (String.SubSequence) -> IO<Int> {
		{ str in IO { str.components(separatedBy: filetype.interfaces).count - 1} }
	}

	static func countClasses(filetype: Filetype) -> (String.SubSequence) -> IO<Int> {
		{ str in IO { str.components(separatedBy: filetype.classes).count - 1} }
	}

	static func countExtensions(sourceFile: String.SubSequence) -> IO<Int> {
		IO { sourceFile.components(separatedBy: "extension ").count - 1}
	}

	static func countEnums(sourceFile: String.SubSequence) -> IO<Int> {
		IO { sourceFile.components(separatedBy: "enum ").count - 1}
	}

	static func countStructs(sourceFile: String.SubSequence) -> IO<Int> {
		IO { sourceFile.components(separatedBy: "struct ").count - 1 }
	}

	static func countLinesIn(sourceFile: String.SubSequence) -> IO<Int> {
		IO { sourceFile.components(separatedBy: .newlines).count - 1 }
	}

	static func countCommentIn(sourceFile: String.SubSequence) -> IO<Int> {
		let comments = sourceFile
			.components(separatedBy: "//").count - 1
			+
			sourceFile.components(separatedBy: "/*").count - 1
		return IO { comments }
	}
}
