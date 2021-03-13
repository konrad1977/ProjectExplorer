//
//  FileType.swift
//  pinfo
//
//  Created by Mikael Konradsson on 2021-03-09.
//

import Foundation

public enum Filetype {
	case all
	case kotlin
	case swift
	case objectiveC
	case none

	init(extension: String) {
		switch `extension` {
		case "kt", "kts", "ktm":
			self = .kotlin
        case "m", "h":
			self = .objectiveC
		case "swift":
			self = .swift
		default:
			self = .none
		}
	}
}
