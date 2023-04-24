//
// KeyEvent.swift
// KeySender
//

import Cocoa

/// A representation of a key event that can be sent by an
/// instance of ``KeySender/KeySender``.
public struct KeyEvent {

    // MARK: Properties

    /// The key associated with this key event.
    public let key: Key

    /// The modifier keys associated with this key event.
    public let modifiers: Modifiers

    /// The kind of this key event.
    public let kind: EventKind

    // MARK: Initializers

    /// Creates a key event with the given key, modifiers, and event kind.
    public init(key: Key, modifiers: Modifiers = [], kind: EventKind) {
        self.key = key
        self.modifiers = modifiers
        self.kind = kind
    }

    /// Creates a key event from the given Core Graphics event.
    public init?(cgEvent: CGEvent) {
        guard
            let key = Key(rawValue: Int(cgEvent.getIntegerValueField(.keyboardEventKeycode))),
            let kind = EventKind(cgEventType: cgEvent.type)
        else {
            return nil
        }
        let modifiers = Modifiers(flags: cgEvent.flags)
        self.init(key: key, modifiers: modifiers, kind: kind)
    }

    /// Creates a key event from the given Cocoa event.
    public init?(nsEvent: NSEvent) {
        guard let cgEvent = nsEvent.cgEvent else {
            return nil
        }
        self.init(cgEvent: cgEvent)
    }
}

extension KeyEvent {
    /// The Core Graphics event corresponding to this key event.
    public var cgEvent: CGEvent? {
        let event = CGEvent(
            keyboardEventSource: CGEventSource(stateID: .hidSystemState),
            virtualKey: CGKeyCode(key.rawValue),
            keyDown: kind == .keyDown
        )
        event?.flags = modifiers.flags
        return event
    }

    /// The Cocoa event corresponding to this key event.
    public var nsEvent: NSEvent? {
        cgEvent.flatMap { NSEvent(cgEvent: $0) }
    }
}

// MARK: KeyEvent: Codable
extension KeyEvent: Codable { }

// MARK: KeyEvent: Equatable
extension KeyEvent: Equatable { }

// MARK: KeyEvent: Hashable
extension KeyEvent: Hashable { }
