//
//  ViewController.swift
//  ObserverDesignPattern
//
//  Created by Lee Danatech on 2021/5/12.
//

import UIKit

class ViewController: UIViewController, ObservedProtocol {
    // MARK: - Properties
    @IBOutlet weak var topBox: UIView!
    @IBOutlet weak var middleBox: UIView!
    @IBOutlet weak var bottomBox: UIView!
    
    var networkConnectionHandler0: NetworkConnectionHandler?
    var networkConnectionHandler1: NetworkConnectionHandler?
    var networkConnectionHandler2: NetworkConnectionHandler?
    
    let statusKey: StatusKey = .networkStatusKey
    let notification: Notification.Name = .networkConnection
    
    override func viewDidLoad() {
        super.viewDidLoad()
        networkConnectionHandler0 = NetworkConnectionHandler(view: topBox, statusKey: statusKey, notification: notification)
        networkConnectionHandler1 = NetworkConnectionHandler(view: middleBox, statusKey: statusKey, notification: notification)
        networkConnectionHandler2 = NetworkConnectionHandler(view: bottomBox, statusKey: statusKey, notification: notification)
    }
    
    @IBAction func swtichChange(_ sender: UISwitch) {
        notifyObservers(about: sender.isOn ? NetworkConnectionStatus.connected.rawValue : NetworkConnectionStatus.disconnected.rawValue)
    }
}
