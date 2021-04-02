//
//  HikeGraph.swift
//  Landmarks
//
//  Created by Lee Danatech on 2021/3/25.
//

import SwiftUI

extension Animation {
    static func ripple() -> Animation {
        //        .default
        Animation.spring(dampingFraction: 0.5)
            .speed(2)
    }
    
    static func ripple(index: Int) -> Animation {
        Animation.spring(dampingFraction: 0.5)
            .speed(2)
            .delay(0.03 * Double(index))
    }
}

struct HikeGraph: View {
    var hike: Hike
    var path: KeyPath<Hike.Observation, Range<Double>>
    var color: Color {
        switch path {
        case \.elevation:
            return .gray
        case \.heartRate:
            return Color(hue: 0, saturation: 0.5, brightness: 0.7)
        case \.pace:
            return Color(hue: 0.7, saturation: 0.4, brightness: 0.7)
        default:
            return .black
        }
    }
    
    var body: some View {
        let data = hike.observations
        let overallRange = rangeOfRanges(data.lazy.map { $0[keyPath: path] })
        let maxMagnitude = data.map { magnitude(of: $0[keyPath: path]) }.max() ?? 0
        let heightRatio = 1 - CGFloat(maxMagnitude / magnitude(of: overallRange))
        
        return GeometryReader { geometry in
            HStack(alignment: .bottom, spacing: geometry.size.width / 120) {
                ForEach(Array(data.enumerated()), id: \.offset) { index, observation in
                    GraphCapsule(index: index, height: geometry.size.height, range: observation[keyPath: path], overallRange: overallRange)
                        .colorMultiply(color)
                        .transition(.slide)
                        .animation(.ripple(index: index))
                }
                .offset(x: 0, y: geometry.size.height * heightRatio)
            }
        }
    }
}

func rangeOfRanges<C: Collection>(_ ranges: C) -> Range<Double> where C.Element == Range<Double> {
    guard !ranges.isEmpty else {
        return 0..<0
    }
    let low = ranges.lazy.map { $0.lowerBound }.min() ?? 0
    let hight = ranges.lazy.map { $0.upperBound }.max() ?? 0
    return low..<hight
}

func magnitude(of range: Range<Double>) -> Double {
    return range.upperBound - range.lowerBound
}

struct HikeGraph_Previews: PreviewProvider {
    
    static var hike = ModelData().hikes[0]
    
    static var previews: some View {
        Group {
            HikeGraph(hike: hike, path: \.elevation)
            HikeGraph(hike: hike, path: \.heartRate)
            HikeGraph(hike: hike, path: \.pace)
        }
    }
}
