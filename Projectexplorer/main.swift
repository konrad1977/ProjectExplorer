import Foundation
import CodeAnalyser

#if DEBUG
	print(FileManager.default.currentDirectoryPath)
#endif


TimeCalculator.run {
	CodeAnalyser()
		.start(startPath: FileManager.default.currentDirectoryPath)
		.flatMap(CodeAnalyserCLI.printSummary)
}
.flatMap(Rounding.decimals(2))
.flatMap(CodeAnalyserCLI.printTime)
.unsafeRun()

