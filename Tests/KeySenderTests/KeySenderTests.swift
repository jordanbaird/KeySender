//
// KeySenderTests.swift
// KeySender
//

import XCTest
@testable import KeySender

final class KeySenderTests: XCTestCase {
    func testOpenAndSend() throws {
        try KeySender(for: "Hello").openApplicationAndSend("TextEdit")
    }
}
