//
//  InfoPanel.swift
//  Cosmos
//
//  Created by Lee Danatech on 2021/5/21.
//

import UIKit
import Cos

public class InfoPanel : CanvasController {
    var link: TextShape?

    public override func setup() {
        canvas.backgroundColor = Color(red: 0, green: 0, blue: 0, alpha: 0.33)
        canvas.opacity = 0

    }

    func createLogo() {
        let logo = Image("logo")!
        logo.center = Point(canvas.center.x, canvas.height / 6)
        canvas.add(logo)
    }

    func createLabel() {
        let message = """
            COSMOS @copyright 2021
            """
        let text = UILabel()
        text.text = message
        text.font = UIFont(name: "Menlo-Regular", size: 18)
        text.numberOfLines = 40
        text.textColor = .white
        text.textAlignment = .center
        text.sizeToFit()
        text.center = CGPoint(canvas.center)
        canvas.add(text)
    }

    func createLink() {
        let f = Font(name: "Menlo-Regular", size: 24)!
        let text = TextShape(text: "www.baidu.com", font: f)!
        text.fillColor = white
        text.center = Point(canvas.center.x, canvas.height * 5.0 / 6.0)

        let a = Point(text.origin.x, text.frame.max.y + 8)
        let b = Point(a.x + text.width + 1, a.y)
        let line = Line((a, b))
        line.lineWidth = 2
        line.strokeColor = C4Pink

        link = text
        canvas.add(link)
        canvas.add(line)
    }

    func linkGesture() {
        let press = link?.addLongPressGestureRecognizer{ [weak self] _, location, state in
            guard let self = self else { return }
            switch state {
            case .began, .changed:
                self.link?.fillColor = C4Pink
            case .ended:
                if let l = self.link, l.hitTest(location) {
                    UIApplication.shared.open(URL(string: "https://www.baidu.com")!, options: [:], completionHandler: nil)
                }
                fallthrough
            default:
                self.link?.fillColor = white
            }
        }
        press?.minimumPressDuration = 0
    }

    func hideGesture() {
        canvas.addTapGestureRecognizer { [weak self] _, _, _ in
            guard let self = self else { return }
            self.hide()
        }
    }

    func hide() {
        ViewAnimation(duration: 0.25) {
            self.canvas.opacity = 0
        }.animate()
    }

    func show() {
        ViewAnimation(duration: 0.25) {
            self.canvas.opacity = 1
        }.animate()
    }
}
