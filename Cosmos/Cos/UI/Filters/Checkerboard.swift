//
//  Checkerboard.swift
//  Cos
//
//  Created by Lee Danatech on 2021/5/19.
//

import CoreImage

public struct Checkerboard : Filter {
    public let filterName: String = "CICheckerboardGenerator"

    public var colors: [Color] = [C4Pink, C4Blue]

    public var center: Point = Point()

    public var sharpness: Double = 1

    public  var width: Double = 5.0

    public init() {}

    public func createCoreImageFilter(_ inputImage: CIImage) -> CIFilter {
        let filter = CIFilter(name: filterName)!
        filter.setDefaults()
        filter.setValue(CIColor(colors[0]), forKey: "inputColor0")
        filter.setValue(CIColor(colors[1]), forKey: "inputColor1")
        filter.setValue(width, forKey: "inputWidth")
        filter.setValue(CIVector(cgPoint: CGPoint(center)), forKey: "inputCenter")
        filter.setValue(sharpness, forKey: "inputSharpness")
        return filter
    }
}
