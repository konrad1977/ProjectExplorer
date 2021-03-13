/*
  Fileinfo.swift
  Projectexplorer

  Created by Mikael Konradsson on 2021-03-07.
*/

import Foundation

public struct Fileinfo {
	public let filename: String
	public let classes: Int
	public let structs: Int
	public let enums: Int
	public let interfaces: Int
	public let functions: Int
	public let imports: Int
	public let extensions: Int
	public let linecount: Int
	public let filetype: Filetype
}

extension Fileinfo {
	static var empty = Fileinfo(
		filename: "",
		classes: 0,
		structs: 0,
		enums: 0,
		interfaces: 0,
		functions: 0,
		imports: 0,
		extensions: 0,
		linecount: 0,
		filetype: .none
	)
}
