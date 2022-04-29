# KeySender

![Swift](https://img.shields.io/badge/Swift-5.5%2B-orange)
![Release](https://img.shields.io/github/v/release/jordanbaird/KeySender)
![Workflow](https://img.shields.io/github/workflow/status/jordanbaird/KeySender/Swift)
[![License](https://img.shields.io/github/license/jordanbaird/KeySender)](https://github.com/jordanbaird/KeySender/blob/main/LICENSE)

An extremely simple micro package that enables you to send key events to any 
running application.

## Install

Add the following to your `Package.swift` file:

```swift
import PackageDescription

let package = Package(
    name: "PackageName",
    dependencies: [
        .package(url: "https://github.com/jordanbaird/KeySender", from: "0.0.5")
    ],
    targets: [
        .target(
            name: "PackageName",
            dependencies: ["KeySender"]
        )
    ]
)
```

## Usage

To create a key sender, call one of its initializers. You can create an instance with multiple 
key events that will be sent in succession, a single key event, a key and some modifiers, or a 
string. You then call one of the `send(to:)` or `trySend(to:)` methods to send the event to a 
running application of your choice, or  `sendGlobally()` to send the event to the system.

When sending to an application, as long as it can accept the keys that you send and is currently 
running, the effect will be the same as if the keys had been entered manually.

When sending globally, the effect will also be the same as if the keys had been entered manually.
```swift
let sender = KeySender(key: .c, modifiers: .command)
try sender.send(to: "TextEdit")

let sender = KeySender(string: "Hello")
sender.trySend(to: "TextEdit")

let sender = KeySender(key: .space, modifiers: .command)
sender.sendGlobally()
```
> Note: As KeySender is under active development, source stability is not guaranteed between releases.
