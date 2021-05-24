//
//  Sepia.swift
//  Cos
//
//  Created by Lee Danatech on 2021/5/19.
//

import CoreImage

public struct Sepia : Filter {
    public let filterName: String = "CISepiaTone"
    public var intensity: Double = 1.0

    public init() {}

    public init(intensity: Double) {
        self.intensity = intensity
    }

    public func createCoreImageFilter(_ inputImage: CIImage) -> CIFilter {
        let filter = CIFilter(name: filterName)!
        filter.setDefaults()
        filter.setValue(intensity, forKey: "inputIntensity")
        filter.setValue(inputImage, forKey: "inputImage")
        return filter
    }

}
