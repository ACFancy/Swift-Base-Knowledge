//
//  UIViewController+C4View.swift
//  Cos
//
//  Created by Lee Danatech on 2021/5/19.
//

import Foundation
import ObjectiveC
import UIKit

private var canvasAssociationKey: UInt8 = 0

public extension UIViewController {
    var canvas: View {
        if let canvas = objc_getAssociatedObject(self, &canvasAssociationKey) as? View {
            return canvas
        }
        
        let canvas = View(view: view)
        objc_setAssociatedObject(self, &canvasAssociationKey, canvas, .OBJC_ASSOCIATION_RETAIN)
        return canvas
    }
}
