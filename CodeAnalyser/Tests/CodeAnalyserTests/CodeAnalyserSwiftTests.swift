import XCTest
@testable import CodeAnalyser

final class CodeAnalyserTests: XCTestCase {

    func testEmptyResult() {
		let (langs, statistics) = CodeAnalyser().start(startPath: "/").unsafeRun()
		XCTAssertEqual(langs.count, 4)
		XCTAssertTrue(statistics.isEmpty, "Statistics not empty")
    }

	func testAnalyserImportsSwift() {
		let fileInfo = CodeAnalyser()
			.analyseSourcefile(
				"imports",
				filedata: swiftImports[...],
				filetype: .swift
			)
		XCTAssertEqual(fileInfo.unsafeRun().imports, 2)
	}

	func testAnalyserExtensionsSwift() {
		let fileInfo = CodeAnalyser()
			.analyseSourcefile(
				"extensions",
				filedata: extensions[...],
				filetype: .swift
			)
		XCTAssertEqual(fileInfo.unsafeRun().extensions, 3)
	}

	func testAnalyserClassesSwift() {
		let fileInfo = CodeAnalyser()
			.analyseSourcefile(
				"classes",
				filedata: classes[...],
				filetype: .swift
			)
		XCTAssertEqual(fileInfo.unsafeRun().classes, 2)
	}

	func testAnalyserFunctionsSwift() {
		let fileInfo = CodeAnalyser()
			.analyseSourcefile(
				"functions",
				filedata: functions[...],
				filetype: .swift
			)
		XCTAssertEqual(fileInfo.unsafeRun().functions, 3)
	}

	func testAnalyserFullFileSwift() {
		let fileInfo = CodeAnalyser()
			.analyseSourcefile(
				"fullfile",
				filedata: fullFile[...],
				filetype: .swift
			)
		XCTAssertEqual(fileInfo.unsafeRun().imports, 1)
		XCTAssertEqual(fileInfo.unsafeRun().classes, 0)
		XCTAssertEqual(fileInfo.unsafeRun().structs, 1)
		XCTAssertEqual(fileInfo.unsafeRun().extensions, 2)
		XCTAssertEqual(fileInfo.unsafeRun().functions, 11)
		XCTAssertEqual(fileInfo.unsafeRun().enums, 1)
		XCTAssertEqual(fileInfo.unsafeRun().linecount, 30)
		XCTAssertEqual(fileInfo.unsafeRun().filetype, .swift)
	}

    static var allTests = [
        ("emptyResult", testEmptyResult),
		("imports", testAnalyserImportsSwift),
		("extensions", testAnalyserExtensionsSwift),
		("classes", testAnalyserClassesSwift),
		("functions", testAnalyserFunctionsSwift),
		("fullfile", testAnalyserFullFileSwift)
    ]
}
