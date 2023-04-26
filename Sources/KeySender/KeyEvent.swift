//
// KeyEvent.swift
// KeySender
//

import CoreGraphics

/// A key event that can be sent by a key sender.
public struct KeyEvent {

    // MARK: Properties

    /// The key associated with this key event.
    public let key: Key

    /// The modifier keys associated with this key event.
    public let modifiers: Modifiers

    /// The event kind of this key event.
    public let kind: EventKind

    // MARK: Initializers

    /// Creates a key event with the given key, modifiers, and event kind.
    public init(key: Key, modifiers: Modifiers, kind: EventKind) {
        self.key = key
        self.modifiers = modifiers
        self.kind = kind
    }

    // MARK: Instance Methods

    /// Creates and returns a Core Graphics event with the same key,
    /// modifiers, and event kind as this key event.
    func makeCGEvent() -> CGEvent? {
        let cgEvent = CGEvent(
            keyboardEventSource: CGEventSource(stateID: .hidSystemState),
            virtualKey: key.virtualKey,
            keyDown: kind == .keyDown
        )
        cgEvent?.flags = modifiers.flags
        return cgEvent
    }
}

// MARK: KeyEvent: Codable
extension KeyEvent: Codable { }

// MARK: KeyEvent: Equatable
extension KeyEvent: Equatable { }

// MARK: KeyEvent: Hashable
extension KeyEvent: Hashable { }
