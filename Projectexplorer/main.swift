import Foundation

#if DEBUG
	print(FileManager.default.currentDirectoryPath)
#endif

TimeCalculator.run {
	CodeAnalyser().start(startPath: FileManager.default.currentDirectoryPath)
}
.flatMap(Rounding.decimals(2))
.flatMap(TimeCalculator.outputTimemeasure)
.unsafeRun()


