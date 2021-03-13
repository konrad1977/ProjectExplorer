/*
  Fileinfo.swift
  Projectexplorer

  Created by Mikael Konradsson on 2021-03-07.
*/

import Foundation

struct Fileinfo {
	let filename: String
	let classes: Int
	let structs: Int
	let enums: Int
	let interfaces: Int
	let functions: Int
	let imports: Int
	let extensions: Int
	let linecount: Int
	let filetype: Filetype
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
