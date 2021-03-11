//
//  SubString+count.swift
//  pinfo
//
//  Created by Mikael Konradsson on 2021-03-09.
//

import Foundation

extension Substring {

	func countInstances(of stringToFind: String) -> Int {
		var count = 0
		var searchRange: Range<String.Index>?
		while let foundRange = range(of: stringToFind, options: [], range: searchRange) {
			count += 1
			searchRange = Range(uncheckedBounds: (lower: foundRange.upperBound, upper: endIndex))
		}
		return count
	}
}

extension String {

	var trimEnd: String {
		var newString = self
		while newString.last?.isWhitespace == true {
			newString = String(newString.dropLast())
		}
		return newString
	}
}
