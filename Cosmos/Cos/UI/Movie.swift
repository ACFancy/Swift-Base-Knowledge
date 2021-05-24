//
//  Movie.swift
//  Cos
//
//  Created by Lee Danatech on 2021/5/19.
//

import UIKit
import AVFoundation

public class Movie : View {
    class MovieView : UIView {
        var movieLayer: PlayerLayer {
            return self.layer as! PlayerLayer
        }
        
        override class var layerClass: AnyClass {
            return PlayerLayer.self
        }
    }
    
    var filename: String!
    var player: AVQueuePlayer?
    var currentItem: AVPlayerItem?
    var reachedEndAction: (() -> Void)?
    private var observer: Any?
    
    public var loops: Bool = true
    
    public var muted: Bool {
        get {
            guard let p = player else {
                return false
            }
            return p.isMuted
        }
        set {
            player?.isMuted = newValue
        }
    }
    
    public override var width: Double {
        get {
            return Double(view.frame.width)
        }
        set {
            var newSize = Size(newValue, height)
            if constrainsProportions {
                let ratio = Double(size.height / size.width)
                newSize.height = ratio * newValue
            }
            var rect = frame
            rect.size = newSize
            frame = rect
        }
    }
    
    public override var height: Double {
        get {
            return Double(view.frame.height)
        }
        set {
            var newSize = Size(width, newValue)
            if constrainsProportions {
                let ratio = Double(size.width / size.height)
                newSize.width = newValue * ratio
            }
            var rect = frame
            rect.size = newSize
            frame = rect
        }
    }
    
    public var constrainsProportions: Bool = true
    
    public internal(set) var originalSize: Size = Size(1, 1)
    
    public var originalRatio: Double {
        return originalSize.width / originalSize.height
    }
    
    var movieLayer: PlayerLayer {
        return movieView.movieLayer
    }
    
    var movieView: MovieView {
        return self.view as! MovieView
    }
    
    public var playing: Bool {
        return player?.rate != 0.0
    }
    
    public override var rotation: Double {
        get {
            if let number = movieLayer.value(forKeyPath: Layer.rotationKey) as? NSNumber {
                return number.doubleValue
            }
            return 0
        }
        set {
            movieLayer.setValue(newValue, forKeyPath: Layer.rotationKey)
        }
    }
    
    public convenience init?(_ filename: String) {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            debugPrint("XXXX")
        }
        
        guard let url = Bundle.main.url(forResource: filename, withExtension: nil) else {
            return nil
        }
        
        let asset = AVAsset(url: url)
        let tracks = asset.tracks(withMediaType: .video)
        
        let movieTrack = tracks[0]
        self.init(frame: Rect(0, 0, Double(movieTrack.naturalSize.width), Double(movieTrack.naturalSize.height)))
        self.filename = filename
        
        let newPlayer = AVQueuePlayer(playerItem: AVPlayerItem(asset: asset))
        newPlayer.actionAtItemEnd = .pause
        currentItem = newPlayer.currentItem
        player = newPlayer
        observer = on(event: NSNotification.Name.AVPlayerItemDidPlayToEndTime) { [weak self] in
            self?.handleReachedEnd()
        }
        movieLayer.player = player
        movieLayer.videoGravity = .resize
        originalSize = size
        muted = false
    }
    
    deinit {
        if let observer = observer {
            cancel(observer)
            self.observer = nil
        }
    }
    
    public override init(frame: Rect) {
        super.init()
        self.view = MovieView(frame: CGRect(frame))
    }
    
    public convenience init?(copy original: Movie) {
        self.init(original.filename)
        self.frame = original.frame
        copyViewStyle(original)
    }
    
    public func play() {
        guard let p = player else {
            return
        }
        p.play()
    }
    
    public func pause() {
        guard let p = player else {
            return
        }
        p.pause()
    }
    
    public func stop() {
        guard let p = player else {
            return
        }
        p.seek(to: CMTimeMake(value: 0, timescale: 1))
        p.pause()
    }
    
    public func reachedEnd(_ action: (() -> Void)?) {
        reachedEndAction = action
    }
    
    func handleReachedEnd() {
        if self.loops {
            stop()
            play()
        }
        reachedEndAction?()
    }
}
