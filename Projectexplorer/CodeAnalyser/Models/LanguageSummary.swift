//
//  LanguageSummary.swift
//  pinfo
//
//  Created by Mikael Konradsson on 2021-03-12.
//

import Foundation

struct LanguageSummary {
	let classes: Int
	let structs: Int
	let enums: Int
	let interfaces: Int
	let functions: Int
	let linecount: Int
	let filecount: Int
	let filetype: Filetype
}

extension LanguageSummary {
	static var empty = LanguageSummary(
		classes: 0,
		structs: 0,
		enums: 0,
		interfaces: 0,
		functions: 0,
		linecount: 0,
		filecount: 0,
		filetype: .none
	)
}
