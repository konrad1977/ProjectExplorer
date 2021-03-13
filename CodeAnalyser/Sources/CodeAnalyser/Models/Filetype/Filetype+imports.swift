//
//  Filetype+imports.swift
//  pinfo
//
//  Created by Mikael Konradsson on 2021-03-13.
//

import Foundation

extension Filetype {
	public var imports: String {
		switch self {
		case .kotlin:
			return "import "
		case .swift:
			return "import "
		case .objectiveC:
			return "#import "
		default:
			return "imports "
		}
	}
}
