//
//  WorkSpace.swift
//  Cosmos
//
//  Created by Lee Danatech on 2021/5/17.
//

import UIKit
import Cos

let cosmosprpl = Color(red:0.565, green: 0.075, blue: 0.996, alpha: 1.0)
let cosmosblue = Color(red: 0.094, green: 0.271, blue: 1.0, alpha: 1.0)
let cosmosbkgd = Color(red: 0.078, green: 0.118, blue: 0.306, alpha: 1.0)

class WorkSpace : CanvasController {
    let stars = Stars()
    let menu = Menu()
    let info = InfoPanel()
    let audio1 = AudioPlayer("audio1.mp3")
    let audio2 = AudioPlayer("audio2.mp3")

    override func setup() {
        canvas.backgroundColor = cosmosbkgd
        canvas.add(stars.canvas)
        menu.canvas.center = canvas.center
        canvas.add(menu.canvas)
        canvas.add(info.canvas)

        menu.selectionAction = stars.goto
        menu.infoAction = info.show

        audio1?.loops = true
        audio1?.play()

        audio2?.loops = true
        audio2?.play()
    }
}
