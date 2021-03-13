//
//  String+trimend.swift
//  pinfo
//
//  Created by Mikael Konradsson on 2021-03-13.
//

import Foundation

extension String {

	var trimEnd: String {
		var newString = self
		while newString.last?.isWhitespace == true {
			newString = String(newString.dropLast())
		}
		return newString
	}
}
