//
//  ContentView.swift
//  SwiftUIAsync
//
//  Created by Lee Danatech on 2021/11/26.
//

import SwiftUI

struct ContentView: View {
    @State private var result = ""
    @State private var loading = true
    /**
     “task modifier 的任务上下文将和它所修饰的 View 的生命周期绑定：当被修饰的 View identifier 改变 (比如被其他 View 取代) 或者被从屏幕上移除时时，task 所关联的任务也将被取消；而 onAppear 和 Task.init 所创建的任务，则和 View 的生命周期无关”

     */

    var body: some View {
//        if loading {
//            ProgressView()
//                .task {
//                    let value = try? await load()
//                    result = value ?? "aaha"
//                    loading = false
//                }
//        }
//        //        Text(result).foregroundColor(.blue)
//        Text(result).onAppear { loading = false }

        /// “在 onAppear 中管理自己的 Task”
//        if loading {
//            ProgressView()
//                .onAppear {
//                    Task {
//                        let value = try? await load()
//                        result = value ?? "xxxs"
//                        loading = false
//                    }
//                }
//        }
//        Text(result).foregroundColor(.red)

        /// “保持任务不被取消的一种更推荐的方法，是保持 View 的稳定：不再使用 if loading 语句来真正地移除一个 View，而只是使用 modifier 来控制 View 的视觉效果”
        ProgressView()
            .opacity(loading ? 1.0 : 0.0)
            .task {
                let value = try? await load()
                result = value ?? "xxgg"
                loading = false
            }
        Text(result).foregroundColor(.brown).frame(width: 100, height: 50, alignment: .center)
    }

    func load() async throws -> String {
        debugPrint(CACurrentMediaTime())
        /// “和无条件等待完成的 Task.sleep(:_) 不同，Task.sleep(nanoseconds:) 将尊重 Task 的取消，并在被取消时暂停休眠并抛出错误”.
        try await Task.sleep(nanoseconds: NSEC_PER_SEC)
        debugPrint(CACurrentMediaTime())
        return "XXXX"
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

//extension View {
//    func task(_ action: @escaping() async -> Void) -> some View
//}
