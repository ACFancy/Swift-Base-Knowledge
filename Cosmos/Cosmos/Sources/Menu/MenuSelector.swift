//
//  MenuSelector.swift
//  Cosmos
//
//  Created by Lee Danatech on 2021/5/21.
//

import UIKit
import Cos

public class MenuSelector : CanvasController {
    var currentSelection = -1
    var menuLabel: TextShape!
    var highlight: Shape!
    var infoButton: View!
    
    var revealInfoButton: ViewAnimation!
    var hideInfoButton: ViewAnimation!
    
    let tick = AudioPlayer("tick.mp3")!
    
    public override func setup() {
        canvas.frame = Rect(0, 0, 80, 80)
        canvas.backgroundColor = clear
        createHighlight()
        createLabel()
        createInfoButton()
        createInfoButtonAnimations()
        tick.volume = 0.4
        
    }
    
    func update(location: Point) {
        let dist = distance(location, rhs: self.canvas.bounds.center)
        if dist > 102, dist < 156 {
            highlight.hidden = false
            let a = Vector(x: canvas.width / 2 + 1, y: canvas.height / 2)
            let b = Vector(x: canvas.width / 2, y: canvas.height / 2)
            let c = Vector(x: location.x, y: location.y)
            var angle = c.angleTo(a, basedOn: b)
            if c.y < a.y {
                angle = Double.pi * 2 - angle
            }
            menuLabel.hidden = false
            let index = Int(radToDeg(angle)) / 30

            if currentSelection != index {
                tick.stop()
                tick.play()
                ShapeLayer.disableActions = true
                menuLabel.text = AstrologicalSignProvider.shared.order[index].capitalized
                menuLabel.center = canvas.bounds.center
                currentSelection = index
                let rotation = Transform.makeRotation(degToRad(Double(currentSelection) * 30), axis: Vector(x: 0, y: 0, z: -1))
                highlight.transform = rotation
            }
        } else {
            highlight.hidden = true
            menuLabel.hidden = true
            currentSelection = -1
            if let l = infoButton, l.hitTest(location, from: canvas) {
                menuLabel.hidden = false
                ShapeLayer.disableActions = true
                menuLabel.text = "Info"
                menuLabel.center = canvas.bounds.center
                ShapeLayer.disableActions = false
            }
        }
    }
    
    func createHighlight() {
        highlight = Wedge(center: canvas.center, radius: 156, start: Double.pi / 6, end: 0, closewise: false)
        highlight.fillColor = cosmosblue
        highlight.lineWidth = 0
        highlight.opacity = 0.8
        highlight.interactionEnabled = false
        highlight.anchorPoint = Point()
        highlight.center = canvas.center
        highlight.hidden = true
        
        let donut = Circle(center: highlight.center, radius: 156 - 54 / 2.0)
        donut.fillColor = clear
        donut.lineWidth = 54
        highlight.mask = donut
        canvas.add(highlight)
    }
    
    func createLabel() {
        let f = Font(name: "Menlo-Regular", size: 13)!
        menuLabel = TextShape(text: "Cosmos", font: f)
        menuLabel.center = canvas.center
        menuLabel.fillColor = white
        menuLabel.interactionEnabled = false
        canvas.add(menuLabel)
        menuLabel.hidden = true
    }
    
    func createInfoButton() {
        infoButton = View(frame: Rect(0, 0, 44, 44))
        let buttonImage = Image("info")!
        buttonImage.interactionEnabled = false
        buttonImage.center = infoButton.center
        infoButton.add(buttonImage)
        infoButton.opacity = 0
        infoButton.center = Point(canvas.center.x, canvas.center.y + 190)
        canvas.add(infoButton)
    }
    
    func createInfoButtonAnimations() {
        revealInfoButton = ViewAnimation(duration: 0.33, animations: {
            self.infoButton?.opacity = 1
        })
        revealInfoButton.curve = .easeOut
        
        hideInfoButton = ViewAnimation(duration: 0.33, animations: {
            self.infoButton.opacity = 0
        })
        hideInfoButton.curve = .easeOut
    }
}
