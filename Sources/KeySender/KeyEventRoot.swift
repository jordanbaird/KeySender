//
// KeyEventRoot.swift
// KeySender
//

import Cocoa

// MARK: - KeyEventRoot

/// A type that stores the underlying value of a key event.
indirect enum KeyEventRoot {
    /// A value that stores a Core Graphics event alongside a second
    /// value that stores the fundamental components of a key event.
    case cgEvent(CGEvent, Self)

    /// A value that stores a Cocoa event alongside a second value
    /// that stores the fundamental components of a key event.
    case nsEvent(NSEvent, Self)

    /// A value that stores the fundamental components of a key event.
    case storage(KeyEvent.Key, KeyEvent.Modifiers, KeyEvent.EventKind)

    init?(_ object: AnyObject) {
        func root(object: AnyObject, shallow: Bool) -> Self? {
            if
                let nsEvent = object as? NSEvent,
                let cgEvent = nsEvent.cgEvent
            {
                guard let root = root(object: cgEvent, shallow: true) else {
                    return nil
                }
                return .nsEvent(nsEvent, root.getStorage())
            }
            if
                CFGetTypeID(object) == CGEvent.typeID,
                let cgEvent = object as! CGEvent?,
                let key = KeyEvent.Key(rawValue: Int(cgEvent.getIntegerValueField(.keyboardEventKeycode))),
                let kind = KeyEvent.EventKind(cgEventType: cgEvent.type)
            {
                let modifiers = KeyEvent.Modifiers(flags: cgEvent.flags)
                let storage = Self.storage(key, modifiers, kind)
                if
                    !shallow,
                    let nsEvent = NSEvent(cgEvent: cgEvent)
                {
                    return .nsEvent(nsEvent, storage)
                }
                return .cgEvent(cgEvent, storage)
            }
            return nil
        }

        guard let root = root(object: object, shallow: false) else {
            return nil
        }
        self = root
    }
}

// MARK: Properties
extension KeyEventRoot {
    /// The key associated with this value.
    var key: KeyEvent.Key {
        switch self {
        case .cgEvent(_, let storage), .nsEvent(_, let storage):
            return storage.key
        case .storage(let key, _, _):
            return key
        }
    }

    /// The modifier keys associated with this value.
    var modifiers: KeyEvent.Modifiers {
        switch self {
        case .cgEvent(_, let storage), .nsEvent(_, let storage):
            return storage.modifiers
        case .storage(_, let modifiers, _):
            return modifiers
        }
    }

    /// The event kind associated with this value.
    var kind: KeyEvent.EventKind {
        switch self {
        case .cgEvent(_, let storage), .nsEvent(_, let storage):
            return storage.kind
        case .storage(_, _, let kind):
            return kind
        }
    }
}

// MARK: Instance Methods
extension KeyEventRoot {
    /// Retrieves the value that stores the fundamental components
    /// needed to construct a key event from this value.
    func getStorage() -> Self {
        switch self {
        case .cgEvent(_, let storage), .nsEvent(_, let storage):
            return storage
        case .storage:
            return self
        }
    }

    /// Returns a Core Graphics event from this value.
    ///
    /// If no underlying Core Graphics event is currently stored, one
    /// will be created, and this value will be mutated to store it.
    mutating func getCGEvent() -> CGEvent? {
        switch self {
        case .cgEvent(let cgEvent, _):
            return cgEvent
        case .nsEvent(let nsEvent, _):
            return nsEvent.cgEvent
        case .storage(let key, let modifiers, let kind):
            guard let cgEvent = CGEvent(
                keyboardEventSource: CGEventSource(stateID: .hidSystemState),
                virtualKey: CGKeyCode(key.rawValue),
                keyDown: kind == .keyDown
            ) else {
                return nil
            }
            cgEvent.flags = modifiers.flags
            self = .cgEvent(cgEvent, getStorage())
            return cgEvent
        }
    }

    /// Returns a Cocoa event from this value.
    ///
    /// If no underlying Cocoa event is currently stored, one will
    /// be created, and this value will be mutated to store it.
    mutating func getNSEvent() -> NSEvent? {
        switch self {
        case .cgEvent(let cgEvent, _):
            guard let nsEvent = NSEvent(cgEvent: cgEvent) else {
                return nil
            }
            self = .nsEvent(nsEvent, getStorage())
            return nsEvent
        case .nsEvent(let nsEvent, _):
            return nsEvent
        case .storage:
            _ = getCGEvent()    // mutates self to .cgEvent if successful
            if case .storage = self {
                return nil
            }
            return getNSEvent() // mutates self to .nsEvent if successful
        }
    }
}

// MARK: KeyEventRoot: Equatable
extension KeyEventRoot: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.key == rhs.key &&
        lhs.modifiers == rhs.modifiers &&
        lhs.kind == rhs.kind
    }
}

// MARK: KeyEventRoot: Hashable
extension KeyEventRoot: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(key)
        hasher.combine(modifiers)
        hasher.combine(kind)
    }
}
