//
//  Stars.swift
//  Cosmos
//
//  Created by Lee Danatech on 2021/5/21.
//

import UIKit
import Cos

let gapBetweenSigns: CGFloat = 10

class Stars : CanvasController, UIScrollViewDelegate {
    let speeds: [CGFloat] = [0.08, 0, 0.1, 0.12, 0.15, 1, 0.8, 1]
    var scrollviews: [InfiniteScrollView]!
    var scrollviewOffsetContext = 0
    
    var signLines: SignLines!
    var bigStars: StarsBig!
    var snapTargets: [CGFloat]!
    
    override func setup() {
        canvas.backgroundColor = cosmosbkgd
        scrollviews = []
        scrollviews.append(StarsBackground(frame: view.frame, imageName: "0Star", starCount: 20, speed: speeds[0]))
        scrollviews.append(createVognette())
        scrollviews.append(StarsBackground(frame: view.frame, imageName: "2Star", starCount: 20, speed: speeds[2]))
        scrollviews.append(StarsBackground(frame: view.frame, imageName: "3Star", starCount: 20, speed: speeds[3]))
        scrollviews.append(StarsBackground(frame: view.frame, imageName: "4Star", starCount: 20, speed: speeds[4]))
        signLines = SignLines(frame: view.frame)
        scrollviews.append(signLines)
        
        scrollviews.append(StarsSmall(frame: view.frame, speed: speeds[6]))
        
        bigStars = StarsBig(frame: view.frame)
        bigStars.addObserver(self, forKeyPath: "contentOffset", options: .new, context: &scrollviewOffsetContext)
        bigStars.contentOffset = CGPoint(x: view.frame.width * CGFloat(gapBetweenSigns / 2.0), y: 0)
        bigStars.delegate = self
        scrollviews.append(bigStars)
        for sv in scrollviews {
            canvas.add(sv)
        }
        createSnapTargets()
    }
    
    func createSnapTargets() {
        snapTargets = []
        for i in 0...12 {
            snapTargets.append(gapBetweenSigns * CGFloat(i) * view.frame.width)
        }
    }
    
    func snapIfNeeded(_ x: CGFloat, _ scrollView: UIScrollView) {
        for target in snapTargets {
            let dist = abs(CGFloat(target) - x)
            if dist <= CGFloat(canvas.width / 2) {
                scrollView.setContentOffset(CGPoint(x: target, y: 0), animated: true)
                wait(0.25) {
                    var index = Int(Double(target) / (self.canvas.width * Double(gapBetweenSigns)))
                    if index == 12 {
                        index = 0
                    }
                    self.signLines.currentIndex = index
                    self.signLines.revealCurrentSignLines()
                }
                return
            }
        }
    }
    
    func createVognette() -> InfiniteScrollView {
        let sv = InfiniteScrollView(frame: view.frame)
        let img = Image("1vignette")!
        img.frame = canvas.frame
        sv.add(img)
        return sv
    }
    
    func goto(_ selection: Int) {
        let target = canvas.width * Double(gapBetweenSigns) * Double(selection)
        let anim = ViewAnimation(duration: 3) {
            self.bigStars.contentOffset = CGPoint(x: CGFloat(target), y: 0)
        }
        anim.curve = .easeOut
        anim.addCompletionObserver {
            self.signLines.revealCurrentSignLines()
        }
        anim.animate()
        
        signLines.currentIndex = selection
    }
    
    // MARK: - Observer
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard context == &scrollviewOffsetContext else {
            return
        }
        let sv = object as! InfiniteScrollView
        let offset = sv.contentOffset
        for i in 0..<(scrollviews.count - 1) {
            let layer = scrollviews[i]
            layer.contentOffset = CGPoint(x: offset.x * speeds[i], y: 0)
        }
    }
    
    // MARK: - UIScrollViewDelegate
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        snapIfNeeded(scrollView.contentOffset.x, scrollView)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard decelerate == false else {
            return
        }
        snapIfNeeded(scrollView.contentOffset.x, scrollView)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        signLines.hideCurrentSignLines()
    }
}
