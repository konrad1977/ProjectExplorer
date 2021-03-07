//
//  Program.swift
//  Projectexplorer
//
//  Created by Mikael Konradsson on 2021-03-07.
//

import Foundation

enum TerminalColor: String {
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

private func colorPrint(color: TerminalColor, text: String) {
	print(color.rawValue + text + TerminalColor.reset.rawValue)
}

struct Fileinfo {
	let filename: String
	let linecount: Int
    let comments: Int
}

extension Fileinfo {
	static var empty = Fileinfo(filename: "", linecount: 0, comments: 0)
}

struct Program {

	private func executablePath() -> IO<String> {
		guard let path = Bundle.main.resourcePath
		else { return IO { "" } }
        return IO { path }
	}

	private func subdirectoriesFromPath(_ path: String) -> IO<[String]> {
		guard let paths = try? FileManager.default
				.subpathsOfDirectory(atPath: path)
				.filter({ $0.hasSuffix(".swift") })

		else { return IO { [] } }
		return IO { paths }
	}

	private func analysePaths(_ paths: [String]) -> IO<[Fileinfo]> {
		IO { paths
			.map(analysePath)
			.map { $0.unsafeRun() }
			.sorted(by: { $0.filename < $1.filename })
		}
	}

	private func startProgramWithMessage(_ message: String) -> IO<Void> {
		IO { colorPrint(color: .yellow, text: message) }
	}

	private func analysePath(_ path: String) -> IO<Fileinfo> {
        let sourceFile = fileFromPath(path).unsafeRun()
        let linecount = linecountForSourceFile(sourceFile).unsafeRun()
        let comments = commentInSourceFile(sourceFile).unsafeRun()
		let filename = URL(fileURLWithPath: path).deletingPathExtension().lastPathComponent

		return IO { Fileinfo(filename: filename, linecount: linecount, comments: comments) }
	}

    private func fileFromPath(_ path: String) -> IO<String> {
        guard let file = try? String(contentsOfFile: path, encoding: .ascii)
        else { return IO { "" } }

        return IO { file }
    }

	private func linecountForSourceFile(_ sourceFile: String) -> IO<Int> {
        IO { sourceFile.components(separatedBy: .newlines).count }
	}

    private func commentInSourceFile(_ sourceFile: String) -> IO<Int> {
        IO { sourceFile.components(separatedBy: "//").count }
    }

	private func printSummary(_ fileInfos: [Fileinfo]) -> IO<Void> {
		zip(
			printFilelist(fileInfos),
			repeatString("⎻", count: 60),
			printProjectSummary(fileInfos),
			repeatString("⎼", count: 60)
		).map { _ in }
	}

	private func repeatString(_ char: Character, count: Int) -> IO<Void> {
		IO { colorPrint(color: .yellow, text: String(repeating: char, count: count)) }
	}

	private func printFilelist(_ infos: [Fileinfo]) -> IO<Void> {
		IO {
            infos.forEach {
                let lineCount = "\(TerminalColor.red.rawValue + "\($0.linecount)" + TerminalColor.reset.rawValue)"
                print("\($0.filename):\(lineCount)")
			}
		}
	}

	private func printProjectSummary(_ infos: [Fileinfo]) -> IO<Void> {
		let totalFiles = infos.count
		let totalLines = infos.reduce(0) { acc, fileInfo in acc + fileInfo.linecount }
        let totalComments = infos.reduce(0) { acc, fileInfo in acc + fileInfo.comments }

        return IO {

            let lineCount = "Swift files:\(TerminalColor.red.rawValue + "\(totalFiles)" + TerminalColor.reset.rawValue)"
            let separator = "\(TerminalColor.yellow.rawValue + " • " + TerminalColor.reset.rawValue)"
            let codeLines = "Code lines:\(TerminalColor.red.rawValue + "\(totalLines)" + TerminalColor.reset.rawValue)"
            let comments = "comments:\(TerminalColor.red.rawValue + "\(totalComments)" + TerminalColor.reset.rawValue)"
            print("\(lineCount)\(separator)\(codeLines)\(separator)\(comments)")
		}
	}

	func start() -> IO<Void> {
		startProgramWithMessage("Analysing path. Stand by...")
			.flatmap(executablePath)
			.flatmap(subdirectoriesFromPath)
			.flatmap(analysePaths)
			.flatmap(printSummary)
	}
}
