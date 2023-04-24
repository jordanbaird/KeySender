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
/// ```swift
/// // Copies selected text in the "TextEdit" application:
/// let sender1 = KeySender(key: .c, modifiers: .command)
/// try sender1.sendToApplication(named: "TextEdit")
///
/// // Types "Hello" into the "TextEdit" application:
/// let sender2 = KeySender(string: "Hello")
/// try sender2.sendToApplication(named: "TextEdit")
/// ```
///
/// As long as the receiver can accept the keys that you send, the effect
/// will be the same as if the keys had been entered manually.
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

    /// Creates a key sender for a key event created using the given key,
    /// modifiers, and event kind.
    ///
    /// - Parameters:
    ///   - key: A key used to create the key sender's event.
    ///   - modifiers: The modifier keys used to create the key sender's event.
    ///   - kind: The event kind used to create the key sender's event.
    public convenience init(key: KeyEvent.Key, modifiers: KeyEvent.Modifiers = [], kind: KeyEvent.EventKind) {
        self.init(event: KeyEvent(key: key, modifiers: modifiers, kind: kind))
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
        let orderedEventKinds: [KeyEvent.EventKind] = [.keyDown, .keyUp]

        self.init(events: string.flatMap { character in
            for combination in validCombinations {
                if let key = KeyEvent.Key(character, modifiers: combination) {
                    return orderedEventKinds.map { kind in
                        KeyEvent(key: key, modifiers: combination, kind: kind)
                    }
                }
            }
            return []
        })
    }
}

// MARK: Instance Methods
extension KeySender {
    /// Sends this instance's events to the given running application.
    ///
    /// - Parameter application: An instance of `NSRunningApplication` that will receive the event.
    public func sendToApplication(_ application: NSRunningApplication) throws {
        for event in events {
            guard let cgEvent = event.cgEvent else {
                throw KeySenderError.couldNotCreate(event)
            }
            cgEvent.postToPid(application.processIdentifier)
        }
    }

    /// Sends this instance's events to the application with the given localized name.
    ///
    /// - Parameter localizedName: The localized name of the application that will receive the event.
    public func sendToApplication(named localizedName: String) throws {
        guard let application = NSWorkspace.shared.runningApplications.first(where: {
            $0.localizedName == localizedName
        }) else {
            throw KeySenderError.applicationNotRunning(localizedName)
        }
        try sendToApplication(application)
    }

    /// Sends this instance's events to the global event stream.
    public func sendGlobally() throws {
        for event in events {
            guard let cgEvent = event.cgEvent else {
                throw KeySenderError.couldNotCreate(event)
            }
            cgEvent.post(tap: .cghidEventTap)
        }
    }
}
