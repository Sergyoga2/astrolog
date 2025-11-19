import Foundation
import AVFoundation
import Combine

/// Service for managing meditation audio playback
@MainActor
class AudioPlayerService: NSObject, ObservableObject {
    static let shared = AudioPlayerService()

    // Published state
    @Published var isPlaying = false
    @Published var currentMeditation: Meditation?
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var playbackRate: Float = 1.0
    @Published var volume: Float = 1.0
    @Published var errorMessage: String?

    // AVPlayer
    private var player: AVPlayer?
    private var playerItem: AVPlayerItem?
    private var timeObserver: Any?
    private var cancellables = Set<AnyCancellable>()

    private override init() {
        super.init()
        setupAudioSession()
        setupNotifications()
    }

    deinit {
        cleanup()
    }

    // MARK: - Audio Session Setup

    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .spokenAudio, options: [])
            try session.setActive(true)
        } catch {
            errorMessage = "Failed to setup audio session: \(error.localizedDescription)"
        }
    }

    // MARK: - Playback Control

    /// Load and prepare meditation for playback
    func loadMeditation(_ meditation: Meditation) async {
        currentMeditation = meditation

        // Clean up existing player
        cleanup()

        // Load audio from URL
        guard let url = URL(string: meditation.audioURL) else {
            errorMessage = "Invalid audio URL"
            return
        }

        // For remote URLs, use AVPlayerItem
        if url.scheme == "http" || url.scheme == "https" {
            playerItem = AVPlayerItem(url: url)
        } else {
            // For local files
            playerItem = AVPlayerItem(url: url)
        }

        guard let playerItem = playerItem else {
            errorMessage = "Failed to create player item"
            return
        }

        player = AVPlayer(playerItem: playerItem)
        player?.volume = volume
        player?.rate = playbackRate

        // Observe player item status
        playerItem.publisher(for: \.status)
            .sink { [weak self] status in
                Task { @MainActor in
                    switch status {
                    case .readyToPlay:
                        self?.duration = playerItem.duration.seconds
                        self?.errorMessage = nil
                    case .failed:
                        self?.errorMessage = "Failed to load audio"
                    default:
                        break
                    }
                }
            }
            .store(in: &cancellables)

        // Add time observer
        let interval = CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            Task { @MainActor in
                self?.currentTime = time.seconds
            }
        }

        // Observe playback end
        NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime, object: playerItem)
            .sink { [weak self] _ in
                Task { @MainActor in
                    self?.handlePlaybackEnd()
                }
            }
            .store(in: &cancellables)
    }

    /// Play current meditation
    func play() {
        guard let player = player else {
            errorMessage = "No meditation loaded"
            return
        }

        player.play()
        isPlaying = true

        // Track play in meditation progress
        if let meditation = currentMeditation {
            Task {
                await MeditationService.shared.trackPlay(meditation)
            }
        }
    }

    /// Pause playback
    func pause() {
        player?.pause()
        isPlaying = false
    }

    /// Toggle play/pause
    func togglePlayPause() {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }

    /// Stop playback and reset
    func stop() {
        player?.pause()
        player?.seek(to: .zero)
        isPlaying = false
        currentTime = 0
    }

    /// Seek to specific time
    func seek(to time: TimeInterval) {
        let cmTime = CMTime(seconds: time, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        player?.seek(to: cmTime)
        currentTime = time
    }

    /// Skip forward by seconds
    func skipForward(by seconds: TimeInterval = 15) {
        let newTime = min(currentTime + seconds, duration)
        seek(to: newTime)
    }

    /// Skip backward by seconds
    func skipBackward(by seconds: TimeInterval = 15) {
        let newTime = max(currentTime - seconds, 0)
        seek(to: newTime)
    }

    /// Set playback rate
    func setPlaybackRate(_ rate: Float) {
        playbackRate = rate
        player?.rate = isPlaying ? rate : 0
    }

    /// Set volume
    func setVolume(_ newVolume: Float) {
        volume = newVolume
        player?.volume = newVolume
    }

    // MARK: - Playback End

    private func handlePlaybackEnd() {
        isPlaying = false
        currentTime = 0

        // Mark session as completed
        if let meditation = currentMeditation {
            Task {
                await MeditationService.shared.completeSession(meditation, duration: duration)
            }
        }
    }

    // MARK: - Notifications

    private func setupNotifications() {
        // Handle audio session interruptions
        NotificationCenter.default.publisher(for: AVAudioSession.interruptionNotification)
            .sink { [weak self] notification in
                Task { @MainActor in
                    self?.handleInterruption(notification)
                }
            }
            .store(in: &cancellables)

        // Handle route changes (headphones disconnected, etc.)
        NotificationCenter.default.publisher(for: AVAudioSession.routeChangeNotification)
            .sink { [weak self] notification in
                Task { @MainActor in
                    self?.handleRouteChange(notification)
                }
            }
            .store(in: &cancellables)
    }

    private func handleInterruption(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }

        switch type {
        case .began:
            // Pause playback when interrupted
            pause()

        case .ended:
            // Resume playback if it should continue
            if let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
                let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                if options.contains(.shouldResume) {
                    play()
                }
            }

        @unknown default:
            break
        }
    }

    private func handleRouteChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
              let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else {
            return
        }

        // Pause if headphones were removed
        if reason == .oldDeviceUnavailable {
            pause()
        }
    }

    // MARK: - Cleanup

    private func cleanup() {
        if let timeObserver = timeObserver {
            player?.removeTimeObserver(timeObserver)
            self.timeObserver = nil
        }

        player?.pause()
        player = nil
        playerItem = nil
        cancellables.removeAll()
    }

    // MARK: - Helper Properties

    var progress: Double {
        guard duration > 0 else { return 0 }
        return currentTime / duration
    }

    var remainingTime: TimeInterval {
        return max(duration - currentTime, 0)
    }

    var currentTimeFormatted: String {
        return formatTime(currentTime)
    }

    var durationFormatted: String {
        return formatTime(duration)
    }

    var remainingTimeFormatted: String {
        return formatTime(remainingTime)
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Meditation Service Extension

extension AudioPlayerService {
    /// Quick play meditation
    func playMeditation(_ meditation: Meditation) async {
        await loadMeditation(meditation)
        // Wait a bit for loading
        try? await Task.sleep(nanoseconds: 500_000_000)
        play()
    }
}
