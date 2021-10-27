//
//  
//

import Foundation

struct ArgumentParser {
    let keyword: String
    let args: [String]
}

extension ArgumentParser {

    func hasArgument() -> Bool {
        let (first, _) = findArgumentIndicies(for: keyword, in: args)
        return first != nil
    }

    func parse() -> [String] {
        let (first, last) = findArgumentIndicies(for: keyword, in: args)

        guard let first = first
        else { return [] }

        guard let lastIndex = last else {
            return Array(args.dropFirst(first + 1))
                .map { $0.lowercased() }
        }

        return Array(args[first + 1 ..< lastIndex])
            .map { $0.lowercased() }
    }
}

extension ArgumentParser {
    private func findArgumentIndicies(for argv: String, in args: [String]) -> (first: Int?, last: Int?) {
        if let first = args.firstIndex(of: argv) {
            let copy = args.dropFirst(first)
            if let next = copy.firstIndex(where: { $0 != argv && $0.hasPrefix("--")}) {
                return (first, next)
            }
            return (first, nil)
        }
        return (nil, nil)
    }
}
