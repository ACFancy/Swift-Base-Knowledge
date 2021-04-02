//
//  LandmarkList.swift
//  Landmarks
//
//  Created by Lee Danatech on 2021/3/24.
//

import SwiftUI

struct LandmarkList: View {
    @EnvironmentObject var modelData: ModelData
    @State private var showFavoritesOnly = false
    @State private var filter = FilterCategory.all
    @State private var selectedLandmark: Landmark?
    
    enum FilterCategory: String, CaseIterable, Identifiable {
        case all = "All"
        case lakes = "Lakes"
        case rivers = "Rivers"
        case mountains = "Mountains"
        
        var id: FilterCategory { self }
    }
    
    var filteredLandmarks: [Landmark] {
        modelData.landmarks.filter {
            (!showFavoritesOnly || $0.isFavorite) && (filter == .all || filter.rawValue == $0.category.rawValue)
        }
    }
    
    var title: String {
        let title = filter == .all ? "Landmarks" : filter.rawValue
        return showFavoritesOnly ? "Favorite \(title)" :  title
    }
    
    var index: Int? {
        modelData.landmarks.firstIndex(where: { $0.id == selectedLandmark?.id })
    }
    
    var body: some View {
        NavigationView {
            #if os(macOS)
            List(selection: $selectedLandmark) {
                ForEach(filteredLandmarks) { landmark in
                    NavigationLink(
                        destination: LandmarkDetail(landmark: landmark)) {
                        LandmarkRow(landmark: landmark)
                    }
                    .tag(landmark)
                }
            }
            .navigationTitle(title)
            .frame(width: 300)
            .toolbar {
                ToolbarItem {
                    Menu(content: {
                        Picker("Category", selection: $filter) {
                            ForEach(FilterCategory.allCases) { category in
                                Text(category.rawValue).tag(category)
                            }
                        }
                        .pickerStyle(InlinePickerStyle())
                        
                        Toggle(isOn: $showFavoritesOnly, label: {
                            Label("Favorites only", systemImage: "star.fill")
                        })
                    }) {
                        Label("Filter", systemImage: "slider.horizontal.3")
                    }
                }
            }
            #else
            List(selection: $selectedLandmark) {
                ForEach(filteredLandmarks) { landmark in
                    NavigationLink(
                        destination: LandmarkDetail(landmark: landmark)) {
                        LandmarkRow(landmark: landmark)
                    }
                    .tag(landmark)
                }
            }
            .navigationTitle(title)
            .toolbar {
                ToolbarItem {
                    Menu(content: {
                        Picker("Category", selection: $filter) {
                            ForEach(FilterCategory.allCases) { category in
                                Text(category.rawValue).tag(category)
                            }
                        }
                        .pickerStyle(InlinePickerStyle())
                        
                        Toggle(isOn: $showFavoritesOnly, label: {
                            Label("Favorites only", systemImage: "star.fill")
                        })
                    }) {
                        Label("Filter", systemImage: "slider.horizontal.3")
                    }
                }
            }
            #endif
            
            Text("Select a Landmark")
        }
        .focusedValue(\.selectedLandmark, $modelData.landmarks[index ?? 0])
    }
}

struct LandmarkList_Previews: PreviewProvider {
    static var previews: some View {
        LandmarkList()
            .environmentObject(ModelData())
        //        ForEach(["iPhone SE (2nd generation)", "iPhone XS Max"], id: \.self) { deviceName in
        //                   LandmarkList()
        //                    .environmentObject(ModelData())
        //                       .previewDevice(PreviewDevice(rawValue: deviceName))
        //                    .previewDisplayName(deviceName)
        //               }
    }
}
