//
//  Image+Filter.swift
//  Cos
//
//  Created by Lee Danatech on 2021/5/19.
//

import QuartzCore
import UIKit

extension Image {
    public func apply(_ filter: Filter) {
        apply(filters: [filter])
    }
    
    public func apply(filters: [Filter]) {
        for filter in filters {
            let cifilter = filter.createCoreImageFilter(output)
            if let outputImage = cifilter.outputImage {
                output = outputImage
            } else {
                debugPrint("Failed to generate outputImage: \(#function)")
            }
        }
        self.renderFilteredImage()
    }
    
    func renderFilteredImage() {
        var extent = output.extent
        if extent.isInfinite {
            extent = ciImage.extent
        }
        let filterContext = CIContext(options: nil)
        let filteredImage = filterContext.createCGImage(output, from: extent)
        DispatchQueue.main.async {
            self.imageView.layer.contents = filteredImage
        }
    }
}
