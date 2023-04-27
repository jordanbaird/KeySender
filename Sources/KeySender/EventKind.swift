//
// EventKind.swift
// KeySender
//

import CoreGraphics

extension KeyEvent {
    /// Constants that specify the kind of a key event.
    public enum EventKind {
        /// The key is not being pressed.
        case keyUp

        /// The key is being pressed.
        case keyDown
    }
}

extension KeyEvent.EventKind {
    /// Creates an event kind for the given Core Graphics event type.
    ///
    /// The provided event type must be either `.keyUp` or `.keyDown`,
    /// or this initializer will return `nil`.
    init?(cgEventType: CGEventType) {
        switch cgEventType {
        case .keyUp:
            self = .keyUp
        case .keyDown:
            self = .keyDown
        default:
            return nil
        }
    }
}

// MARK: EventKind: Codable
extension KeyEvent.EventKind: Codable { }

// MARK: EventKind: Equatable
extension KeyEvent.EventKind: Equatable { }

// MARK: EventKind: Hashable
extension KeyEvent.EventKind: Hashable { }
