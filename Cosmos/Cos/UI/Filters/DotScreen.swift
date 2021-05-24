//
//  DotScreen.swift
//  Cos
//
//  Created by Lee Danatech on 2021/5/19.
//

import CoreImage

public struct DotScreen : Filter {
    public let filterName: String = "CIDotScreen"
    public var center: Point = Point()
    public var width: Double = 2.0
    public var angle: Double = 0
    public var sharpness: Double = 0.5
    
    public init() {}
    
    public func createCoreImageFilter(_ inputImage: CIImage) -> CIFilter {
        let filter = CIFilter(name: filterName)!
        filter.setDefaults()
        filter.setValue(width, forKey: "inputWidth")
        filter.setValue(angle, forKey: "inputAngle")
        filter.setValue(sharpness, forKey: "inputSharpness")
        filter.setValue(CIVector(cgPoint: CGPoint(center)), forKey: "inputCenter")
        filter.setValue(inputImage, forKey: "inputImage")
        return filter
    }
}
