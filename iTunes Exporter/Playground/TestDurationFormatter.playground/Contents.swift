import Cocoa

let formatter = DateComponentsFormatter()
formatter.allowedUnits = [.hour, .minute, .second]
formatter.unitsStyle = .positional
formatter.zeroFormattingBehavior = .pad

func durationString(for duration: TimeInterval) -> String {
    formatter.string(from: duration)!
        .replacingOccurrences(of: #"^00[:.]0?|^0"#, with: "", options: .regularExpression)
}

