import Foundation
import CodeAnalyser

#if DEBUG
	print(FileManager.default.currentDirectoryPath)
#endif

runProgram(args: CommandLine.arguments)

private func runProgram(args: [String]) {

    guard args.count > 1
    else { runProjectAnalytics(); return }

    let argsWithoutBinary = Array(args.dropFirst())

    if showHelp(args: argsWithoutBinary) {
        print("pinfo --[linecount n (top 'n' files)] [--lang languagename ('swift', 'kotlin', 'objc')] [--help]")
        return
    }

    let languages: Filetype = parseLanguages(args: argsWithoutBinary)

    if hasLinecount(args: args) == false {
        runProjectAnalytics(languages: languages)
        return
    }

    let take = parseLineCount(args: argsWithoutBinary)
    runLinecount(take: take, languages: languages)
}

private func showHelp(args: [String]) -> Bool {
    let (first, _) = findArgumentIndicies(for: "--help", in: args)
    return first != nil
}

private func hasLinecount(args: [String]) -> Bool {
    let (first, _) = findArgumentIndicies(for: "--linecount", in: args)
    return first != nil
}

private func parseLineCount(args: [String]) -> Int {
    let (first, _) = findArgumentIndicies(for: "--linecount", in: args)
    guard let first = first, args.count >= first
    else { return 5 }

    return Int(args[first + 1]) ?? 5
}

private func parseLanguages(args: [String]) -> Filetype {

    let (first, _) = findArgumentIndicies(for: "--lang", in: args)

    guard let first = first
    else { return .all }

    var fileType: Filetype = .empty

    let languages = Array(args.dropFirst(first + 1)).map { $0.lowercased() }
    if languages.contains(where: { $0 == "swift" }) {
        fileType.insert(.swift)
    } else if (languages.contains(where: { $0 == "kotlin" || $0 == "kt" })) {
        fileType.insert(.kotlin)
    } else if (languages.contains(where: { $0 == "objective-c" || $0 == "objc" || $0 == "objectivec" })) {
        fileType.insert(.objectiveC)
    }
    return fileType
}

private func findArgumentIndicies(for argv: String, in args: [String]) -> (first: Int?, last: Int?) {
    if let first = args.firstIndex(of: argv) {
        if let next = args.firstIndex(where: { $0 != argv && $0.hasPrefix("--")}) {
            return (first, next)
        }
        return (first, nil)
    }
    return (nil, nil)
}

private func runProjectAnalytics(languages: Filetype = .all) {
    TimeCalculator.run {
        CodeAnalyser()
            .statistics(from: FileManager.default.currentDirectoryPath, language: languages)
            .flatMap(CodeAnalyserCLI.printSummary)
    }
    .flatMap(Rounding.decimals(2))
    .flatMap(CodeAnalyserCLI.printTime)
    .unsafeRun()
}

private func runLinecount(take: Int = 5, languages: Filetype = .all) {
    TimeCalculator.run {
        CodeAnalyser()
            .fileInfo(from: FileManager.default.currentDirectoryPath, language: languages)
            .flatMap(CodeAnalyserCLI.printLargestFiles(take: take))
    }
    .flatMap(CodeAnalyserCLI.printTime)
    .unsafeRun()
}
