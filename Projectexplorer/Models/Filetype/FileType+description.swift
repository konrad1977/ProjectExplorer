//
//  FileType+description.swift
//  pinfo
//
//  Created by Mikael Konradsson on 2021-03-09.
//

import Foundation

extension Filetype {
	var description: String {
		switch self {
		case .c:
			return "C"
		case .cpp:
			return "C++"
		case .kotlin:
			return "Kotlin"
		case .swift:
			return "Swift"
		case .objectiveC:
			return "Objective-C"
		case .none:
			return ""
		case .all:
			return "Summary"
		}
	}
}
