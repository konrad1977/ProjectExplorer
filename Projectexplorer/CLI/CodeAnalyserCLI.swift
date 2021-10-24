//
//  CodeAnalyserCLI.swift
//  pinfo
//
//  Created by Mikael Konradsson on 2021-03-12.
//

import Foundation
import CodeAnalyser
import Funswift

struct CodeAnalyserCLI {

	private static func lineSeparator(color: TerminalColor = .accentColor) -> IO<Void> {
		printRepeatingCharacter("—", count: 35, color: color)
	}

    static func printLargestFiles(take: Int) -> ([FileLineInfo]) -> IO<Void> {
        { fileInfo in
            IO {
                let largestFiles = fileInfo
                    .sorted(by: { $0.linecount > $1.linecount })
                    .prefix(take)
                    .map { ($0.path, $0.linecount)}

                largestFiles.forEach { (path, count) in
                    Console.output("\(path):", text: "\(count)", color: .lineColor)
                }
                Console.output("Total files:", text: "\(fileInfo.count)", color: .barColor)
            }
        }
    }

	static func printSummary(_ langs: [LanguageSummary], statistics: [Statistics]) -> IO<Void> {
		IO {
			var langSummaries = langs
			if langSummaries.count == 2 {
				langSummaries = langSummaries.dropLast()
			}

			langSummaries
				.map(printSummaryFor)
				.forEach { $0.unsafeRun() }

            _ = zip(
				printPercentSummary(statistics),
				lineSeparator()
			).unsafeRun()
		}
	}

	static func printSummaryFor(_ language: LanguageSummary) -> IO<Void> {

		guard language.filetype != .empty
		else { return IO { } }

		return IO {
			let width = 35
			Console.output(language.filetype.description, color: .white, lineWidth: width)
			Console.output("classes:", data: language.classes, color: .classColor, width: width)
			Console.output("\(language.filetype.structs.trimEnd):", data: language.structs, color: .structColor, width: width)
			Console.output("\(language.filetype.enums.trimEnd):", data: language.enums, color: .enumColor, width: width)
			Console.output("functions:", data: language.functions, color: .functionColor, width: width)
			Console.output("\(language.filetype.interfaces.trimEnd):", data: language.interfaces, color: .interfaceColor, width: width)
			Console.output("\(language.filetype.imports)", data: language.imports, color: .functionColor, width: width)
			Console.output("\(language.filetype.extensions)", data: language.extensions, color: .functionColor, width: width)
			Console.output("files:", data: language.filecount, color: .fileColor, width: width)
			Console.output("lines:", data: language.linecount, color: .lineColor, width: width)
            Console.output("Avg lines:", data: language.linecount / language.filecount, color: .lineColor, width: width)
		}
	}

	private static func printPercentSummary(_ statistics: [Statistics]) -> IO<Void> {

		guard statistics.isEmpty == false
		else { return IO {} }

		return IO {

			let rounding = Rounding.decimals(1)

			statistics
				.filter { $0.lineCountPercentage > 0 }
				.forEach { stat in
					let percentage = rounding(stat.lineCountPercentage).unsafeRun()
					lineSeparator().unsafeRun()
					Console.output(
						stat.filetype.description + " code",
						text: "\(percentage) %",
						color: .structColor,
						width: 35
					)
				}
			}
		}

	private static func printRepeatingCharacter(
		_ char: Character,
		count: Int,
		color: TerminalColor = .accentColor
	) -> IO<Void> {
		IO { print(String(repeating: char, count: count).textColor(color)) }
	}

	public static func printTime(_ value: Double) -> IO<Void> {
		IO { print("Total time: " + "\(value)".textColor(.accentColor) + " seconds") }
	}
}
