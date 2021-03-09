//
//  FileType+classes.swift
//  pinfo
//
//  Created by Mikael Konradsson on 2021-03-09.
//

import Foundation

extension Filetype {

	var classes: String {
		switch self {
		case .c:
			return ""
		case .cpp:
			return "class "
		case .kotlin:
			return "class "
		case .swift:
			return "class "
		case .objectiveC:
			return "@implementation "
		default:
			return ""
		}
	}
}
