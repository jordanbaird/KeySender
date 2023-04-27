//
// EventKind.swift
// KeySender
//

import CoreGraphics

extension KeyEvent {
    /// Constants that specify the kind of a key event.
    public enum EventKind {
        /// A single key-up event.
        case keyUp

        /// A single key-down event.
        case keyDown

        /// A balanced key-press event; that is, a key-down
        /// event followed by a key-up event.
        case keyPress
    }
}

// MARK: EventKind: Codable
extension KeyEvent.EventKind: Codable { }

// MARK: EventKind: Equatable
extension KeyEvent.EventKind: Equatable { }

// MARK: EventKind: Hashable
extension KeyEvent.EventKind: Hashable { }
