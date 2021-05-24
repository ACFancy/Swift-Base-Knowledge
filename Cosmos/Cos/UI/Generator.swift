//
//  Generator.swift
//  Cos
//
//  Created by Lee Danatech on 2021/5/19.
//

import CoreImage

public protocol Generator {
    var filterName: String { get }

    func createCoreImageFilter() -> CIFilter
}
