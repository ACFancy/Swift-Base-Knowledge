//
//  LinearGradient.swift
//  Cos
//
//  Created by Lee Danatech on 2021/5/19.
//

import CoreImage

public struct LinearGradient : Filter {
    public let filterName: String = "CISmoothLinearGradient"
    public var colors: [Color] = [C4Pink, C4Blue]
    public var points: [Point] = [Point(), Point(100, 100)]

    public init() {}


    public func createCoreImageFilter(_ inputImage: CIImage) -> CIFilter {
        let filter = CIFilter(name: filterName)!
        filter.setDefaults()
        filter.setValue(CIColor(colors[0]), forKey: "inputColor0")
        filter.setValue(CIColor(colors[1]), forKey: "inputColor1")
        filter.setValue(CIVector(cgPoint: CGPoint(points[0])), forKey: "inputPoint0")
        filter.setValue(CIVector(cgPoint: CGPoint(points[1])), forKey: "inputPoint1")
        return filter
    }
}
