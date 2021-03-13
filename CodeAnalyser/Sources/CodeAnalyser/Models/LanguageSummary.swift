//
//  LanguageSummary.swift
//  pinfo
//
//  Created by Mikael Konradsson on 2021-03-12.
//

import Foundation

public struct LanguageSummary {
	public let classes: Int
	public let structs: Int
	public let enums: Int
	public let interfaces: Int
	public let functions: Int
	public let imports: Int
	public let extensions: Int
	public let linecount: Int
	public let filecount: Int
	public let filetype: Filetype
}

public struct Statistics {
	public let filetype: Filetype
	public let lineCountPercentage: Double

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
		imports: 0,
		extensions: 0,
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
