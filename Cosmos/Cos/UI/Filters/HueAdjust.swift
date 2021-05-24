//
//  HueAdjust.swift
//  Cos
//
//  Created by Lee Danatech on 2021/5/19.
//

import CoreImage

public struct Hue : Filter {
    public let filterName: String = "CIHueAdjust"
    public var angle: Double = 1.0

    public init() {}

    public func createCoreImageFilter(_ inputImage: CIImage) -> CIFilter {
        let filter = CIFilter(name: filterName)!
        filter.setDefaults()
        filter.setValue(angle, forKey: "inputAngle")
        filter.setValue(inputImage, forKey: "inputImage")
        return filter
    }
}
