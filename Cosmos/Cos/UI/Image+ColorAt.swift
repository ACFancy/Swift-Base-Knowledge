//
//  Image+ColorAt.swift
//  Cos
//
//  Created by Lee Danatech on 2021/5/19.
//

import Foundation
import CoreGraphics

public extension Image {
    func cgimage(at point: CGPoint) -> CGImage? {
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)
        
        guard let offscreenContext = CGContext(data: nil, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 0, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: bitmapInfo.rawValue) else {
            debugPrint("Could not create offscreenContext")
            return nil
        }
        offscreenContext.translateBy(x: CGFloat(-point.x), y: CGFloat(-point.y))
        layer?.render(in: offscreenContext)
        guard let image = offscreenContext.makeImage() else {
            debugPrint("Could not create pixel image")
            return nil
        }
        return image
    }
    
    func color(at point: Point) -> Color {
        guard bounds.contains(point) else {
            debugPrint("Point is outside the image bounds")
            return clear
        }
        guard let pixelImage = cgimage(at: CGPoint(point)) else {
            debugPrint("Could not create pixel Image from CGImage")
            return clear
        }
        let imageProvider = pixelImage.dataProvider
        let imageData = imageProvider?.data
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(imageData)
        return Color(red: Double(data[1]) / 255.0,
                     green: Double(data[2]) / 255.0,
                     blue: Double(data[3]) / 255.0,
                     alpha: Double(data[4]) / 255.0)
    }
}
