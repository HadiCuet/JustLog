//  JustFileDestination.swift

import Foundation
import SwiftyBeaver

public class JustFileDestination: FileDestination {

    public override func send(_ level: SwiftyBeaver.Level, msg: String, thread: String, file: String, function: String, line: Int, context: Any? = nil) -> String? {
        let dict = msg.toDictionary()
        guard let innerMessage = dict?["message"] as? String else { return nil }
        return super.send(level, msg: innerMessage, thread: thread, file: file, function: function, line: line, context: context)
    }
}

