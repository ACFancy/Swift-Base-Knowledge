//
//  SignLines.swift
//  Cosmos
//
//  Created by Lee Danatech on 2021/5/21.
//

import UIKit
import Cos

public class SignLines : InfiniteScrollView {
    var lines: [[Line]]!
    var currentIndex: Int = 0
    var currentLines: [Line] {
        let set = lines[currentIndex]
        return set
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)

        let count = CGFloat(AstrologicalSignProvider.shared.order.count)
        contentSize = CGSize(width: frame.width * (count * gapBetweenSigns + 1), height: 1.0)

        var signOrder = AstrologicalSignProvider.shared.order
        signOrder.append(signOrder[0])
        lines = []
        for i in 0..<signOrder.count {
            let dx = Double(i) * Double(frame.width * gapBetweenSigns)
            let t = Transform.makeTranslation(Vector(x: Double(center.x) + dx, y: Double(center.y), z: 0))
            guard let sign = AstrologicalSignProvider.shared.get(sign: signOrder[i]),
                  let connections = sign.lines else {
                continue
            }

            var currentLineSet: [Line] = []
            for points in connections {
                var begin = points[0]
                begin.transform(t)
                var end = points[1]
                end.transform(t)
                let line = Line((begin, end))
                line.lineWidth = 1
                line.strokeColor = cosmosprpl
                line.opacity = 0.4
                line.strokeEnd = 0
                add(line)
                currentLineSet.append(line)
            }
            lines.append(currentLineSet)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    func revealCurrentSignLines() {
        ViewAnimation(duration: 0.25) {
            for line in self.currentLines {
                line.strokeEnd = 1.0
            }
        }.animate()
    }

    func hideCurrentSignLines() {
        ViewAnimation(duration: 0.25) {
            for line in self.currentLines {
                line.strokeEnd = 0
            }
        }.animate()
    }
}
