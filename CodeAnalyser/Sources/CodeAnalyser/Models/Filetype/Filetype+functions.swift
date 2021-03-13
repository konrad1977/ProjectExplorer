//
//  FileType+functions.swift
//  pinfo
//
//  Created by Mikael Konradsson on 2021-03-09.
//

import Foundation

extension Filetype {
	public var functions: String {
		switch self {
		case .kotlin:
			return "fun "
		case .swift:
			return "func "
		case .objectiveC:
			return "- ("
		default:
			return ""
		}
	}
}
