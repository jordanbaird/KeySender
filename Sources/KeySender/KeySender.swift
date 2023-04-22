//
// KeySender.swift
// KeySender
//

import Cocoa

/// A type that can send key events to any running application.
///
/// To create a key sender, call one of its initializers. You can create an
/// instance with multiple key events that will be sent in succession, a single
/// key event, a key and some modifiers, or a string. You then call one of the
/// `send(to:)`, `trySend(to:)`, or `sendGlobally()` methods to send the event
/// to a running application of your choice.
///
/// As long as that application can accept the keys that you send, the effect
/// will be the same as if the keys had been entered manually.
///
/// ```swift
/// let sender = KeySender(key: .c, modifiers: .command)
/// try sender.send(to: "TextEdit")
///
/// let stringSender = KeySender(string: "Hello")
/// stringSender.trySend(to: "TextEdit")
/// ```
///
/// - Note: The application you send the key events to must currently be running,
///   or sending the events will fail.
public struct KeySender {
    /// The events that will be sent by this key sender.
    public let events: [KeyEvent]

    /// Creates a sender for the given key events.
    public init(for events: [KeyEvent]) {
        self.events = events
    }

    /// Creates a sender for the given key events.
    public init(for events: KeyEvent...) {
        self.events = events
    }

    /// Creates a sender for the given key event.
    public init(for event: KeyEvent) {
        self.events = [event]
    }

    /// Creates a sender for the given key and modifiers.
    ///
    /// This initializer works by creating a `KeyEvent` behind the scenes, then adding
    /// it to the instance's `events` property.
    public init(key: KeyEvent.Key, modifiers: [KeyEvent.Modifier]) {
        self.init(for: KeyEvent(key: key, modifiers: modifiers))
    }

    /// Creates a sender for the given key and modifiers.
    ///
    /// This initializer works by creating a `KeyEvent` behind the scenes, then adding
    /// it to the instance's `events` property.
    public init(key: KeyEvent.Key, modifiers: KeyEvent.Modifier...) {
        self.init(for: KeyEvent(key: key, modifiers: modifiers))
    }

    /// Creates a key sender for the given string.
    ///
    /// This initializer throws an error if the string contains an invalid character.
    /// Valid characters are those that appear on the keyboard, and that can be typed
    /// without the use of any modifiers. The exception is capital letters, which are
    /// valid. However, any character that requires a modifier key to be pressed, such
    /// as Shift-1 (for "!"), are invalid characters. To send one of these characters,
    /// use one of the other initializers to construct a key event using the key and
    /// modifiers necessary to type the character.
    public init(for string: String) throws {
        var events = [KeyEvent]()
        for character in string {
            guard let key = KeyEvent.Key(character) else {
                throw KeySenderError("Invalid character. Cannot create key event.")
            }
            let event: KeyEvent
            if character.isUppercase {
                event = KeyEvent(key: key, modifiers: [.shift])
            } else {
                event = KeyEvent(key: key, modifiers: [])
            }
            events.append(event)
        }
        self.events = events
    }
}

// MARK: - Helper Methods

extension KeySender {
    // Tries to convert a string into an NSRunningApplication.
    private func target(from string: String) throws -> NSRunningApplication {
        guard let target = NSWorkspace.shared.runningApplications.first(where: { $0.localizedName == string }) else {
            throw KeySenderError("Application \"\(string)\" not currently running.")
        }
        return target
    }

    private func cgEvent(from keyEvent: KeyEvent, keyDown: Bool) -> CGEvent? {
        let event = CGEvent(
            keyboardEventSource: CGEventSource(stateID: .hidSystemState),
            virtualKey: CGKeyCode(keyEvent.key.rawValue),
            keyDown: keyDown
        )
        event?.flags = KeyEvent.Modifier.flags(for: keyEvent.modifiers)
        return event
    }

    // All local send methods delegate to this one.
    private func sendLocally(event: KeyEvent, application: NSRunningApplication, sendKeyUp: Bool) {
        cgEvent(from: event, keyDown: true)?.postToPid(application.processIdentifier)
        if sendKeyUp {
            cgEvent(from: event, keyDown: false)?.postToPid(application.processIdentifier)
        }
    }

    // All global send methods delegate to this one.
    private func sendGlobally(event: KeyEvent, sendKeyUp: Bool) {
        cgEvent(from: event, keyDown: true)?.post(tap: .cghidEventTap)
        if sendKeyUp {
            cgEvent(from: event, keyDown: false)?.post(tap: .cghidEventTap)
        }
    }
}

// MARK: - Main Methods

extension KeySender {
    /// Sends this instance's events to the given running application.
    ///
    /// - Parameter application: An instance of `NSRunningApplication` that will receive
    ///   the event.
    public func send(to application: NSRunningApplication, sendKeyUp: Bool = true) {
        for event in events {
            sendLocally(event: event, application: application, sendKeyUp: sendKeyUp)
        }
    }

    /// Sends this instance's events to the application with the given name.
    ///
    /// - Parameter application: The name of the application that will receive the event.
    public func send(to application: String, sendKeyUp: Bool = true) throws {
        try send(to: target(from: application), sendKeyUp: sendKeyUp)
    }

    /// Attempts to send this instance's events to the application with the given name,
    /// printing an error to the console if the operation fails.
    ///
    /// - Parameter application: The name of the application that will receive the event.
    public func trySend(to application: String, sendKeyUp: Bool = true) {
        do {
            try send(to: application, sendKeyUp: sendKeyUp)
        } catch {
            print(error.localizedDescription)
        }
    }

    /// Sends this instance's events globally, making the events visible to the system,
    /// rather than a single application.
    public func sendGlobally(sendKeyUp: Bool = true) {
        for event in events {
            sendGlobally(event: event, sendKeyUp: sendKeyUp)
        }
    }

    /// Sends this instance's events to the application that has focus in the shared
    /// workspace.
    public func sendToFrontmostApplication(sendKeyUp: Bool = true) throws {
        guard let application = NSWorkspace.shared.frontmostApplication else {
            throw KeySenderError("No frontmost application exists.")
        }
        send(to: application)
    }

    /// Sends this instance's events to every running application.
    public func sendToAllApplications(sendKeyUp: Bool = true) {
        for application in NSWorkspace.shared.runningApplications {
            send(to: application, sendKeyUp: sendKeyUp)
        }
    }

    /// Sends this instance's events to every running application that matches the
    /// given predicate.
    public func send(where predicate: (NSRunningApplication) throws -> Bool) rethrows {
        for application in NSWorkspace.shared.runningApplications where try predicate(application) {
            send(to: application)
        }
    }

    /// Opens the given application (if it is not already open), and sends this
    /// instance's events.
    public func openApplicationAndSend(_ application: String) throws {
        if let application = NSWorkspace.shared.runningApplications.first(where: {
            $0.localizedName?.lowercased() == application.lowercased()
        }) {
            send(to: application)
        } else {
            let process = Process()
            process.arguments = ["-a", application]
            if #available(macOS 10.13, *) {
                process.executableURL = URL(fileURLWithPath: "/usr/bin/open")
                try process.run()
            } else {
                process.launchPath = "/usr/bin/open"
                process.launch()
            }
            process.waitUntilExit()
            try openApplicationAndSend(application)
        }
    }
}
