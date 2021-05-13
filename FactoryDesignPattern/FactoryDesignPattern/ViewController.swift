//
//  ViewController.swift
//  FactoryDesignPattern
//
//  Created by Lee Danatech on 2021/5/12.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func drawCircle(_ sender: Any) {
        createShape(.circle, on: view)
    }

    @IBAction func drawSquare(_ sender: Any) {
        createShape(.square, on: view)
    }

    @IBAction func drawRectangle(_ sender: Any) {
        //        createShape(.rectangle, on: view)
        let  rectangle = getShape(.rectangle, on: view)
        rectangle.display()
    }
}

