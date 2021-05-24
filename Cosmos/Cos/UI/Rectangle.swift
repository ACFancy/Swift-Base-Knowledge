//
//  Rectangle.swift
//  Cos
//
//  Created by Lee Danatech on 2021/5/19.
//

import Foundation
import CoreGraphics

public class Rectangle : Shape {
    public var corner: Size = Size(8, 8) {
        didSet {
            updatePath()
        }
    }
    
    public override init() {
        super.init()
    }
    
    public override init(frame: Rect) {
        super.init()
        if frame.width <= corner.width * 2 || frame.height <= corner.width / 2 {
            corner = Size()
        }
        view.frame = CGRect(frame)
        updatePath()
    }
    
    override func updatePath() {
        let newPath = Path()
        newPath.addRoundedRect(bounds, cornerWidth: corner.width, cornerHeight: corner.height)
        path = newPath
    }
}
