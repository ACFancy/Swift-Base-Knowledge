//
//  GaussianBlur.swift
//  Cos
//
//  Created by Lee Danatech on 2021/5/19.
//

import CoreImage

public struct GaussianBlur : Filter {
    public let filterName: String = "CIGaussianBlur"
    public var radius: Double
    public init(radius: Double = 5.0) {
        self.radius = radius
    }

    public func createCoreImageFilter(_ inputImage: CIImage) -> CIFilter {
        let filter = CIFilter(name: filterName)!
        filter.setDefaults()
        filter.setValue(radius, forKey: "inputRadius")
        filter.setValue(inputImage, forKey: "inputImage")
        return filter
    }
}
