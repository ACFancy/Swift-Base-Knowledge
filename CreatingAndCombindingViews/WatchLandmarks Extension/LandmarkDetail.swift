//
//  LandmarkDetail.swift
//  WatchLandmarks Extension
//
//  Created by Lee Danatech on 2021/3/26.
//

import SwiftUI

struct LandmarkDetail: View {
    @EnvironmentObject var modelData: ModelData
    
    var landmark: Landmark
    
    var landmarkIndex: Int {
        modelData.landmarks.firstIndex(where: { $0.id == landmark.id
        }) ?? 0
    }
    
    var body: some View {
        ScrollView {
            VStack {
                CircleImage(image: landmark.image.resizable())
                    .scaledToFit()
                
                Text(landmark.name)
                    .font(.headline)
                    .lineLimit(0)
                
                Toggle(isOn: $modelData.landmarks[landmarkIndex].isFavorite) {
                    Text("Favorite")
                }
                
                Divider()
                
                Text(landmark.park)
                    .font(.caption)
                    .bold()
                    .lineLimit(0)
                
                Text(landmark.state)
                    .font(.caption)
                
                Divider()
                
                MapView(coordinate: landmark.locationCoordinate)
                    .scaledToFit()
                
            }
            .padding(16)
        }
        .navigationTitle("Landmarks")
    }
}

struct LandmarkDetail_Previews: PreviewProvider {
    static var previews: some View {
        let modelData = ModelData()
        Group {
            LandmarkDetail(landmark: ModelData().landmarks[0])
                .environmentObject(modelData)
                .previewDevice("Apple Watch Series 5 - 44m")
            LandmarkDetail(landmark: ModelData().landmarks[1])
                .environmentObject(modelData)
                .previewDevice("Apple Watch Series 5 - 44m")
        }
        
    }
}
