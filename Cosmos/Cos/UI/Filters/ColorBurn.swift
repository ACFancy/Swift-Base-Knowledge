//
//  ColorBurn.swift
//  Cos
//
//  Created by Lee Danatech on 2021/5/19.
//

import CoreImage

public struct ColorBurn : Filter {
    public let filterName: String = "CIColorBurnBlendMode"
    public var background: Image = Image()

    public init() {}

    public func createCoreImageFilter(_ inputImage: CIImage) -> CIFilter {
        let filter = CIFilter(name: filterName)!
        filter.setDefaults()
        filter.setValue(inputImage, forKey: "inputImage")
        filter.setValue(background.ciImage, forKey: "inputBackgroundImage")
        return filter
    }
}
