//
//  IO.swift
//  Projectexplorer
//
//  Created by Mikael Konradsson on 2021-03-07.
//

import Foundation

struct IO<A> {

	let unsafeRun: () -> A

	func map<B>(_ f: @escaping (A) -> B) -> IO<B> {
		IO<B> { f(self.unsafeRun()) }
	}

	func flatmap<B>(_ f: @escaping (A) -> IO<B>) -> IO<B> {
		IO<B> { f(self.unsafeRun()).unsafeRun() }
	}
}

func zip<A, B>(
	_ first: IO<A>,
	_ second: IO<B>
) -> IO<(A, B)> {
	IO { (first.unsafeRun(), second.unsafeRun()) }
}

func zip<A, B, C>(
	_ first: IO<A>,
	_ second: IO<B>,
	_ third: IO<C>
) -> IO<(A, B, C)> {
	zip(first, zip(second, third)).map { ($0, $1.0, $1.1) }
}

func zip<A, B, C, D>(
	_ first: IO<A>,
	_ second: IO<B>,
	_ third: IO<C>,
	_ forth: IO<D>
) -> IO<(A, B, C, D)> {
	zip(first, zip(second, third, forth)).map { ($0, $1.0, $1.1, $1.2) }
}
