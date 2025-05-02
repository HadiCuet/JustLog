//
//  LogstashFileDestination.swift
//  JustLog
//
//  Created by Abdullah Al Hadi on 1/5/25.
//
import Foundation

public class LogstashFileDestination {
    private let semaphore = DispatchSemaphore(value: 1)
    private let fileName = "logstash_to_be_sent.log"

    private var cacheDirectoryURL: URL? {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
    }

    private var logFileURL: URL? {
        return cacheDirectoryURL?.appendingPathComponent(fileName)
    }

    init() {
        if let fileURL = logFileURL, !FileManager.default.fileExists(atPath: fileURL.path) {
            FileManager.default.createFile(atPath: fileURL.path, contents: nil)
        }
    }
    /// Append a single log
    func appendLog(tag: LogTag, content: LogContent) {
        appendLogs([(tag, content)])
    }

    func appendLogsFromDictionary(_ logs: [LogTag: LogContent]) {
        let logsArray = logs.map { (tag, content) in
            return (tag, content)
        }
        appendLogs(logsArray)
    }

    /// Append multiple logs at once
    func appendLogs(_ logs: [(LogTag, LogContent)]) {
        semaphore.wait()
        defer {
            semaphore.signal()
        }

        guard let fileURL = logFileURL else {
            return
        }

        do {
            let fileHandle = try FileHandle(forWritingTo: fileURL)
            defer {
                try? fileHandle.close()
            }

            fileHandle.seekToEndOfFile()

            for (tag, content) in logs {
                let entry = [
                    "tag": tag,
                    "content": content
                ] as [String : Any]

                if let data = try? JSONSerialization.data(withJSONObject: entry),
                   let line = String(data: data, encoding: .utf8) {
                    if let lineData = (line + "\n").data(using: .utf8) {
                        fileHandle.write(lineData)
                    }
                }
            }
        } catch {
            print("Error writing to log file: \(error)")
        }
    }

    /// Read logs and clear file in one atomic operation
    func readAndClearLogs() -> [LogTag: LogContent] {
        semaphore.wait()
        defer {
            semaphore.signal()
        }

        let logs = readLogs()
        clearLogs()

        return logs
    }

    // Private version without locking (for internal use)
    private func readLogs() -> [LogTag: LogContent] {
        guard let fileURL = logFileURL else {
            return [:]
        }
        var logs = [LogTag: LogContent]()

        do {
            let content = try String(contentsOf: fileURL, encoding: .utf8)
            let lines = content.components(separatedBy: .newlines)

            for line in lines where !line.isEmpty {
                if let data = line.data(using: .utf8),
                   let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let tag = json["tag"] as? LogTag,
                   let content = json["content"] as? LogContent {
                    logs[tag] = content
                }
            }
        } catch {
            print("Error reading logs: \(error)")
        }

        return logs
    }

    func clearLogs() {
        guard let fileURL = logFileURL else { return }

        do {
            try "".write(to: fileURL, atomically: true, encoding: .utf8)
        } catch {
            print("Error clearing logs: \(error)")
        }
    }
}
