//
//  PageControl.swift
//  Landmarks
//
//  Created by Lee Danatech on 2021/3/26.
//

import SwiftUI
import UIKit

struct PageControl: UIViewRepresentable {
    typealias UIViewType = UIPageControl
    
    var numberOfPages: Int
    
    @Binding var currentPage: Int
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> UIPageControl {
        let control = UIPageControl()
        control.numberOfPages = numberOfPages
        control.addTarget(context.coordinator, action: #selector(Coordinator.updateCurrentPage(sender:)), for: .valueChanged)
        return control
    }
    
    func updateUIView(_ uiView: UIPageControl, context: Context) {
        uiView.currentPage = currentPage
    }
    
    class Coordinator: NSObject {
        let control: PageControl
        
        init(_ pageControl: PageControl) {
            control = pageControl
        }
        
        @objc func updateCurrentPage(sender: UIPageControl) {
            control.currentPage = sender.currentPage
        }
    }
}
