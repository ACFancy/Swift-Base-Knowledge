//
//  Image+Generator.swift
//  Cos
//
//  Created by Lee Danatech on 2021/5/19.
//

import QuartzCore
import UIKit

extension Image {
    public func generate(_ generator: Generator) {
        let crop = CIFilter(name: "CICrop")!
        crop.setDefaults()
        crop.setValue(CIVector(cgRect: CGRect(bounds)), forKey: "inputRectangle")
        let generatorFilter = generator.createCoreImageFilter()
        crop.setValue(generatorFilter.outputImage, forKey: "inputImage")
        
        if var outputImage = crop.outputImage {
            let scale = CGAffineTransform(scaleX: 1, y: -1)
            outputImage = outputImage.transformed(by: scale)
            output = outputImage
            
            let cgimg = CIContext().createCGImage(output, from: output.extent)
            imageView.image = UIImage(cgImage: cgimg!)
            _originalSize = Size(output.extent.size)
        } else {
            debugPrint("Failed to generate outputImage: \(#function)")
        }
    }
}
