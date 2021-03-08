/*
  Fileinfo.swift
  Projectexplorer

  Created by Mikael Konradsson on 2021-03-07.
*/

import Foundation

enum Filetype {
    case all
	case c
	case cpp
	case kotlin
	case swift
	case objectiveC
	case none

	init(extension: String) {
		switch `extension` {
		case "c":
			self = .c
		case "cpp", "mm", "cc":
			self = .cpp
		case "kt", "kts", "ktm":
			self = .kotlin
		case "m":
			self = .objectiveC
		case "swift":
			self = .swift
		default:
			self = .none
		}
	}
}

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
            return "All"
        }
	}
}

struct Fileinfo {
	let filename: String
	let linecount: Int
	let comments: Int
	let filetype: Filetype
}

extension Fileinfo {
	static var empty = Fileinfo(filename: "", linecount: 0, comments: 0, filetype: .none)
}
