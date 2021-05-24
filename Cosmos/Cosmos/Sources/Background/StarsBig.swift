//
//  StarsBig.swift
//  Cosmos
//
//  Created by Lee Danatech on 2021/5/21.
//

import UIKit
import Cos

public class StarsBig : InfiniteScrollView {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        //grabs the current order
        var signOrder = AstrologicalSignProvider.shared.order
        //sets the contents size to signCount * single size, adds canvas.width to account for overlap to hide snap
        contentSize = CGSize(width: frame.size.width * (1.0 + CGFloat(signOrder.count) * gapBetweenSigns), height: 1.0)

        //appends a copy of the first sign to the end of the order
        signOrder.append(signOrder[0])

        //adds all the big stars to the view
        for i in 0..<signOrder.count {
            //calculates the offset
            let dx = Double(i) * Double(frame.size.width  * gapBetweenSigns)
            //creates a transform
            let t = Transform.makeTranslation(Vector(x: Double(center.x) + dx, y: Double(center.y), z: 0))
            //grabs the current sign
            if let sign = AstrologicalSignProvider.shared.get(sign: signOrder[i]) {
                //creates a new big star for each point
                for point in sign.big {
                    let img = Image("7bigStar")!
                    var p = point
                    p.transform(t)
                    img.center = p
                    add(img)
                }
            }
        }

        addDashes()
        addMarkers()
        addSignNames()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    func addDashes() {
        let points = (Point(0, Double(frame.maxY)), Point(Double(contentSize.width), Double(frame.maxY)))

        let dashes = Line(points)
        dashes.lineDashPattern = [2, 6]
        dashes.lineWidth = 10
        dashes.strokeColor = cosmosblue
        dashes.opacity = 0.33
        dashes.lineCap = .butt
        add(dashes)
    }

    func addMarkers() {
        for i in 0..<AstrologicalSignProvider.shared.order.count {
            let dx = Double(i) * Double(frame.width * gapBetweenSigns) + Double(frame.width / 2)
            let begin = Point(dx, Double(frame.height - 20))
            let end = Point(dx, Double(frame.height))

            let marker = Line((begin, end))
            marker.lineWidth = 2
            marker.strokeColor = white
            marker.lineCap = .butt
            marker.opacity = 0.33
            add(marker)
        }
    }

    func addSignNames() {
        var signNames = AstrologicalSignProvider.shared.order
        signNames.append(signNames[0])

        let y = Double(frame.width - 86)
        let dx = Double(frame.width * gapBetweenSigns)
        let offset = Double(frame.width / 2)
        let font = Font(name: "Menlo-Regular", size: 13)!

        for i in 0..<signNames.count {
            let name = signNames[i]

            var point = Point(offset + dx * Double(i), y)
            if let sign = createSmallSign(name: name) {
                sign.center = point
                add(sign)
            }
            point.y += 26

            let title = createSmallSignTitle(name: name, font: font)
            title.center = point
            point.y += 22

            var value = i * 30
            if value > 330 {
                value = 0
            }
            let degree = createSmallSignDegree(degree: value, font: font)
            degree.center = point
            add(title)
            add(degree)
        }
    }

    func createSmallSign(name: String) -> Shape? {
        guard let sign = AstrologicalSignProvider.shared.get(sign: name)?.shape else {
            return nil
        }
        sign.lineWidth = 2
        sign.strokeColor = white
        sign.fillColor = clear
        sign.opacity = 0.33
        sign.transform = Transform.makeScale(0.66, 0.66, 0)
        return sign
    }

    func createSmallSignTitle(name: String, font: Font) -> TextShape {
        let text = TextShape(text: name, font: font)!
        text.fillColor = white
        text.lineWidth = 0
        text.opacity = 0.33
        return text
    }

    func createSmallSignDegree(degree: Int, font: Font) -> TextShape {
        return createSmallSignTitle(name: "\(degree)°", font: font)
    }
}
