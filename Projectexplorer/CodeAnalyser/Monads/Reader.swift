//
//  Reader.swift
//  pinfo
//
//  Created by Mikael Konradsson on 2021-03-12.
//

import Foundation

struct Reader<Environment, A> {
	let run: (Environment) -> A

	func map<B>(_ f: @escaping (A) -> B) -> Reader<Environment, B> {
		Reader<Environment, B> { env in f(self.run(env)) }
	}

	func flatMap<B>(_ f: @escaping (A) -> Reader<Environment, B>) -> Reader<Environment, B> {
		Reader<Environment, B> { env in f(self.run(env)).run(env) }
	}
}
