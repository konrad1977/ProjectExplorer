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

	func flatMap<B>(_ f: @escaping (A) -> IO<B>) -> IO<B> {
		IO<B> { f(self.unsafeRun()).unsafeRun() }
	}
}
extension IO {
	static func pure<A>(_ value: A) -> IO<A> {
		IO<A> { value }
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
	zip(first, zip(second, third))
		.map { ($0, $1.0, $1.1) }
}

func zip<A, B, C, D>(
	_ first: IO<A>,
	_ second: IO<B>,
	_ third: IO<C>,
	_ forth: IO<D>
) -> IO<(A, B, C, D)> {
	zip(first, zip(second, third, forth))
		.map { ($0, $1.0, $1.1, $1.2) }
}

func zip<A, B, C, D, E>(
	_ first: IO<A>,
	_ second: IO<B>,
	_ third: IO<C>,
	_ forth: IO<D>,
	_ fifth: IO<E>
) -> IO<(A, B, C, D, E)> {
	zip(first, zip(second, third, forth, fifth))
		.map { ($0, $1.0, $1.1, $1.2, $1.3) }
}

func zip<A, B, C, D, E, F>(
	_ first: IO<A>,
	_ second: IO<B>,
	_ third: IO<C>,
	_ forth: IO<D>,
	_ fifth: IO<E>,
	_ sixth: IO<F>
) -> IO<(A, B, C, D, E, F)> {
	zip(first, zip(second, third, forth, fifth, sixth))
		.map { ($0, $1.0, $1.1, $1.2, $1.3, $1.4) }
}

func zip<A, B, C, D, E, F, G>(
	_ first: IO<A>,
	_ second: IO<B>,
	_ third: IO<C>,
	_ forth: IO<D>,
	_ fifth: IO<E>,
	_ sixth: IO<F>,
	_ seventh: IO<G>
) -> IO<(A, B, C, D, E, F, G)> {
	zip(first, zip(second, third, forth, fifth, sixth, seventh))
		.map { ($0, $1.0, $1.1, $1.2, $1.3, $1.4, $1.5) }
}

func zip<A, B, C, D, E, F, G, H>(
	_ first: IO<A>,
	_ second: IO<B>,
	_ third: IO<C>,
	_ forth: IO<D>,
	_ fifth: IO<E>,
	_ sixth: IO<F>,
	_ seventh: IO<G>,
	_ eigth: IO<H>
) -> IO<(A, B, C, D, E, F, G, H)> {
	zip(first, zip(second, third, forth, fifth, sixth, seventh, eigth))
		.map { ($0, $1.0, $1.1, $1.2, $1.3, $1.4, $1.5, $1.6) }
}

func zip<A, B, C, D, E, F, G, H, I>(
	_ first: IO<A>,
	_ second: IO<B>,
	_ third: IO<C>,
	_ forth: IO<D>,
	_ fifth: IO<E>,
	_ sixth: IO<F>,
	_ seventh: IO<G>,
	_ eigth: IO<H>,
	_ ninth: IO<I>
) -> IO<(A, B, C, D, E, F, G, H, I)> {
	zip(first, zip(second, third, forth, fifth, sixth, seventh, eigth, ninth))
		.map { ($0, $1.0, $1.1, $1.2, $1.3, $1.4, $1.5, $1.6, $1.7) }
}

func zip<A, B, C, D, E, F, G, H, I, J>(
	_ first: IO<A>,
	_ second: IO<B>,
	_ third: IO<C>,
	_ forth: IO<D>,
	_ fifth: IO<E>,
	_ sixth: IO<F>,
	_ seventh: IO<G>,
	_ eigth: IO<H>,
	_ ninth: IO<I>,
	_ tenth: IO<J>
) -> IO<(A, B, C, D, E, F, G, H, I, J)> {
	zip(first, zip(second, third, forth, fifth, sixth, seventh, eigth, ninth, tenth))
		.map { ($0, $1.0, $1.1, $1.2, $1.3, $1.4, $1.5, $1.6, $1.7, $1.8) }
}