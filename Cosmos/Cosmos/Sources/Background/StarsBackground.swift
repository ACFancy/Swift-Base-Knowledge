//
//  StarsBackground.swift
//  Cosmos
//
//  Created by Lee Danatech on 2021/5/21.
//

import UIKit
import Cos

public class StarsBackground : InfiniteScrollView {
    public convenience init(frame: CGRect, imageName: String, starCount: Int, speed: CGFloat) {
        self.init(frame: frame)
        let adjustedFrameSize = frame.width * speed
        let singleSignContentSize = adjustedFrameSize * gapBetweenSigns
        let count = CGFloat(AstrologicalSignProvider.shared.order.count)

        contentSize = CGSize(width: singleSignContentSize * count + frame.width, height: 1.0)

        for currentFrame in 0..<Int(count) {
            let dx = Double(singleSignContentSize) * Double(currentFrame)
            for _ in 0..<starCount {
                let x = dx + random(in: 0..<1) * Double(singleSignContentSize)
                let y = random(in: 0.0..<1.0) * Double(frame.height)
                var pt = Point(x, y)
                let img = Image(imageName)!
                img.center = pt
                add(img)
                if pt.x < Double(frame.width) {
                    pt.x += Double(count * singleSignContentSize)
                    let img = Image(imageName)!
                    img.center = pt
                    add(img)
                }
            }
        }
    }
}
