//
//  FileType+interfaces.swift
//  pinfo
//
//  Created by Mikael Konradsson on 2021-03-09.
//

import Foundation

extension Filetype {

	var interfaces: String {
		switch self {
		case .c:
			return ""
		case .cpp:
			return ""
		case .kotlin:
			return "interface "
		case .swift:
			return "protocol "
		case .objectiveC:
			return "@interface "
		default:
			return ""
		}
	}
}
