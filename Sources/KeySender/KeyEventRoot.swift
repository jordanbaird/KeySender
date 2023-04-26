//
// KeyEventRoot.swift
// KeySender
//

import Cocoa

// MARK: - KeyEventRoot

enum KeyEventRoot {
    case cgEvent(CGEvent, Storage)
    case nsEvent(NSEvent, Storage)
    case storage(Storage)
}

// MARK: Properties
extension KeyEventRoot {
    var storage: Storage {
        switch self {
        case .cgEvent(_, let storage), .nsEvent(_, let storage), .storage(let storage):
            return storage
        }
    }

    var key: KeyEvent.Key {
        storage.key
    }

    var modifiers: KeyEvent.Modifiers {
        storage.modifiers
    }

    var kind: KeyEvent.EventKind {
        storage.kind
    }
}

// MARK: Instance Methods
extension KeyEventRoot {
    mutating func getCGEvent() -> CGEvent? {
        switch self {
        case .cgEvent(let cgEvent, _):
            return cgEvent
        case .nsEvent(let nsEvent, _):
            return nsEvent.cgEvent
        case .storage(let storage):
            guard let cgEvent = CGEvent(
                keyboardEventSource: CGEventSource(stateID: .hidSystemState),
                virtualKey: CGKeyCode(storage.key.rawValue),
                keyDown: storage.kind == .keyDown
            ) else {
                return nil
            }
            cgEvent.flags = storage.modifiers.flags
            self = .cgEvent(cgEvent, storage)
            return cgEvent
        }
    }

    mutating func getNSEvent() -> NSEvent? {
        switch self {
        case .cgEvent(let cgEvent, let storage):
            guard let nsEvent = NSEvent(cgEvent: cgEvent) else {
                return nil
            }
            self = .nsEvent(nsEvent, storage)
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
        lhs.storage == rhs.storage
    }
}

// MARK: KeyEventRoot: Hashable
extension KeyEventRoot: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(storage)
    }
}

// MARK: KeyEventRoot.Storage
extension KeyEventRoot {
    struct Storage: Hashable {
        let key: KeyEvent.Key
        let modifiers: KeyEvent.Modifiers
        let kind: KeyEvent.EventKind
    }
}
