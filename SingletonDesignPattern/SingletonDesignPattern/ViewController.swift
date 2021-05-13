//
//  ViewController.swift
//  SingletonDesignPattern
//
//  Created by Lee Danatech on 2021/5/12.
//

import UIKit

class ViewController: UIViewController {
    // MARK: - Properties
    @IBOutlet weak var passwprdTextField: UITextField!
    
    @IBOutlet weak var passwordVisibleSwitch: UISwitch!
}

extension ViewController {
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let isPasswordVisible = UserPreferences.shared.isPasswordVisible()
        passwprdTextField.isSecureTextEntry = !isPasswordVisible
        passwordVisibleSwitch.isOn = isPasswordVisible
    }
}

extension ViewController {
    // MARK: - Action Functions
    @IBAction func passwordVisibleSwitched(_ sender: UISwitch) {
        passwprdTextField.isSecureTextEntry = !sender.isOn
        UserPreferences.shared.setPasswordVisibity(sender.isOn)
    }
}
