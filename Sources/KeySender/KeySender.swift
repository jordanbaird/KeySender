//
// KeySender.swift
// KeySender
//

import Cocoa

/// A type that sends key events to the system or any running application.
///
/// To create a key sender, call one of its initializers. You can create an
/// instance with multiple key events that will be sent in succession, or
/// provide a string that will automatically be converted into key-press events.
/// You then call one of the available key-sending methods to send the events
/// to the global event stream, or to a specific application.
///
/// ```swift
/// // Copies selected text from the "TextEdit" application:
/// let sender1 = KeySender(events: [
///     KeyEvent(key: .c, modifiers: .command, kind: .keyPress)
/// ])
/// try sender1.sendToApplication(named: "TextEdit")
///
/// // Pastes the copied text using the global event stream:
/// let sender2 = KeySender(events: [
///     KeyEvent(key: .v, modifiers: .command, kind: .keyPress)
/// ])
/// try sender2.sendGlobally()
///
/// // Types "Hello, world!" into the "TextEdit" application:
/// let sender3 = KeySender(string: "Hello, world!")
/// try sender3.sendToApplication(named: "TextEdit")
/// ```
///
/// As long as the receiver can accept the keys that you send, the effect will
/// be the same as if the keys had been entered manually.
public class KeySender {

    // MARK: Properties

    /// The key events that are sent by this key sender.
    public var events: [KeyEvent]

    // MARK: Initializers

    /// Creates a key sender for the given key events.
    ///
    /// - Parameter events: The key events that are sent by the returned key sender.
    public init(events: [KeyEvent]) {
        self.events = events
    }

    /// Creates a key sender for the given string.
    ///
    /// The returned key sender contains a key-press event for every valid
    /// character in the string. If the key combination needed to type a character
    /// cannot be determined, the character will be skipped. Valid characters are
    /// those that can be typed without the use of additional modifiers and those
    /// that can be typed while holding down a combination of the Shift and Option
    /// modifiers. To send a character that requires the use of some other key
    /// combination, use ``init(events:)`` to create a key sender from an array of
    /// manually constructed events.
    ///
    /// - Note: Many Unicode characters, such as emojis and symbols, cannot be typed
    ///   using a standard keyboard layout. Character availability may also depend on
    ///   the locale of individual keyboards and systems.
    ///
    /// - Parameter string: A string used to create the returned key sender's events.
    ///
    /// - Returns: A key sender containing a key-press event for every valid character
    ///   in `string`.
    public convenience init(string: String) {
        let validModifiers: [KeyEvent.Modifiers] = [[], .shift, .option, [.shift, .option]]
        self.init(events: string.compactMap { character in
            for modifiers in validModifiers {
                if let key = KeyEvent.Key(character, modifiers: modifiers) {
                    return KeyEvent(key: key, modifiers: modifiers, kind: .keyPress)
                }
            }
            return nil
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
            for converted in event.convertToSimpleEvents() {
                guard let cgEvent = converted.makeCGEvent() else {
                    throw KeySenderError.couldNotCreate(converted)
                }
                cgEvent.postToPid(application.processIdentifier)
            }
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
            for converted in event.convertToSimpleEvents() {
                guard let cgEvent = converted.makeCGEvent() else {
                    throw KeySenderError.couldNotCreate(converted)
                }
                cgEvent.post(tap: .cghidEventTap)
            }
        }
    }
}
