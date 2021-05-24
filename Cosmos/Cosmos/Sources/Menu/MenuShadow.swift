//
//  MenuShadow.swift
//  Cosmos
//
//  Created by Lee Danatech on 2021/5/21.
//

import UIKit
import Cos

public class MenuShadow : CanvasController {
    var reveal: ViewAnimation?
    var hide: ViewAnimation?
    
    
    public override func setup() {
        canvas.frame = Rect(UIScreen.main.bounds)
        canvas.backgroundColor = black
        canvas.opacity = 0
        createShadowAnimations()
    }
    
    func createShadowAnimations() {
        reveal = ViewAnimation(duration: 0.25, animations: {
            self.canvas.opacity = 0.44
        })
        reveal?.curve = .easeOut
        hide = ViewAnimation(duration: 0.25, animations: {
            self.canvas.opacity = 0
        })
        hide?.curve = .easeOut
    }
}
