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
    /// An error that indicates that a system event could not be
    /// created from the specified key event.
    static func couldNotCreate(_ event: KeyEvent) -> Self {
        Self("Could not create system event from key event \(event).")
    }

    /// An error that indicates that no application with the
    /// specified name is currently running.
    static func applicationNotRunning(_ application: String) -> Self {
        Self("Application \"\(application)\" not currently running.")
    }
}
