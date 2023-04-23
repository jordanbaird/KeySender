//
// KeySenderError.swift
// KeySender
//

import Foundation

/// An error that can be thrown during a key sending operation.
public struct KeySenderError: LocalizedError {
    /// The message accompanying this error.
    public let message: String

    public var errorDescription: String? { message }

    /// Creates an error with the given message.
    public init(_ message: String) {
        self.message = message
    }
}

extension KeySenderError {
    static func couldNotCreate(_ event: KeyEvent) -> Self {
        Self("Could not create key event \(event).")
    }

    static func applicationNotRunning(_ application: String) -> Self {
        Self("Application \"\(application)\" not currently running.")
    }
}
