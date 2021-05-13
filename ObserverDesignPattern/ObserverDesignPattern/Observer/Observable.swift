//
//  Observable.swift
//  ObserverDesignPattern
//
//  Created by Lee Danatech on 2021/5/12.
//

import UIKit

extension Notification.Name {
    static let networkConnection = Notification.Name("networkConnection")
    static let batteryStatus = Notification.Name("batteryStatus")
    static let locationChange = Notification.Name("locationChange")
}

enum NetworkConnectionStatus: String {
    case connected
    case disconnected
    case connecting
    case disconnecting
    case error
}

enum StatusKey: String {
    case networkStatusKey
}

protocol ObserverProtocol {
    var statusValue: String { get set }
    var statusKey: String { get }
    var notificationOfInterest: NSNotification.Name { get }
    func subscribe()
    func unsubscribe()
    func handleNotification()
}

class Observer:ObserverProtocol {
    
    var statusValue: String
    let statusKey: String
    let notificationOfInterest: NSNotification.Name
    
    init(statusKey: StatusKey, notification: Notification.Name) {
        statusValue = "N/A"
        self.statusKey = statusKey.rawValue
        self.notificationOfInterest = notification
        subscribe()
    }
    
    func subscribe() {
        NotificationCenter.default.addObserver(self, selector: #selector(receiveNotification(_:)), name: notificationOfInterest, object: nil)
    }
    
    func unsubscribe() {
        NotificationCenter.default.removeObserver(self)
    }
    
    func handleNotification() {
        fatalError("Error : you must ovverride the [handleNotification] ")
    }
    
    deinit {
        unsubscribe()
    }
}

extension Observer {
    // MARK: - Private Functions
    @objc private func receiveNotification(_ notification: Notification) {
        guard let userInfo = notification.userInfo, let status = userInfo[statusKey] as? String else {
            return
        }
        statusValue = status
        handleNotification()
    }
}


class NetworkConnectionHandler: Observer {
    var view: UIView
    
    init(view: UIView, statusKey: StatusKey, notification: Notification.Name) {
        self.view = view
        super.init(statusKey: statusKey, notification: notification)
    }
    
    override func handleNotification() {
        view.backgroundColor = statusValue == NetworkConnectionStatus.connected.rawValue ?  .green : .red
    }
}

protocol ObservedProtocol {
    var statusKey: StatusKey { get }
    var notification: NSNotification.Name { get }
    func notifyObservers(about changeTo:String)
}


extension ObservedProtocol {
    func notifyObservers(about changeTo:String) {
        NotificationCenter.default.post(name: notification, object: self, userInfo: [statusKey.rawValue : changeTo])
    }
}



