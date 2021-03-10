//
//  SwiftAnalysis.swift
//  pinfo
//
//  Created by Mikael Konradsson on 2021-03-08.
//

import Foundation

enum SourceFileAnalysis {

	static func countFunctions(filetype: Filetype) -> (String.SubSequence) -> IO<Int> {
		{ str in IO { str.countInstances(of: filetype.functions) } }
	}

	static func countInterfaces(filetype: Filetype) -> (String.SubSequence) -> IO<Int> {
		{ str in IO { str.countInstances(of: filetype.interfaces) } }
	}

	static func countClasses(filetype: Filetype) -> (String.SubSequence) -> IO<Int> {
		{ str in IO { str.countInstances(of: filetype.classes) } }
	}

	static func countExtensions(sourceFile: String.SubSequence) -> IO<Int> {
		IO { sourceFile.countInstances(of:"extension ") }
	}

    static func countEnums(filetype: Filetype) -> (String.SubSequence) -> IO<Int> {
        { str in IO { str.countInstances(of: filetype.enums) } }
    }

    static func countStructs(filetype: Filetype) -> (String.SubSequence) -> IO<Int> {
        { str in IO { str.countInstances(of: filetype.structs) } }
    }

	static func countLinesIn(sourceFile: String.SubSequence) -> IO<Int> {
		IO { sourceFile.components(separatedBy: .newlines).count - 1 }
	}

	static func countCommentIn(sourceFile: String.SubSequence) -> IO<Int> {
		return IO { sourceFile.countInstances(of: "//") + sourceFile.countInstances(of: "/*")   }
	}
}
