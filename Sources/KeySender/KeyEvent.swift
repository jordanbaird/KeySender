//
// KeyEvent.swift
// KeySender
//

import Cocoa

/// A key event that can be sent by a key sender.
public class KeyEvent: Codable {

    // MARK: Properties

    private var cgEventConstructor = Constructor.nilConstructor(for: CGEvent.self)
    private var nsEventConstructor = Constructor.nilConstructor(for: NSEvent.self)

    private lazy var _cgEvent: CGEvent? = {
        if let cgEvent = cgEventConstructor.take() {
            return cgEvent
        }
        let cgEvent = CGEvent(
            keyboardEventSource: CGEventSource(stateID: .hidSystemState),
            virtualKey: CGKeyCode(key.rawValue),
            keyDown: kind == .keyDown
        )
        cgEvent?.flags = modifiers.flags
        return cgEvent
    }()

    private lazy var _nsEvent: NSEvent? = {
        if let nsEvent = nsEventConstructor.take() {
            return nsEvent
        }
        guard let _cgEvent else {
            return nil
        }
        return NSEvent(cgEvent: _cgEvent)
    }()

    /// The key associated with this key event.
    public let key: Key

    /// The modifier keys associated with this key event.
    public let modifiers: Modifiers

    /// The kind of this key event.
    public let kind: EventKind

    /// The Core Graphics event corresponding to this key event.
    public var cgEvent: CGEvent? { _cgEvent }

    /// The Cocoa event corresponding to this key event.
    public var nsEvent: NSEvent? { _nsEvent }

    // MARK: Initializers

    /// Creates a key event with the given key, modifiers, and event kind.
    public init(key: Key, modifiers: Modifiers = [], kind: EventKind) {
        self.key = key
        self.modifiers = modifiers
        self.kind = kind
    }

    /// Creates a key event from the given Core Graphics event.
    public convenience init?(cgEvent: CGEvent) {
        guard
            let key = Key(rawValue: Int(cgEvent.getIntegerValueField(.keyboardEventKeycode))),
            let kind = EventKind(cgEventType: cgEvent.type)
        else {
            return nil
        }
        let modifiers = Modifiers(flags: cgEvent.flags)
        self.init(key: key, modifiers: modifiers, kind: kind)
        self.cgEventConstructor = Constructor(value: cgEvent)
    }

    /// Creates a key event from the given Cocoa event.
    public convenience init?(nsEvent: NSEvent) {
        guard
            let cgEvent = nsEvent.cgEvent,
            let key = Key(rawValue: Int(cgEvent.getIntegerValueField(.keyboardEventKeycode))),
            let kind = EventKind(cgEventType: cgEvent.type)
        else {
            return nil
        }
        let modifiers = Modifiers(flags: cgEvent.flags)
        self.init(key: key, modifiers: modifiers, kind: kind)
        self.cgEventConstructor = Constructor(value: cgEvent)
        self.nsEventConstructor = Constructor(value: nsEvent)
    }
}

// MARK: KeyEvent: Equatable
extension KeyEvent: Equatable {
    public static func == (lhs: KeyEvent, rhs: KeyEvent) -> Bool {
        lhs.key == rhs.key &&
        lhs.modifiers == rhs.modifiers &&
        lhs.kind == rhs.kind
    }
}

// MARK: KeyEvent: Hashable
extension KeyEvent: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(key)
        hasher.combine(modifiers)
        hasher.combine(kind)
    }
}
