import UIKit
import PlaygroundSupport

public class TrafficLight {
    public enum State {
        case stop
        case proceed
        case caution
    }

    public enum GreenLightColor {
        case green
        case turquoise
    }
    public var preferredGreenLightColor: GreenLightColor = .green

    public private(set) var state: State = .stop {
        didSet {
            onStateChanged?(state)
        }
    }

    public var onStateChanged: ((State) -> Void)?

    public var stopDuration = 4.0
    public var proceedDuration = 6.0
    public var cautionDuration = 1.5

    private var timer: Timer?

    private func turnState(_ state: State) {
        switch state {
        case .proceed:
            timer = Timer.scheduledTimer(withTimeInterval: proceedDuration, repeats: false) { _ in
                self.turnState(.caution)
            }
        case .caution:
            timer = Timer.scheduledTimer(withTimeInterval: cautionDuration, repeats: false) { _ in
                self.turnState(.stop)
            }
        case .stop:
            timer = Timer.scheduledTimer(withTimeInterval: stopDuration, repeats: false) { _ in
                self.turnState(.proceed)
            }
        }
        self.state = state
    }

    public func start() {
        guard timer == nil else { return }
        turnState(.stop)
    }

    public func stop() {
        timer?.invalidate()
        timer = nil
    }
}

extension TrafficLight.GreenLightColor {
    var color: UIColor {
        switch self {
        case .green:
            return .green
        case .turquoise:
            return UIColor(red: 0.25, green: 0.88, blue: 0.82, alpha: 1.0)
        }
    }
}

class ViewController: UIViewController {
    var light: TrafficLight?

    deinit {
        light?.stop()
    }

    override func loadView() {
        let view = UIView()
        view.backgroundColor = .white
        self.view = view
        light = TrafficLight()
        light?.preferredGreenLightColor = .turquoise
        light?.onStateChanged = { [weak self, weak light] state in
            guard let self = self, let light = light else {
                return
            }
            let color: UIColor
            switch state {
            case .proceed: color = light.preferredGreenLightColor.color
            case .caution: color = .yellow
            case .stop: color = .red
            }
            UIView.animate(withDuration: 0.25) {
                self.view.backgroundColor = color
            }
        }
        light?.start()
    }
}


PlaygroundPage.current.liveView = ViewController()

//: MARK - Optional Pattern
public protocol TrafficLightOption {
    associatedtype Value

    /// 默认选项值
    static var defaultValue: Value { get }
}

public class TrafficLight2 {
    private var options = [ObjectIdentifier: Any]()

    public subscript<T: TrafficLightOption>(option type: T.Type) -> T.Value {
        get {
            options[ObjectIdentifier(type)] as? T.Value ?? type.defaultValue
        }
        set {
            options[ObjectIdentifier(type)] = newValue
        }
    }

    public enum State {
        case stop
        case proceed
        case caution
    }

    public enum GreenLightColor: TrafficLightOption {
        case green
        case turquoise

        public static let defaultValue: GreenLightColor = .green
    }

    public private(set) var state: State = .stop {
        didSet {
            onStateChanged?(state)
        }
    }

    public var onStateChanged: ((State) -> Void)?

    public var stopDuration = 4.0
    public var proceedDuration = 6.0
    public var cautionDuration = 1.5

    private var timer: Timer?

    private func turnState(_ state: State) {
        switch state {
        case .proceed:
            timer = Timer.scheduledTimer(withTimeInterval: proceedDuration, repeats: false) { _ in
                self.turnState(.caution)
            }
        case .caution:
            timer = Timer.scheduledTimer(withTimeInterval: cautionDuration, repeats: false) { _ in
                self.turnState(.stop)
            }
        case .stop:
            timer = Timer.scheduledTimer(withTimeInterval: stopDuration, repeats: false) { _ in
                self.turnState(.proceed)
            }
        }
        self.state = state
    }

    public func start() {
        guard timer == nil else { return }
        turnState(.stop)
    }

    public func stop() {
        timer?.invalidate()
        timer = nil
    }
}

extension TrafficLight2 {
    public var preferredGreenLightColor: TrafficLight2.GreenLightColor {
        get { self[option: GreenLightColor.self] }
        set { self[option: GreenLightColor.self] = newValue }
    }
}

extension TrafficLight2.GreenLightColor {
    var color: UIColor {
        switch self {
        case .green:
            return .green
        case .turquoise:
            return UIColor(red: 0.25, green: 0.88, blue: 0.82, alpha: 1.00)
        }
    }
}

class ViewController2: UIViewController {
    var light: TrafficLight2?

    deinit {
        light?.stop()
    }

    override func loadView() {
        let view = UIView()
        view.backgroundColor = .white
        self.view = view
        light = TrafficLight2()
        light?.preferredGreenLightColor = .turquoise
        light?.onStateChanged = { [weak self, weak light] state in
            guard let self = self, let light = light else {
                return
            }
            let color: UIColor
            switch state {
            case .proceed: color = light.preferredGreenLightColor.color
            case .caution: color = .yellow
            case .stop: color = .red
            }
            UIView.animate(withDuration: 0.25) {
                self.view.backgroundColor = color
            }
        }
        light?.start()
    }
}

PlaygroundPage.current.liveView = ViewController2()
