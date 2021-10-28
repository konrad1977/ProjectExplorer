import Foundation
import CodeAnalyser

//#if DEBUG
//	print(FileManager.default.currentDirectoryPath)
//#endif

runProgram(args: CommandLine.arguments)

private func runProgram(args: [String]) {

    guard args.count > 1
    else { runProjectAnalytics(); return }

    let argsWithoutBinary = Array(args.dropFirst())

    if showHelp(args: argsWithoutBinary) {
        print("pinfo --[linecount n (top 'n' files)] [--lang languagename ('swift', 'kotlin', 'objc')] [--help] --exclude ['pods', 'SwiftPackages']")
        return
    }

    let languages: Filetype = parseLanguages(args: argsWithoutBinary)
    let filters: PathFilter = parsePathfilter(args: argsWithoutBinary)

    if showTodo(args: argsWithoutBinary) {
        runTodoAnalysis(language: languages, filter: filters)
        return
    }

    if hasLinecount(args: args) == false {
        runProjectAnalytics(languages: languages, filter: filters)
        return
    }

    let take = parseLineCount(args: argsWithoutBinary)
    runLinecount(take: take, languages: languages, pathFilter: filters)
}

private func showTodo(args: [String]) -> Bool {
    ArgumentParser(keyword: "--todo", args: args).hasArgument()
}

private func showHelp(args: [String]) -> Bool {
    ArgumentParser(keyword: "--help", args: args).hasArgument()
}

private func hasLinecount(args: [String]) -> Bool {
    ArgumentParser(keyword: "--linecount", args: args).hasArgument()
}

private func parseLineCount(args: [String]) -> Int {
    ArgumentParser(
        keyword: "--linecount",
        args: args
    ).parse(default: 5) { Int($0.first ?? "5") ?? 5 }
}

private func parsePathfilter(args: [String]) -> PathFilter {
    ArgumentParser(
        keyword: "--exclude",
        args: args
    ).parse(default: .empty) { .custom($0) }
}

private func parseLanguages(args: [String]) -> Filetype {
    ArgumentParser(
        keyword: "--lang",
        args: args
    ).parse(default: .all) {
        var fileType: Filetype = .empty

        if $0.contains(where: { $0 == "swift" }) {
            fileType.insert(.swift)
        }
        if $0.contains(where: { $0 == "kotlin" || $0 == "kt" }) {
            fileType.insert(.kotlin)
        }
        if $0.contains(where: { $0 == "objective-c" || $0 == "objc" || $0 == "objectivec" }) {
            fileType.insert(.objectiveC)
        }
        return fileType
    }
}

private func runTodoAnalysis(language: Filetype = .all, filter: PathFilter = .empty) {
    TimeCalculator.run {
        CodeAnalyser()
            .todos(from: FileManager.default.currentDirectoryPath, language: language, filter: filter)
            .flatMap(CodeAnalyserCLI.printTodoSummary)
    }
    .flatMap(Rounding.decimals(2))
    .flatMap(CodeAnalyserCLI.printTime)
    .unsafeRun()
}

private func runProjectAnalytics(languages: Filetype = .all, filter: PathFilter = .empty) {
    TimeCalculator.run {
        CodeAnalyser()
            .statistics(from: FileManager.default.currentDirectoryPath, language: languages, filter: filter)
            .flatMap(CodeAnalyserCLI.printSummary)
    }
    .flatMap(Rounding.decimals(2))
    .flatMap(CodeAnalyserCLI.printTime)
    .unsafeRun()
}

private func runLinecount(take: Int = 5, languages: Filetype = .all, pathFilter: PathFilter = .empty) {
    TimeCalculator.run {
        CodeAnalyser()
            .fileLineInfo(from: FileManager.default.currentDirectoryPath, language: languages, filter: pathFilter)
            .flatMap(CodeAnalyserCLI.printLargestFiles(take: take))
    }
    .flatMap(Rounding.decimals(2))
    .flatMap(CodeAnalyserCLI.printTime)
    .unsafeRun()
}
