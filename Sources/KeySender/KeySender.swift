//
// KeySender.swift
// KeySender
//

import Cocoa

/// A type that sends key events to the system or any running application.
///
/// To create a key sender, call one of its initializers. You can create
/// an instance with multiple key events that will be sent in succession,
/// a single key event, a key and some modifiers, or a string. You then
/// call one of the key-sending methods to either send the event globally,
/// or to a specified running application.
///
/// As long as the receiver can accept the keys that you send, the effect
/// will be the same as if the keys had been entered manually.
///
/// ```swift
/// // Copies selected text in the "TextEdit" application:
/// let sender1 = KeySender(key: .c, modifiers: .command)
/// try sender1.sendTo(applicationNamed: "TextEdit")
///
/// // Types "Hello" into the "TextEdit" application:
/// let sender2 = KeySender(string: "Hello")
/// try sender2.sendTo(applicationNamed: "TextEdit")
/// ```
///
/// - Note: If you send the events to an application, it must currently
///   be running, or sending the events will fail.
public class KeySender {

    // MARK: Properties

    /// The key events that are sent by this key sender.
    public let events: [KeyEvent]

    // MARK: Initializers

    /// Creates a key sender for the given key events.
    ///
    /// - Parameter events: The key events that are sent by the created key sender.
    public init(events: [KeyEvent]) {
        self.events = events
    }

    /// Creates a key sender for the given key event.
    ///
    /// - Parameter event: The key event that is sent by the created key sender.
    public convenience init(event: KeyEvent) {
        self.init(events: [event])
    }

    /// Creates a key sender for a key event created by the given key
    /// and modifiers.
    ///
    /// - Parameters:
    ///   - key: A key used to create the key sender's event.
    ///   - modifiers: The modifier keys used to create the key sender's event.
    public convenience init(key: KeyEvent.Key, modifiers: KeyEvent.Modifiers) {
        self.init(event: KeyEvent(key: key, modifiers: modifiers))
    }

    /// Creates a key sender for the given string.
    ///
    /// If the key combination needed to type a character cannot be determined,
    /// the character will be skipped. Valid characters are those that can be
    /// typed without the use of additional modifiers, and those that can be
    /// typed while holding down Shift and/or Option. To send a character that
    /// requires the use of some other key combination, use one of this type's
    /// other initializers to construct a key event manually.
    ///
    /// - Note: Some Unicode characters, such as emojis and symbols, cannot be
    ///   typed using a standard keyboard layout. Character availability may
    ///   also depend on the locale of individual keyboards and systems.
    ///
    /// - Parameter string: A string used to create the key sender's events.
    public convenience init(string: String) {
        let validCombinations: [KeyEvent.Modifiers] = [[], .shift, .option, [.shift, .option]]
        self.init(events: string.compactMap { character in
            for combination in validCombinations {
                if let key = KeyEvent.Key(character, modifiers: combination) {
                    return KeyEvent(key: key, modifiers: combination)
                }
            }
            return nil
        })
    }
}

// MARK: Helpers
extension KeySender {
    // Tries to return a CGEvent from a KeyEvent.
    private func cgEvent(from keyEvent: KeyEvent, keyDown: Bool) throws -> CGEvent {
        let event = CGEvent(
            keyboardEventSource: CGEventSource(stateID: .hidSystemState),
            virtualKey: CGKeyCode(keyEvent.key.rawValue),
            keyDown: keyDown
        )
        guard let event else {
            throw KeySenderError.couldNotCreate(keyEvent)
        }
        event.flags = keyEvent.modifiers.flags
        return event
    }
}

// MARK: Sending Methods
extension KeySender {
    /// Sends this instance's events to the given running application.
    ///
    /// - Parameters:
    ///   - application: An instance of `NSRunningApplication` that will receive the event.
    ///   - sendKeyUp: A Boolean value that indicates whether a corresponding key-up event
    ///     will be sent with each key-down event. Default is `true`.
    public func sendTo(runningApplication application: NSRunningApplication, sendKeyUp: Bool = true) throws {
        for event in events {
            try cgEvent(from: event, keyDown: true).postToPid(application.processIdentifier)
            if sendKeyUp {
                try cgEvent(from: event, keyDown: false).postToPid(application.processIdentifier)
            }
        }
    }

    /// Sends this instance's events to the application with the given localized name.
    ///
    /// - Parameters:
    ///   - localizedName: The localized name of the application that will receive the event.
    ///   - sendKeyUp: A Boolean value that indicates whether a corresponding key-up event
    ///     will be sent with each key-down event. Default is `true`.
    public func sendTo(applicationNamed localizedName: String, sendKeyUp: Bool = true) throws {
        guard let application = NSWorkspace.shared.runningApplications.first(where: {
            $0.localizedName == localizedName
        }) else {
            throw KeySenderError.applicationNotRunning(localizedName)
        }
        try sendTo(runningApplication: application, sendKeyUp: sendKeyUp)
    }

    /// Sends this instance's events globally, making the events visible to the system, rather
    /// than a single application.
    ///
    /// - Parameter sendKeyUp: A Boolean value that indicates whether a corresponding key-up
    ///   event will be sent with each key-down event. Default is `true`.
    public func sendGlobally(sendKeyUp: Bool = true) throws {
        for event in events {
            try cgEvent(from: event, keyDown: true).post(tap: .cghidEventTap)
            if sendKeyUp {
                try cgEvent(from: event, keyDown: false).post(tap: .cghidEventTap)
            }
        }
    }
}
