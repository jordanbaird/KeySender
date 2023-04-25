//
// Constructor.swift
// KeySender
//

struct Constructor<Value>: Codable {
    private var body: (() -> Value)?

    private init(nil: ()) {
        self.body = nil
    }

    init(body: @escaping () -> Value) {
        self.body = body
    }

    init(value: @escaping @autoclosure () -> Value) {
        self.init(body: value)
    }

    init(from decoder: Decoder) {
        self.body = nil
    }

    static func nilConstructor(for type: Value.Type = Value.self) -> Self {
        Self(nil: ())
    }

    func encode(to encoder: Encoder) { }

    func call() -> Value? {
        body?()
    }

    mutating func take() -> Value? {
        defer { body = nil }
        return call()
    }
}
