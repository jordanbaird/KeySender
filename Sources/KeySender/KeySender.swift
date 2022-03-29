//===----------------------------------------------------------------------===//
//
// KeySender.swift
//
// Created: 2022. Author: Jordan Baird.
//
//===----------------------------------------------------------------------===//

import Cocoa

/// A type that can send key events to any running application.
///
/// To create a key sender, call one of its initializers. You can create an
/// instance with multiple key events that will be sent in succession, a single
/// key event, a key and some modifiers, or a string. You then call one of the
/// `send(to:)`, `trySend(to:)`, or `sendGlobally()` methods to send the event
/// to a running application of your choice.
///
/// As long as that application can accept the keys that you send, the effect
/// will be the same as if the keys had been entered manually.
///
/// ```swift
/// let sender = KeySender(key: .c, modifiers: .command)
/// try sender.send(to: "TextEdit")
///
/// let stringSender = KeySender(string: "Hello")
/// stringSender.trySend(to: "TextEdit")
/// ```
///
/// - Note: The application you send the key events to must currently be running,
/// or sending the events will fail.
public struct KeySender {
  /// The events that will be sent by this key sender.
  public let events: [KeyEvent]
  
  /// Creates a sender for the given key events.
  public init(for events: [KeyEvent]) {
    self.events = events
  }
  
  /// Creates a sender for the given key events.
  public init(for events: KeyEvent...) {
    self.events = events
  }
  
  /// Creates a sender for the given key event.
  public init(for event: KeyEvent) {
    self.events = [event]
  }
  
  /// Creates a sender for the given key and modifiers.
  ///
  /// This initializer works by creating a `KeyEvent` behind the scenes, then adding
  /// it to the instance's `events` property.
  public init(key: KeyEvent.Key, modifiers: [KeyEvent.Modifier]) {
    self.init(for: .init(key: key, modifiers: modifiers))
  }
  
  /// Creates a sender for the given key and modifiers.
  ///
  /// This initializer works by creating a `KeyEvent` behind the scenes, then adding
  /// it to the instance's `events` property.
  public init(key: KeyEvent.Key, modifiers: KeyEvent.Modifier...) {
    self.init(for: .init(key: key, modifiers: modifiers))
  }
  
  /// Creates a key sender for the given string.
  ///
  /// This initializer throws an error if the string contains an invalid character.
  /// Valid characters are those that appear on the keyboard, and that can be typed
  /// without the use of any modifiers. The exception is capital letters, which are
  /// valid. However, any character that requires a modifier key to be pressed, such
  /// as Shift-1 (for "!"), are invalid characters. To send one of these characters,
  /// use one of the other initializers to construct a key event using the key and
  /// modifiers necessary to type the character.
  public init(for string: String) throws {
    var events = [KeyEvent]()
    for character in string {
      guard let key = KeyEvent.Key("\(character)") else {
        throw KeySenderError("Invalid character. Cannot create key event.")
      }
      var event: KeyEvent
      if character.isUppercase {
        event = .init(key: key, modifiers: [.shift])
      } else {
        event = .init(key: key, modifiers: [])
      }
      events.append(event)
    }
    self.events = events
  }
}

// MARK: - Helper Methods

extension KeySender {
  // Tries to convert a string into an NSRunningApplication.
  private func getTarget(from string: String) throws -> NSRunningApplication {
    let target = NSWorkspace.shared.runningApplications.first(where: {
      $0.localizedName == string
    })
    guard let target = target else {
      throw KeySenderError(
        """
        Application with name "\(string)" either does not exist, \
        or is not currently running.
        """
      )
    }
    return target
  }
  
  private func createEvent(from keyEvent: KeyEvent) -> CGEvent? {
    // Create the event.
    let postableEvent = CGEvent(
      keyboardEventSource: .init(stateID: .hidSystemState),
      virtualKey: CGKeyCode(keyEvent.key.rawValue),
      keyDown: true)
    // Give it the appropriate modifiers flags.
    postableEvent?.flags = KeyEvent.Modifier.flags(for: keyEvent.modifiers)
    return postableEvent
  }
  
  // All other send methods delegate to this one.
  private func send(event: KeyEvent, to application: NSRunningApplication) {
    let postableEvent = createEvent(from: event)
    postableEvent?.postToPid(application.processIdentifier)
  }
  
  private func sendGlobally(event: KeyEvent) {
    let postableEvent = createEvent(from: event)
    postableEvent?.post(tap: .cghidEventTap)
  }
}

// MARK: - Main Methods

extension KeySender {
  /// Sends this instance's events to the given running application.
  /// - Parameter application: An instance of `NSRunningApplication` that will
  /// receive the event.
  public func send(to application: NSRunningApplication) {
    for event in events {
      send(event: event, to: application)
    }
  }
  
  /// Sends this instance's events to the application with the given name.
  /// - Parameter application: The name of the application that will receive the
  /// event.
  public func send(to application: String) throws {
    let target = try getTarget(from: application)
    send(to: target)
  }
  
  /// Attempts to send this instance's events to the application with the given
  /// name, printing an error to the console if the operation fails.
  /// - Parameter application: The name of the application that will receive the
  /// event.
  public func trySend(to application: String) {
    do {
      try send(to: application)
    } catch {
      print(error.localizedDescription)
    }
  }
  
  /// Sends this instance's events globally, making the events visible to the
  /// system, rather than a single application.
  public func sendGlobally() {
    for event in events {
      sendGlobally(event: event)
    }
  }
}
