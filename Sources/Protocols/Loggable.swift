//  Loggable.swift

import Foundation

/// Represents the type/level of a log message.
/// Used to categorize log entries and control log output.
public enum LogType: String {
    /// Used for development and debugging messages.
    case debug

    /// Indicates a warning, something unexpected but not necessarily an error.
    case warning

    /// Provides very detailed or high-volume log messages, often useful for tracing.
    case verbose

    /// Used for errors, indicating failures or issues needing attention.
    case error

    /// Informational messages about normal app operation.
    case info

    /// Contains sensitive data.
    /// Note: Log messages of this type will **not be printed to file** for security reasons.
    case sensitive

    /// Sensitive data has been sanitized.
    /// Note: Log messages of this type will **not be sent to Logstash**.
    case sanitized
}

public protocol Loggable {
    var type: LogType { get }
    var message: String { get }
    var error: NSError? { get }
    var customData: [String: Any]? { get set }
    var file: String { get }
    var function: String { get }
    var line: UInt { get }
}
