//
//  AudioPlayer.swift
//  Cos
//
//  Created by Lee Danatech on 2021/5/19.
//

import UIKit
import AVFoundation

public class AudioPlayer : NSObject, AVAudioPlayerDelegate {
    internal var player: AVAudioPlayer!
    
    var filename: String!
    
    public init?(_ name: String) {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            debugPrint("session not ready")
        }
        super.init()
        
        guard let url = Bundle.main.url(forResource: name, withExtension: nil) else {
            return nil
        }
        guard let player = try? AVAudioPlayer(contentsOf: url) else {
            return nil
        }
        self.player = player
        player.delegate = self
        self.filename = name
    }
    
    public convenience init?(copy original: AudioPlayer) {
        self.init(original.filename)
    }
    
    public func play() {
        player.play()
    }
    
    public func pause() {
        player.pause()
    }
    
    public func stop() {
        player.stop()
    }
    
    public var duration: Double {
        return Double(player.duration)
    }
    
    public var playing: Bool {
        return player.isPlaying
    }
    
    public var pan: Double {
        get {
            return Double(player.pan)
        }
        set {
            player.pan = clamp(Float(newValue), min: -1.0, max: 1.0)
        }
    }
    
    public var volume: Double {
        get {
            return Double(player.volume)
        }
        set {
            player.volume = clamp(Float(newValue), min: 0, max: 1.0)
        }
    }
    
    public var currentTime: Double {
        get {
            return player.currentTime
        }
        set {
            player.currentTime = clamp(TimeInterval(newValue), min: 0, max: player.duration)
        }
    }
    
    public var rate: Double {
        get {
            return Double(player.rate)
        }
        set {
            player.rate = Float(newValue)
        }
    }
    
    public var loops: Bool {
        get {
            return player.numberOfLoops > 0
        }
        set {
            player.numberOfLoops = newValue ? 100_0000 : 0
        }
    }
    
    public var meteringEnabled: Bool {
        get {
            return player.isMeteringEnabled
        }
        set {
            player.isMeteringEnabled = newValue
        }
    }
    
    public var enableRate: Bool {
        get {
            return player.enableRate
        }
        set {
            player.enableRate = newValue
        }
    }
    
    public func updateMeters() {
        player.updateMeters()
    }
    
    public func averagePower(_ channel: Int) -> Double {
        return Double(player.averagePower(forChannel: channel))
    }
    
    public func peakPower(_ channel: Int) -> Double {
        return Double(player.peakPower(forChannel: channel))
    }
}
