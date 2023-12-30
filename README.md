# KeySender

[![Continuous Integration][ci-badge]](https://github.com/jordanbaird/KeySender/actions/workflows/test.yml)
[![Swift Versions][versions-badge]](https://github.com/jordanbaird/KeySender)
[![Release][release-badge]](https://github.com/jordanbaird/KeySender/releases/latest)
[![License][license-badge]](LICENSE)

A simple micro package that enables you to send key events to any running application.

## Install

Add the following dependency to your `Package.swift` file:

```swift
.package(url: "https://github.com/jordanbaird/KeySender", from: "0.0.5")
```

## Usage

Create a key sender using one of several initializers. You can create an instance with multiple key events that will be sent in succession, a single key event, a key and some modifiers, or a string. You then call one of the `send(to:)` or `trySend(to:)` methods to send the event to a running application of your choice, or `sendGlobally()` to send the event to the system.

When sending to an application, as long as it can accept the keys that you send and is currently running, the effect will be the same as if the keys had been entered manually.

When sending globally, the effect will also be the same as if the keys had been entered manually.

```swift
let sender = KeySender(key: .c, modifiers: .command)
try sender.send(to: "TextEdit")

let sender = KeySender(string: "Hello")
sender.trySend(to: "TextEdit")

let sender = KeySender(key: .space, modifiers: .command)
sender.sendGlobally()
```

## Source Stability

As KeySender is under active development, source stability is not guaranteed between releases.

## License

KeySender is available under the [MIT license](LICENSE).

[ci-badge]: https://img.shields.io/github/actions/workflow/status/jordanbaird/KeySender/test.yml?branch=main&style=flat-square
[release-badge]: https://img.shields.io/github/v/release/jordanbaird/KeySender?style=flat-square
[versions-badge]: https://img.shields.io/badge/Swift-5.9%2B-F05138?style=flat-square
[license-badge]: https://img.shields.io/github/license/jordanbaird/KeySender?style=flat-square
