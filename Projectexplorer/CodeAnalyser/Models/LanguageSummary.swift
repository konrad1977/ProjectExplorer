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

struct Statistics {
	let filetype: Filetype
	let lineCountPercentage: Double

	fileprivate init(filetype: Filetype, percentage: Double) {
		self.filetype = filetype
		self.lineCountPercentage = percentage
	}
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

extension LanguageSummary {
	
	static func statistics(from langs: [LanguageSummary]) -> [Statistics] {

		guard langs.count > 1, let summary = langs.filter({ $0.filetype == .all }).first
		else { return [] }

		let languges = langs.filter { $0.filetype != .all }

		return languges.map { lang in
			Statistics(
				filetype: lang.filetype,
				percentage: (Double(lang.linecount) / Double(summary.linecount)) * 100
			)
		}
	}
}
