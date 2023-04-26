//
// KeyEvent.swift
// KeySender
//

import Cocoa

/// A key event that can be sent by a key sender.
public class KeyEvent {

    // MARK: Properties

    /// The value at the root of this event.
    private var root: KeyEventRoot

    /// The key associated with this key event.
    public var key: Key {
        root.key
    }

    /// The modifier keys associated with this key event.
    public var modifiers: Modifiers {
        root.modifiers
    }

    /// The kind of this key event.
    public var kind: EventKind {
        root.kind
    }

    /// The Core Graphics event corresponding to this key event.
    public var cgEvent: CGEvent? {
        root.getCGEvent()
    }

    /// The Cocoa event corresponding to this key event.
    public var nsEvent: NSEvent? {
        root.getNSEvent()
    }

    // MARK: Initializers

    /// Creates a key event with the given key, modifiers, and event kind.
    public init(key: Key, modifiers: Modifiers, kind: EventKind) {
        root = .storage(key, modifiers, kind)
    }

    /// Creates a key event from the given Core Graphics event.
    public convenience init?(cgEvent: CGEvent) {
        guard let root = KeyEventRoot(cgEvent) else {
            return nil
        }
        self.init(key: root.key, modifiers: root.modifiers, kind: root.kind)
        self.root = root
    }

    /// Creates a key event from the given Cocoa event.
    public convenience init?(nsEvent: NSEvent) {
        guard let root = KeyEventRoot(nsEvent) else {
            return nil
        }
        self.init(key: root.key, modifiers: root.modifiers, kind: root.kind)
        self.root = root
    }
}

// MARK: KeyEvent: Equatable
extension KeyEvent: Equatable {
    public static func == (lhs: KeyEvent, rhs: KeyEvent) -> Bool {
        lhs.root == rhs.root
    }
}

// MARK: KeyEvent: Hashable
extension KeyEvent: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(root)
    }
}
