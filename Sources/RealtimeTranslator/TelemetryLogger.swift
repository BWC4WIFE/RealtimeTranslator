import Foundation
import os

/// Lightweight per-event wall-clock timer; thread-safe.
final class TelemetryLogger: Sendable {

    private let log = Logger(subsystem: "com.realtimetranslator", category: "telemetry")
    private let lock = OSAllocatedUnfairLock(initialState: [String: Date]())

    func start(_ event: String) {
        lock.withLock { $0[event] = Date() }
    }

    func end(_ event: String, engine: String) {
        let elapsed = lock.withLock { dict -> TimeInterval? in
            guard let t = dict.removeValue(forKey: event) else { return nil }
            return Date().timeIntervalSince(t)
        }
        guard let ms = elapsed else { return }
        log.info("[\(engine, privacy: .public)] \(event, privacy: .public): \(Int(ms * 1000), privacy: .public)ms")
    }
}