//
// KeyEvent.swift
// KeySender
//

import Cocoa

/// A key event that can be sent by a key sender.
public class KeyEvent {

    // MARK: Properties

    private lazy var _cgEvent: CGEvent? = {
        let cgEvent = CGEvent(
            keyboardEventSource: CGEventSource(stateID: .hidSystemState),
            virtualKey: CGKeyCode(key.rawValue),
            keyDown: kind == .keyDown
        )
        cgEvent?.flags = modifiers.flags
        return cgEvent
    }()

    private lazy var _nsEvent: NSEvent? = {
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
        self._cgEvent = cgEvent
    }

    /// Creates a key event from the given Cocoa event.
    public convenience init?(nsEvent: NSEvent) {
        guard let cgEvent = nsEvent.cgEvent else {
            return nil
        }
        self.init(cgEvent: cgEvent)
        self._nsEvent = nsEvent
    }

    public required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            key: container.decode(Key.self, forKey: .key),
            modifiers: container.decode(Modifiers.self, forKey: .modifiers),
            kind: container.decode(EventKind.self, forKey: .kind)
        )
    }
}

// MARK: KeyEvent: Codable
extension KeyEvent: Codable {
    private enum CodingKeys: CodingKey {
        case key
        case modifiers
        case kind
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(key, forKey: .key)
        try container.encode(modifiers, forKey: .modifiers)
        try container.encode(kind, forKey: .kind)
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
