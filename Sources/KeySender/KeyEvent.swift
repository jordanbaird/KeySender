//
// KeyEvent.swift
// KeySender
//

/// A representation of a key event that can be sent by an
/// instance of ``KeySender/KeySender``.
public struct KeyEvent {

    // MARK: Properties

    /// The key associated with this key event.
    public let key: Key

    /// The modifier keys associated with this key event.
    public let modifiers: Modifiers

    // MARK: Initializers

    /// Creates a key event with the given keys and modifiers.
    public init(key: Key, modifiers: Modifiers = []) {
        self.key = key
        self.modifiers = modifiers
    }
}

// MARK: KeyEvent: Codable
extension KeyEvent: Codable { }

// MARK: KeyEvent: Equatable
extension KeyEvent: Equatable { }

// MARK: KeyEvent: Hashable
extension KeyEvent: Hashable { }
