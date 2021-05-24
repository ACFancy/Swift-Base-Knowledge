//
//  UIView+AddRemove.swift
//  Cos
//
//  Created by Lee Danatech on 2021/5/19.
//

import UIKit

extension UIView {
    public func add<T>(_ subview: T?) {
        if let v = subview as? UIView {
            addSubview(v)
        } else if let v = subview as? View {
            addSubview(v.view)
        } else {
            fatalError("xxx")
        }
    }
    
    public func add<T>(_ subviews: [T?]) {
        for subv  in subviews {
            add(subv)
        }
    }
    
    public func remove<T>(_ subview: T?) {
        if let v = subview as? UIView {
            v.removeFromSuperview()
        } else if let v = subview as? View {
            v.view.removeFromSuperview()
        } else {
            fatalError("xx")
        }
    }
    
    public func sendToBack<T>(_ subview: T?) {
        if let v = subview as? UIView {
            sendSubviewToBack(v)
        } else if let v = subview as? View {
            sendSubviewToBack(v.view)
        } else {
            fatalError("xx")
        }
    }
    
    public func bringToFront<T>(_ subview: T?) {
        if let v = subview as? UIView {
            bringSubviewToFront(v)
        } else if let v = subview as? View {
            bringSubviewToFront(v.view)
        } else {
            fatalError("xxx")
        }
    }
}
