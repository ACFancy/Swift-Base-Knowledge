//
//  ContentView.swift
//  WatchLandmarks Extension
//
//  Created by Lee Danatech on 2021/3/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        LandmarkList()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(ModelData())
    }
}
