//
//  Filter.swift
//  Cos
//
//  Created by Lee Danatech on 2021/5/19.
//

import CoreImage

public protocol Filter {
    var filterName: String { get }
    func createCoreImageFilter(_ inputImage: CIImage) -> CIFilter
}
