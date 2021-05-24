//
//  StarsSmall.swift
//  Cosmos
//
//  Created by Lee Danatech on 2021/5/21.
//

import UIKit
import Cos

public class StarsSmall : InfiniteScrollView {
    public convenience init(frame: CGRect, speed: CGFloat) {
        self.init(frame: frame)
        var signOrder = AstrologicalSignProvider.shared.order
        contentSize = CGSize(width: frame.width * (1 + CGFloat(signOrder.count) * gapBetweenSigns), height: 1.0)
        signOrder.append(signOrder[0])

        for i in 0..<signOrder.count {
            let dx = Double(i) * Double(frame.width * speed * gapBetweenSigns)
            let t = Transform.makeTranslation(Vector(x: Double(center.x) + dx, y: Double(center.y), z: 0))
            guard let sign = AstrologicalSignProvider.shared.get(sign: signOrder[i]), let small = sign.small else {
                continue
            }
            for point in small {
                let img = Image("6smallStar")!
                var p = point
                p.transform(t)
                img.center = p
                add(img)
            }
        }
    }
}
