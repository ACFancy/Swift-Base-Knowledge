//
//  MenuIcons.swift
//  Cosmos
//
//  Created by Lee Danatech on 2021/5/21.
//

import UIKit
import Cos

public class MenuIcons : CanvasController {
    //A dictionary to store references to functions
    var signIcons : [String:Shape]!
    //An array of targets for the closed state
    var innerTargets : [Point]!
    //An array of targets for the open state
    var outerTargets : [Point]!
    //Animations
    var signIconsOut : ViewAnimation!
    var signIconsIn : ViewAnimation!
    var revealSignIcons : ViewAnimation!
    var hideSignIcons : ViewAnimation!
    
    public override func setup() {
        canvas.frame = Rect(0,0,80,80)
        canvas.backgroundColor = clear
        createSignIcons()
        createSignIconAnimations()
    }
    
    //MARK: -
    //MARK: Animations
    func createSignIconAnimations() {
        //animates strokeEnd so the icons are revealed
        revealSignIcons = ViewAnimation(duration: 0.5) {
            for sign in [Shape](self.signIcons.values) {
                sign.strokeEnd = 1.0
            }
        }
        revealSignIcons?.curve = .easeOut
        
        //animates strokeEnd so the shapes are only dots
        hideSignIcons = ViewAnimation(duration: 0.5) {
            for sign in [Shape](self.signIcons.values) {
                sign.strokeEnd = 0.001
            }
        }
        hideSignIcons?.curve = .easeOut
        
        //moves icons to open position
        signIconsOut = ViewAnimation(duration: 0.33) {
            for i in 0..<AstrologicalSignProvider.shared.order.count {
                let name = AstrologicalSignProvider.shared.order[i]
                if let sign = self.signIcons[name] {
                    sign.center = self.outerTargets[i]
                }
            }
        }
        signIconsOut?.curve = .easeOut
        
        //moves icons to closed position
        signIconsIn = ViewAnimation(duration: 0.33) {
            for i in 0..<AstrologicalSignProvider.shared.order.count {
                let name = AstrologicalSignProvider.shared.order[i]
                if let sign = self.signIcons[name] {
                    sign.center = self.innerTargets[i]
                }
            }
        }
        signIconsIn?.curve = .easeOut
    }
    
    //MARK: -
    //MARK: Sign Icons
    func createSignIcons() {
        //Associate all the names of signs with the products of their methods
        signIcons = [String:Shape]()
        signIcons["aries"] = aries()
        signIcons["taurus"] = taurus()
        signIcons["gemini"] = gemini()
        signIcons["cancer"] = cancer()
        signIcons["leo"] = leo()
        signIcons["virgo"] = virgo()
        signIcons["libra"] = libra()
        signIcons["scorpio"] = scorpio()
        signIcons["sagittarius"] = sagittarius()
        signIcons["capricorn"] = capricorn()
        signIcons["aquarius"] = aquarius()
        signIcons["pisces"] = pisces()
        
        //style all the signs
        for shape in [Shape](self.signIcons.values) {
            shape.strokeEnd = 0.001 //in combination with the next two settings
            shape.lineCap = .round  //strokeEnd 0.001 makes a round dot at
            shape.lineJoin = .round //the beginning of the shape's path
            
            shape.transform = Transform.makeScale(0.64, 0.64, 1.0)
            shape.lineWidth = 2
            shape.strokeColor = white
            shape.fillColor = clear
        }
        
        positionSignIcons()
    }
    
    func positionSignIcons() {
        innerTargets = [Point]()
        let provider = AstrologicalSignProvider.shared
        //inner radius for the dots in the closed state menu
        let r = 10.5
        let dx = canvas.center.x
        let dy = canvas.center.y
        //loop through each sign in order
        for i in 0..<provider.order.count {
            //calculate the angle to the current sign
            let ϴ = Double.pi/6 * Double(i)
            //grab the name of the current sign
            let name = provider.order[i]
            //grab the shape from our local signIcons dictionary
            if let sign = signIcons[name] {
                //set the center point (remember we've already adjusted the anchorPoint)
                sign.center = Point(r * cos(ϴ) + dx, r * sin(ϴ) + dy)
                //add the sign to the canvas
                canvas.add(sign)
                //reset the anchorPoint to the center of the sign's view
                sign.anchorPoint = Point(0.5,0.5)
                //set the actual center of the sign as the target for the closed state of the menu
                innerTargets.append(sign.center)
            }
        }
        
        outerTargets = [Point]()
        for i in 0..<provider.order.count {
            //outer radius for the signs
            let r = 129.0
            //calculate the angle for the current sign
            let ϴ = Double.pi/6 * Double(i) + Double.pi/12.0
            //append the target point to the outer array
            outerTargets.append(Point(r * cos(ϴ) + dx, r * sin(ϴ) + dy))
        }
    }
    
    //MARK: -
    //MARK: Signs
    //These intermediate methods take the raw sign struct from the provider
    //Then, they extract the shape and offset each to the origin point
    //of the shape's path, this allows us to anchor the "dots" precisely
    //for the closed state of the menu
    func taurus() -> Shape {
        let shape = AstrologicalSignProvider.shared.taurus().shape!
        shape.anchorPoint = Point()
        return shape
    }
    
    func aries() -> Shape {
        let shape = AstrologicalSignProvider.shared.aries().shape!
        shape.anchorPoint = Point(0.0777,0.536)
        return shape
    }
    
    func gemini() -> Shape {
        let shape = AstrologicalSignProvider.shared.gemini().shape!
        shape.anchorPoint = Point(0.996,0.0)
        return shape
    }
    
    func cancer() -> Shape {
        let shape = AstrologicalSignProvider.shared.cancer().shape!
        shape.anchorPoint = Point(0.0,0.275)
        return shape
    }
    
    func leo() -> Shape {
        let shape = AstrologicalSignProvider.shared.leo().shape!
        shape.anchorPoint = Point(0.379,0.636)
        return shape
    }
    
    func virgo() -> Shape {
        let shape = AstrologicalSignProvider.shared.virgo().shape!
        shape.anchorPoint = Point(0.750,0.387)
        return shape
    }
    
    func libra() -> Shape {
        let shape = AstrologicalSignProvider.shared.libra().shape!
        shape.anchorPoint = Point(1.00,0.559)
        return shape
    }
    
    func pisces() -> Shape {
        let shape = AstrologicalSignProvider.shared.pisces().shape!
        shape.anchorPoint = Point(0.099,0.004)
        return shape
    }
    
    func aquarius() -> Shape {
        let shape = AstrologicalSignProvider.shared.aquarius().shape!
        shape.anchorPoint = Point(0.0,0.263)
        return shape
    }
    
    func sagittarius() -> Shape {
        let shape = AstrologicalSignProvider.shared.sagittarius().shape!
        shape.anchorPoint = Point(1.0,0.349)
        return shape
    }
    
    func capricorn() -> Shape {
        let shape = AstrologicalSignProvider.shared.capricorn().shape!
        shape.anchorPoint = Point(0.288,0.663)
        return shape
    }
    
    func scorpio() -> Shape {
        let shape = AstrologicalSignProvider.shared.scorpio().shape!
        shape.anchorPoint = Point(0.255,0.775)
        return shape
    }
}
