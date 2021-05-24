//
//  CanvasController.swift
//  Cos
//
//  Created by Lee Danatech on 2021/5/19.
//

import UIKit

open class CanvasController : UIViewController {
    open override func viewDidLoad() {
        canvas.backgroundColor = C4Grey
        ShapeLayer.disableActions = true
        setup()
        ShapeLayer.disableActions = false
    }
    
    open func setup() {}
    
    #if os(iOS)
    open override var prefersStatusBarHidden: Bool {
        return true
    }
    #endif
}
