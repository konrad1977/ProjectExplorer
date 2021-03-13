//
//  Filetype+extensions.swift
//  pinfo
//
//  Created by Mikael Konradsson on 2021-03-13.
//

import Foundation

extension Filetype {

	var extensions: String {
		switch self {
		case .kotlin:
			return ""
		case .swift:
			return "extension "
		case .objectiveC:
			return ""
		default:
			return "extensions "
		}
	}
}
