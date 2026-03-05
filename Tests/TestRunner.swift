import Foundation

// Minimal test framework for DyWallpaper (no XCTest dependency needed for swiftc builds)

var totalTests = 0
var passedTests = 0
var failedTests: [(name: String, message: String)] = []

func test(_ name: String, _ body: () throws -> Void) {
    totalTests += 1
    do {
        try body()
        passedTests += 1
        print("  PASS  \(name)")
    } catch {
        let msg = "\(error)"
        failedTests.append((name: name, message: msg))
        print("  FAIL  \(name) — \(msg)")
    }
}

struct AssertionError: Error, CustomStringConvertible {
    let description: String
}

func assertEqual<T: Equatable>(_ lhs: T, _ rhs: T, file: String = #file, line: Int = #line) throws {
    guard lhs == rhs else {
        throw AssertionError(description: "Expected \(rhs), got \(lhs) (\(file):\(line))")
    }
}

func assertTrue(_ value: Bool, _ message: String = "Expected true", file: String = #file, line: Int = #line) throws {
    guard value else {
        throw AssertionError(description: "\(message) (\(file):\(line))")
    }
}

func assertFalse(_ value: Bool, _ message: String = "Expected false", file: String = #file, line: Int = #line) throws {
    guard !value else {
        throw AssertionError(description: "\(message) (\(file):\(line))")
    }
}

func assertNotNil<T>(_ value: T?, _ message: String = "Expected non-nil", file: String = #file, line: Int = #line) throws {
    guard value != nil else {
        throw AssertionError(description: "\(message) (\(file):\(line))")
    }
}

func assertNil<T>(_ value: T?, _ message: String = "Expected nil", file: String = #file, line: Int = #line) throws {
    guard value == nil else {
        throw AssertionError(description: "\(message) (\(file):\(line))")
    }
}

func printSummary() {
    print("")
    print("═══════════════════════════════════════")
    print("Results: \(passedTests)/\(totalTests) passed")
    if !failedTests.isEmpty {
        print("")
        print("Failed tests:")
        for f in failedTests {
            print("  - \(f.name): \(f.message)")
        }
    }
    print("═══════════════════════════════════════")
}

func exitWithStatus() -> Never {
    printSummary()
    exit(failedTests.isEmpty ? 0 : 1)
}
