//
//  Triangle.swift
//  Cos
//
//  Created by Lee Danatech on 2021/5/19.
//

import Foundation

public class Triangle : Polygon {
    public override init(_ points: [Point]) {
        assert(points.count >= 3, "xxxx")
        super.init(points)
        fillColor = C4Blue
        close()
    }
}
