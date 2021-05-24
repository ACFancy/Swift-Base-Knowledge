//
//  MenuRings.swift
//  Cosmos
//
//  Created by Lee Danatech on 2021/5/21.
//

import UIKit
import Cos

public class MenuRings : CanvasController {
    //MARK: -
    //MARK: Properties
    var thickRing : Circle!
    var thickRingFrames : [Rect]!
    var thickRingOut : ViewAnimation?
    var thickRingIn : ViewAnimation?
    
    var thinRings : [Circle]!
    var thinRingFrames : [Rect]!
    var thinRingsOut : ViewAnimationSequence?
    var thinRingsIn : ViewAnimationSequence?
    
    var dashedRings : [Circle]!
    var revealDashedRings : ViewAnimation?
    var hideDashedRings : ViewAnimation?
    
    var menuDividingLines : [Line]!
    
    var menuIsVisible = false
    
    
    //MARK: -
    //MARK: Setup
    public override func setup() {
        //clear the canvas
        canvas.backgroundColor = clear
        //make the canvas small (helps isolate its interactivity to a small portion of the main app's screen)
        canvas.frame = Rect(0,0,80,80)
        createRingsLines()
        createRingsLinesAnimations()
    }
    
    //MARK: -
    //MARK: Rings and Lines
    func createRingsLines() {
        createThickRing()
        createThinRings()
        createDashedRings()
        createMenuDividingLines()
    }
    
    func createRingsLinesAnimations() {
        createThickRingAnimations()
        createThinRingsOutAnimations()
        createThinRingsInAnimations()
        createDashedRingAnimations()
    }
    
    //creates the thick ring
    func createThickRing() {
        //create 2 shapes
        let inner = Circle(center: canvas.center, radius: 14)
        let outer = Circle(center: canvas.center, radius: 225)
        //store the frames of each position
        thickRingFrames = [inner.frame,outer.frame]
        
        //style the inner ring and use it to create the `thickRing` object
        inner.fillColor = clear
        inner.lineWidth = 3
        inner.strokeColor = cosmosblue
        inner.interactionEnabled = false
        thickRing = inner
        
        canvas.add(thickRing)
    }
    
    //creates the in / out animations for the thick ring
    func createThickRingAnimations() {
        //animates the frame of the ring to its open position
        thickRingOut = ViewAnimation(duration: 0.5) {
            self.thickRing?.frame = self.thickRingFrames[1]
        }
        thickRingOut?.curve = .easeOut
        
        //animates the frame of the ring to its closed position
        thickRingIn = ViewAnimation(duration: 0.5) {
            self.thickRing?.frame = self.thickRingFrames[0]
        }
        thickRingIn?.curve = .easeOut
    }
    
    func createThinRings() {
        //creates the closed position of each ring
        thinRings = [Circle]()
        thinRings.append(Circle(center: canvas.center, radius: 8))
        thinRings.append(Circle(center: canvas.center, radius: 56))
        thinRings.append(Circle(center: canvas.center, radius: 78))
        thinRings.append(Circle(center: canvas.center, radius: 98))
        thinRings.append(Circle(center: canvas.center, radius: 102))
        thinRings.append(Circle(center: canvas.center, radius: 156))
        
        //iterate through all the current thin rings to grab their frames
        thinRingFrames = [Rect]()
        for i in 0..<self.thinRings.count {
            let ring = self.thinRings[i]
            ring.fillColor = clear
            ring.lineWidth = 1
            ring.strokeColor = cosmosblue
            ring.interactionEnabled = false
            if i > 0 {
                ring.opacity = 0.0
            }
            self.thinRingFrames.append(ring.frame)
        }
        
        //add all the rings to the canvas
        for ring in thinRings {
            canvas.add(ring)
        }
    }
    
    func createThinRingsOutAnimations() {
        //create an array to store the animations we'll create
        var animationArray = [ViewAnimation]()
        //for each of the rings (except the last one)
        for i in 0..<self.thinRings.count-1 {
            //create an aninmation whose duration is slightly longer than the previous one
            let anim = ViewAnimation(duration: 0.075 + Double(i) * 0.01) {
                let circle = self.thinRings[i]
                //for each animation greatre than the first
                if (i > 0) {
                    //animate the opacity of the ring to 1.0
                    ViewAnimation(duration: 0.0375) {
                        circle.opacity = 1.0
                    }.animate()
                }
                
                circle.frame = self.thinRingFrames[i+1]
            }
            anim.curve = .easeOut
            animationArray.append(anim)
        }
        //create an animation sequence for animating the thin rings out
        thinRingsOut = ViewAnimationSequence(animations: animationArray)
    }
    
    func createThinRingsInAnimations() {
        //create an array to store the animations we'll create
        var animationArray = [ViewAnimation]()
        //for each of the rings (except the first one)
        for i in 1...self.thinRings.count {
            //create an aninmation whose duration is slightly longer than the previous one
            let anim = ViewAnimation(duration: 0.075 + Double(i) * 0.01, animations: { () -> Void in
                //grab the last ring and work towards the first
                let circle = self.thinRings[self.thinRings.count - i]
                if self.thinRings.count - i > 0 {
                    //for each ring that isn't the first, animate its opacity to 0.0
                    ViewAnimation(duration: 0.0375) {
                        circle.opacity = 0.0
                    }.animate()
                }
                circle.frame = self.thinRingFrames[self.thinRings.count - i]
            })
            anim.curve = .easeOut
            animationArray.append(anim)
        }
        thinRingsIn = ViewAnimationSequence(animations: animationArray)
    }
    
    func createDashedRings() {
        dashedRings = [Circle]()
        createShortDashedRing()
        createLongDashedRing()
        
        for ring in self.dashedRings {
            ring.strokeColor = cosmosblue
            ring.fillColor = clear
            ring.interactionEnabled = false
            ring.lineCap = .butt
            self.canvas.add(ring)
        }
    }
    
    func createShortDashedRing() {
        //creates a new ring and styles it
        let shortDashedRing = Circle(center: canvas.center, radius: 82+2)
        //creates a pattern, with 4 dashes and 1 wide gap
        let pattern = [1.465,1.465,1.465,1.465,1.465,1.465,1.465,1.465*3.0] as [NSNumber]
        shortDashedRing.lineDashPattern = pattern
        shortDashedRing.strokeEnd = 0.995
        
        //adjusts the angle of the shape's rotation to make the gap appear at 0 position
        let angle = degToRad(-1.5)
        let rotation = Transform.makeRotation(angle)
        shortDashedRing.transform = rotation
        
        shortDashedRing.lineWidth = 0.0
        dashedRings.append(shortDashedRing)
    }
    
    func createLongDashedRing() {
        //creates a new ring and styles it
        let longDashedRing = Circle(center: canvas.center, radius: 82+2)
        longDashedRing.lineWidth = 0.0
        
        //creates a pattern, with 1 dash and 1 very wide gap
        let pattern = [1.465,1.465*9.0] as [NSNumber]
        longDashedRing.lineDashPattern = pattern
        longDashedRing.strokeEnd = 0.995
        
        //adjusts the angle of the shape's rotation to make the dash appear at 0 position
        let angle = degToRad(0.5)
        let rotation = Transform.makeRotation(angle)
        longDashedRing.transform = rotation
        
        //adds a mask to the long dashed ring so that it looks like it lines up with the inner radius of the short ring
        let mask = Circle(center: longDashedRing.bounds.center, radius: 82+4)
        mask.fillColor = clear
        mask.lineWidth = 8
        longDashedRing.layer?.mask = mask.layer
        
        dashedRings.append(longDashedRing)
    }
    
    func createDashedRingAnimations() {
        //instead of changing the opacities, we animate the line width for a nicer effect
        revealDashedRings = ViewAnimation(duration: 0.25) {
            self.dashedRings[0].lineWidth = 4
            self.dashedRings[1].lineWidth = 12
        }
        revealDashedRings?.curve = .easeOut
        
        hideDashedRings = ViewAnimation(duration: 0.25) {
            self.dashedRings[0].lineWidth = 0
            self.dashedRings[1].lineWidth = 0
        }
        hideDashedRings?.curve = .easeOut
    }
    
    func createMenuDividingLines() {
        menuDividingLines = [Line]()
        //adds 12 lines and rotates them into position
        for i in 0...11 {
            let line = Line((Point(),Point(54,0)))
            //adjusting the anchor point means centering the shape will be offset so that it appears to the right
            line.anchorPoint = Point(-1.88888,0)
            line.center = canvas.center
            //rotate the shape around the offset anchor point
            line.transform = Transform.makeRotation(Double.pi / 6.0 * Double(i) , axis: Vector(x: 0, y: 0, z: -1))
            line.lineCap = .butt
            line.strokeColor = cosmosblue
            line.lineWidth = 1.0
            line.strokeEnd = 0.0
            canvas.add(line)
            menuDividingLines.append(line)
        }
    }
    
    //instead of having two separate methods, we use a target value for the strokeEnd of the lines
    //e.g. hide = 0.0
    //we do this because the logic is random, and identical in either direction
    func revealHideDividingLines(_ target: Double) {
        //create a list of indices that need to be animated
        var indices = [0,1,2,3,4,5,6,7,8,9,10,11]
        
        //instead of changing the opacities, we animate the line width for a nicer effect
        for i in 0...11 {
            //create a delay, and grab a line based on random selection from the local indices[]
            wait(0.05*Double(i)) {
                let randomIndex = random(below: indices.count)
                let index = indices[randomIndex]
                
                ViewAnimation(duration: 0.1) {
                    self.menuDividingLines[index].strokeEnd = target
                }.animate()
                //removes the current index from the local list so we can continue grabbing the remaining shapes
                indices.remove(at: randomIndex)
            }
        }
    }
}
