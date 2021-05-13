//
//  Memento.swift
//  MementoDesignPattern
//
//  Created by Lee Danatech on 2021/5/13.
//

import Foundation

protocol Memento : AnyObject {
    var stateName: String { get }
    var state: [String: String] { get set }
    
    func save()
    func restore()
    func persist()
    func recover()
    func show()
}

extension Memento {
    func save() {
        UserDefaults.standard.set(state, forKey: stateName)
    }
    
    func restore() {
        guard let dictionary = UserDefaults.standard.object(forKey: stateName) as? [String: String] else {
            state.removeAll()
            return
        }
        state = dictionary
    }
    
    func show() {
        var line = ""
        if !state.isEmpty {
            line = state.reduce("") { $0 + $1.key + ":" + $1.value + "\n" }
            debugPrint(line)
        } else {
            debugPrint("Empty entity.\n")
        }
    }
}

class User: Memento {
    let stateName: String
    var state: [String : String]
    
    var firstName: String
    var lastName: String
    var age: String
    
    init(firstName: String, lastName: String, age: String, stateName: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.age = age
        self.stateName = stateName
        self.state = [:]
        persist()
    }
    
    init(stateName: String) {
        self.stateName = stateName
        state = [:]
        
        firstName = ""
        lastName = ""
        age = ""
        
        recover()
    }
    
    func persist() {
        state["firstName"] = firstName
        state["lastName"] = lastName
        state["age"] = age
        save()
    }
    
    func recover() {
        restore()
        guard !state.isEmpty else {
            firstName = ""
            lastName = ""
            age = ""
            return
        }
        firstName = state["firstName"] ?? ""
        lastName = state["lastName"] ?? ""
        age = state["age"] ?? ""
    }
}
