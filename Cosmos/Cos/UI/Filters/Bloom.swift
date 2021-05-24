//
//  Bloom.swift
//  Cos
//
//  Created by Lee Danatech on 2021/5/19.
//

import CoreImage

public struct Bloom : Filter {
    public let filterName: String = "CIBloom"

    public var radius: Double = 10.0

    public var intensity: Double = 1.0

    public init() {}


    public func createCoreImageFilter(_ inputImage: CIImage) -> CIFilter {
        let filter = CIFilter(name: filterName)!
        filter.setDefaults()
        filter.setValue(radius, forKey: "inputRadius")
        filter.setValue(intensity, forKey: "inputIntensity")
        filter.setValue(inputImage, forKey: "inputImage")
        return filter
    }
}
