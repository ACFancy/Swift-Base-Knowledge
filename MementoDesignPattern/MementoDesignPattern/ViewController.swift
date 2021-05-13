//
//  ViewController.swift
//  MemntoDesignPattern
//
//  Created by Lee Danatech on 2021/5/13.
//

import UIKit

class ViewController: UIViewController {
    // MARK: - Properties
    @IBOutlet weak var firstNameTextFiled: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var ageTextField: UITextField!

    private let stateName: String = "userKey"

    @IBAction func saveUserTapped(_ sender: UIButton) {
        guard let firstName = firstNameTextFiled.text,
              let lastName = lastNameTextField.text,
              let age = ageTextField.text,
              !firstName.isEmpty, !lastName.isEmpty, !age.isEmpty else {
            return
        }
        let user = User(firstName: firstName, lastName: lastName, age: age, stateName: stateName)
        user.show()
    }

    @IBAction func restoreUserTapped(_ sender: UIButton) {
        let user = User(stateName: stateName)
        firstNameTextFiled.text = user.firstName
        lastNameTextField.text = user.lastName
        ageTextField.text = user.age
    }
}

extension ViewController {
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

