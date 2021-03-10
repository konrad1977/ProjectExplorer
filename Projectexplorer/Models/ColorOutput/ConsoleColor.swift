//
//  ConsoleColor.swift
//  pinfo
//
//  Created by Mikael Konradsson on 2021-03-10.
//

import Foundation

enum TerminalFontStyle: String {
	case bold = "\u{001B}[0;1m"
	case dim = "\u{001B}[0;2m"
	case italic = "\u{001B}[0;3m"
	case underline = "\u{001B}[0;4m"
	case inverse = "\u{001B}[0;7m"
	case strike = "\u{001B}[0;9m"
	case hidden = "\u{001B}[0;8m"
}

enum TerminalForegroundColor: String {
	case reset = "\u{001B}[0;0m"
	case black = "\u{001B}[0;30m"
	case red = "\u{001B}[0;31m"
	case green = "\u{001B}[0;32m"
	case yellow = "\u{001B}[0;33m"
	case blue = "\u{001B}[0;34m"
	case magenta = "\u{001B}[0;35m"
	case cyan = "\u{001B}[0;36m"
	case white = "\u{001B}[0;37m"
}

enum TerminalBackgroundColor: String {
	case black = "\u{001B}[0;40m"
	case red = "\u{001B}[0;41m"
	case green = "\u{001B}[0;42m"
	case yellow = "\u{001B}[0;43m"
	case blue = "\u{001B}[0;44m"
	case magenta = "\u{001B}[0;45m"
	case cyan = "\u{001B}[0;46m"
	case white = "\u{001B}[0;47m"
}

private let endStyle: String = "\u{001B}[0;0m"

extension String {

	@discardableResult
	func textColor(_ color: TerminalForegroundColor) -> Self {
		color.rawValue + self + endStyle
	}

	@discardableResult
	func backgroundColor(_ color: TerminalBackgroundColor) -> Self {
		color.rawValue + self + endStyle
	}

	@discardableResult
	func fontStyle(_ style: TerminalFontStyle) -> Self {
		style.rawValue + self + endStyle
	}
}

