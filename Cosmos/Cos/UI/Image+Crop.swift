//
//  Image+Crop.swift
//  Cos
//
//  Created by Lee Danatech on 2021/5/19.
//

import QuartzCore
import UIKit

extension Image {
    public func crop(_ rect: Rect) {
        let intersection = CGRect(rect).intersection(CGRect(self.bounds))
        if intersection.isNull {
            return
        }
        let inputRectangle = CGRect(x: intersection.minX,
                                    y: CGFloat(self.height) - intersection.maxY,
                                    width: intersection.width,
                                    height: intersection.height)
        let crop = CIFilter(name: "CICrop")!
        crop.setDefaults()
        crop.setValue(CIVector(cgRect: inputRectangle), forKey: "inputRectangle")
        crop.setValue(ciImage, forKey: "inputImage")
        if let outputImage = crop.outputImage {
            output = outputImage
            imageView.image = UIImage(ciImage: output)
            frame = Rect(intersection)
        } else {
            debugPrint("Failed to generate outputImage: \(#function)")
        }
    }
}
