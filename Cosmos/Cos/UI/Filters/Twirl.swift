//
//  Twirl.swift
//  Cos
//
//  Created by Lee Danatech on 2021/5/19.
//

import CoreImage

public struct Twirl :  Filter {
    public let filterName: String = "CITwirlDistortion"
    public var center: Point = Point()
    public var radius: Double = 100.0
    public var angle: Double = Double.pi
    
    public init() {}
    
    public func createCoreImageFilter(_ inputImage: CIImage) -> CIFilter {
        let filter = CIFilter(name: filterName)!
        filter.setDefaults()
        filter.setValue(radius, forKey: "inputRadius")
        filter.setValue(angle, forKey: "inputAngle")
        let filterSize = inputImage.extent.size
        let vector = CIVector(x: CGFloat(center.x) * filterSize.width, y: CGFloat(center.y) * filterSize.height)
        filter.setValue(vector, forKey: "inputCenter")
        filter.setValue(inputImage, forKey: "inputImage")
        return filter
    }
}
