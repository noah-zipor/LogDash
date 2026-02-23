import Foundation
import MediaPlayer

class MacOSMediaService: NSObject, MediaServiceProtocol {
    var onMediaChanged: ((MediaInfo) -> Void)?
    private var lastMediaInfo: MediaInfo?
    private var pollTimer: Timer?

    override init() {
        super.init()
        setupObservers()
        startPolling()
    }

    deinit {
        DistributedNotificationCenter.default().removeObserver(self)
        pollTimer?.invalidate()
    }

    private func startPolling() {
        pollTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            DispatchQueue.global(qos: .background).async {
                self?.pollMediaInfo()
            }
        }
    }

    private func pollMediaInfo() {
        if let info = AppleScriptHelper.getMusicInfo() {
            let media = MediaInfo(title: info.title, artist: info.artist, albumArt: nil, isPlaying: info.isPlaying)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                if media.title != self.lastMediaInfo?.title || media.isPlaying != self.lastMediaInfo?.isPlaying {
                    self.lastMediaInfo = media
                    self.onMediaChanged?(media)
                }
            }
        }
    }

    private func setupObservers() {
        // Listen for Apple Music notifications
        DistributedNotificationCenter.default().addObserver(
            self,
            selector: #selector(handleAppleMusicChange),
            name: NSNotification.Name("com.apple.Music.playerInfo"),
            object: nil
        )

        // Listen for Spotify notifications
        DistributedNotificationCenter.default().addObserver(
            self,
            selector: #selector(handleSpotifyChange),
            name: NSNotification.Name("com.spotify.client.PlaybackStateChanged"),
            object: nil
        )
    }

    @objc private func handleAppleMusicChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }

        let title = (userInfo["Name"] as? String) ?? "Unknown Title"
        let artist = (userInfo["Artist"] as? String) ?? "Unknown Artist"
        let isPlaying = (userInfo["Player State"] as? String) == "Playing"

        let info = MediaInfo(title: title, artist: artist, albumArt: nil, isPlaying: isPlaying)
        self.lastMediaInfo = info

        DispatchQueue.main.async {
            self.onMediaChanged?(info)
        }
    }

    @objc private func handleSpotifyChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }

        let title = (userInfo["trackName"] as? String) ?? "Unknown Title"
        let artist = (userInfo["artistName"] as? String) ?? "Unknown Artist"
        let isPlaying = (userInfo["playerState"] as? String) == "Playing"

        let info = MediaInfo(title: title, artist: artist, albumArt: nil, isPlaying: isPlaying)
        self.lastMediaInfo = info

        DispatchQueue.main.async {
            self.onMediaChanged?(info)
        }
    }

    func getCurrentMedia() -> MediaInfo? {
        if let last = lastMediaInfo, last.isPlaying {
            return last
        }
        return nil
    }
}
