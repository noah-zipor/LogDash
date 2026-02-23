import Foundation

class AppleScriptHelper {
    static func execute(script: String) -> String? {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
        process.arguments = ["-e", script]

        let outputPipe = Pipe()
        process.standardOutput = outputPipe

        do {
            try process.run()
            let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8) {
                return output.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        } catch {
            print("AppleScript execution failed: \(error)")
        }
        return nil
    }

    static func getMusicInfo() -> (title: String, artist: String, isPlaying: Bool)? {
        let script = """
        if application "Music" is running then
            tell application "Music"
                if player state is playing then
                    return "Music|" & name of current track & "|" & artist of current track & "|playing"
                else if player state is paused then
                    return "Music|" & name of current track & "|" & artist of current track & "|paused"
                end if
            end tell
        end if
        if application "Spotify" is running then
            tell application "Spotify"
                if player state is playing then
                    return "Spotify|" & name of current track & "|" & artist of current track & "|playing"
                else if player state is paused then
                    return "Spotify|" & name of current track & "|" & artist of current track & "|paused"
                end if
            end tell
        end if
        return "None|||stopped"
        """

        if let output = execute(script: script) {
            let parts = output.components(separatedBy: "|")
            if parts.count >= 4 {
                let title = parts[1]
                let artist = parts[2]
                let isPlaying = parts[3] == "playing"
                if parts[0] != "None" {
                    return (title, artist, isPlaying)
                }
            }
        }
        return nil
    }
}
