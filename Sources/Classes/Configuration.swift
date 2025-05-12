//  Configuration.swift

import Foundation

public struct Configuration: Configurable {

    public var logFormat: String
    public var sendingInterval: TimeInterval

    // file
    public var logFolderName: String
    public var logFilename: String
    public var baseUrlForFileLogging: URL?
    public var logFileAmount: Int
    public var fileLogFormat: String

    // logstash
    public var allowUntrustedServer: Bool
    public var logstashHost: String
    public var logstashPort: UInt16
    public var logstashTimeout: TimeInterval
    public var logLogstashSocketActivity: Bool
    public var logzioToken: String?
    public var logstashOverHTTP: Bool

    // destinations
    public var isConsoleLoggingEnabled: Bool
    public var isFileLoggingEnabled: Bool
    public var isLogstashLoggingEnabled: Bool
    public var isCustomLoggingEnabled: Bool

    public init(logFormat: String = "$Dyyyy-MM-dd HH:mm:ss.SSS$d $T $C$L$c: $M",
                sendingInterval: TimeInterval = 5,
                logFolderName: String = "log-folder",
                logFilename: String = "just-app.log",
                baseUrlForFileLogging: URL? = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
                logFileAmount: Int = 1,
                fileLogFormat: String = "$Dyyyy-MM-dd HH:mm:ss.SSS$d $N.$F:$l $C$L$c: $M",
                allowUntrustedServer: Bool = false,
                logstashHost: String = "",
                logstashPort: UInt16 = 9300,
                logstashTimeout: TimeInterval = 20,
                logLogstashSocketActivity: Bool = true,
                logzioToken: String? = nil,
                logstashOverHTTP: Bool = false,
                isConsoleLoggingEnabled: Bool = false,
                isFileLoggingEnabled: Bool = true,
                isLogstashLoggingEnabled: Bool = true,
                isCustomLoggingEnabled: Bool = true) {
        self.logFormat = logFormat
        self.sendingInterval = sendingInterval

        self.logFolderName = logFolderName
        if logFilename.lowercased().hasSuffix(".log") {
            self.logFilename = logFilename
        } else {
            self.logFilename = logFilename + ".log"
        }
        self.baseUrlForFileLogging = baseUrlForFileLogging
        self.logFileAmount = logFileAmount
        self.fileLogFormat = fileLogFormat

        // logstash
        self.allowUntrustedServer = allowUntrustedServer
        self.logstashHost = logstashHost
        self.logstashPort = logstashPort
        self.logstashTimeout = logstashTimeout
        self.logLogstashSocketActivity = logLogstashSocketActivity
        self.logzioToken = logzioToken
        self.logstashOverHTTP = logstashOverHTTP

        // destinations
        self.isConsoleLoggingEnabled = isConsoleLoggingEnabled
        self.isFileLoggingEnabled = isFileLoggingEnabled
        self.isLogstashLoggingEnabled = isLogstashLoggingEnabled
        self.isCustomLoggingEnabled = isCustomLoggingEnabled
    }
}
