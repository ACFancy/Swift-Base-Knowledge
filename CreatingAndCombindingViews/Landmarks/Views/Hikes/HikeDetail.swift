//
//  HikeDetail.swift
//  Landmarks
//
//  Created by Lee Danatech on 2021/3/25.
//

import SwiftUI

struct HikeDetail: View {
    let hike: Hike
    @State var dateToShow = \Hike.Observation.elevation
    var buttons = [
        ("Elevation", \Hike.Observation.elevation),
        ("Heart Rate", \Hike.Observation.heartRate),
        ("Pace", \Hike.Observation.pace)
    ]
    
    var body: some View {
        return VStack {
            HikeGraph(hike: hike, path: dateToShow)
                .frame(height: 200)
            
            HStack(spacing: 25) {
                ForEach(buttons, id: \.0) { value in
                    Button(action: {
                        self.dateToShow = value.1
                    }) {
                        Text(value.0)
                            .font(.system(size: 15))
                            .foregroundColor(value.1 == self.dateToShow ? .gray : .accentColor)
                            .animation(nil)
                    }
                }
            }
        }
    }
}

struct HikeDetail_Previews: PreviewProvider {
    static var previews: some View {
        HikeDetail(hike: ModelData().hikes[0])
    }
}
