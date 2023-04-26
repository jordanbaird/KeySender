//
// Modifiers.swift
// KeySender
//

import Carbon.HIToolbox
import CoreGraphics

extension KeyEvent {
    /// Constants that represent modifier keys associated with a key event.
    public struct Modifiers: OptionSet {

        // MARK: Properties

        public let rawValue: UInt64

        // MARK: Initializers

        public init(rawValue: UInt64) {
            self.rawValue = rawValue
        }

        private init(flags: CGEventFlags) {
            self.init(rawValue: flags.rawValue)
        }

        // MARK: Static Members

        /// The Caps Lock key.
        ///
        /// Device-independent.
        public static let capsLock = Self(flags: .maskAlphaShift)

        /// The Shift key.
        ///
        /// Device-independent.
        public static let shift = Self(flags: .maskShift)

        /// The Control key.
        ///
        /// Device-independent.
        public static let control = Self(flags: .maskControl)

        /// The Option, or Alt key.
        ///
        /// Device-independent.
        public static let option = Self(flags: .maskAlternate)

        /// The Command key.
        ///
        /// Device-independent.
        public static let command = Self(flags: .maskCommand)

        /// A key on the numeric keypad.
        public static let numericPad = Self(flags: .maskNumericPad)

        /// The Help key.
        public static let help = Self(flags: .maskHelp)

        /// The Fn, or Function key.
        public static let function = Self(flags: .maskSecondaryFn)
    }
}

// MARK: Flags
extension KeyEvent.Modifiers {
    /// This instance's equivalent Core Graphics flags.
    var flags: CGEventFlags {
        CGEventFlags(rawValue: rawValue)
    }

    /// This instance's equivalent Carbon flags.
    ///
    /// - Note: Carbon does not define flags for keys on the numeric keypad,
    ///   the Help key, or the Function key. Occurrences of these flags are
    ///   omitted from the result.
    var carbonFlags: Int {
        var result = 0
        if contains(.capsLock) {
            result |= alphaLock
        }
        if contains(.shift) {
            result |= shiftKey
        }
        if contains(.control) {
            result |= controlKey
        }
        if contains(.option) {
            result |= optionKey
        }
        if contains(.command) {
            result |= cmdKey
        }
        return result
    }
}

// MARK: Modifiers: Codable
extension KeyEvent.Modifiers: Codable { }

// MARK: Modifiers: Equatable
extension KeyEvent.Modifiers: Equatable { }

// MARK: Modifiers: Hashable
extension KeyEvent.Modifiers: Hashable { }
