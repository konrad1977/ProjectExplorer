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
}

extension Fileinfo {
	static var empty = Fileinfo(filename: "", linecount: 0)
}

extension Fileinfo: CustomStringConvertible {
	var description: String {
		"\(filename):\(linecount)"
	}
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
		let linecount = linecountForFile(path).unsafeRun()
		let filename = URL(fileURLWithPath: path).deletingPathExtension().lastPathComponent
		return IO { Fileinfo(filename: filename, linecount: linecount) }
	}

	private func linecountForFile(_ path: String) -> IO<Int> {
		guard let file = try? String(contentsOfFile: path, encoding: .ascii)
		else { return IO { 0 } }

		return IO { file.components(separatedBy: .newlines).count }
	}

	private func printSummary(_ fileInfos: [Fileinfo]) -> IO<Void> {
		zip(
			printFilelist(fileInfos),
			repeatString("-", count: 40),
			printCount(fileInfos),
			repeatString("-", count: 40)
		).map { _ in }
	}

	private func repeatString(_ char: Character, count: Int) -> IO<Void> {
		IO { colorPrint(color: .green, text: String(repeating: char, count: count)) }
	}

	private func printFilelist(_ infos: [Fileinfo]) -> IO<Void> {
		IO { infos.forEach {
			print("\($0.filename):\(TerminalColor.red.rawValue + "\($0.linecount)" + TerminalColor.reset.rawValue)")
			}
		}
	}

	private func printCount(_ infos: [Fileinfo]) -> IO<Void> {
		let totalFiles = infos.count
		let totalLines = infos.reduce(0) { acc, fileInfo in
			acc + fileInfo.linecount
		}

		return IO {
			colorPrint(
				color: .green,
				text: "Files: \(totalFiles) • lines of code: \(totalLines)"
			)
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
