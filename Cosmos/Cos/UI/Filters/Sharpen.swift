//
//  Sharpen.swift
//  Cos
//
//  Created by Lee Danatech on 2021/5/19.
//

import CoreImage

public struct Sharpen : Filter {
    public let filterName: String = "CISharpenLuminance"

    public var sharpness: Double = 0.4

    public init() {}

    public func createCoreImageFilter(_ inputImage: CIImage) -> CIFilter {
        let filter = CIFilter(name: filterName)!
        filter.setDefaults()
        filter.setValue(sharpness, forKey: "inputSharpness")
        filter.setValue(inputImage, forKey: "inputImage")
        return filter
    }
}
