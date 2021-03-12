//
//  PredicateSet.swift
//  Projectexplorer
//
//  Created by Mikael Konradsson on 2021-03-07.
//

import Foundation

struct Predicate<A> {
	let contains: (A) -> Bool
}
