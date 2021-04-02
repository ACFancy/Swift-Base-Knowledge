//
//  PageViewController.swift
//  Landmarks
//
//  Created by Lee Danatech on 2021/3/26.
//

import SwiftUI
import UIKit

struct PageViewController<Page: View>: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIPageViewController
    
    @Binding var currentPage: Int
    
    var pages: [Page]
    
    func makeUIViewController(context: Context) -> UIPageViewController{
        let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
        pageViewController.dataSource = context.coordinator
        pageViewController.delegate = context.coordinator
        return pageViewController
    }
    
    func updateUIViewController(_ uiViewController: UIPageViewController, context: Context) {
        uiViewController.setViewControllers( [context.coordinator.controllers[currentPage]], direction: .forward, animated: true)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
        var parent: PageViewController
        var controllers = [UIViewController]()
        
        init(_ pageViewController: PageViewController) {
            parent = pageViewController
            controllers = parent.pages.map { UIHostingController(rootView: $0) }
        }
        
        // MARK: - UIPageViewControllerDataSource
        func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
            guard let index = controllers.firstIndex(of: viewController) else {
                return nil
            }
            if index == 0 {
                return controllers.last
            }
            return controllers[index - 1]
        }
        
        func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
            guard let index = controllers.firstIndex(of: viewController) else {
                return nil
            }
            if index + 1 == controllers.count {
                return controllers.first
            }
            return controllers[index + 1]
        }
        
        // MARK: - UIPageViewControllerDelegate
        func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
            guard completed,
                  let visibleViewController = pageViewController.viewControllers?.first,
                  let index = controllers.firstIndex(of: visibleViewController) else {
                return
            }
            parent.currentPage = index
        }
    }
}
