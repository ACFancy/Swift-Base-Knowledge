import Foundation

struct Video: Decodable {
    let id: Int
    let title: String
    let commentEnabled: Bool?
}

struct Video2: Decodable {
    let id: Int
    let title: String
    var commentEnabled: Bool = false
}

struct Video3: Decodable {
    let id: Int
    let title: String
    private let commentEnabled: Bool?
    var resolvedCommentEnabled: Bool {
        return commentEnabled ?? false
    }
}

struct Video4: Decodable {
    let id: Int
    let title: String
    let commentEnabled: Bool

    enum CodingKeys: String, CodingKey {
        case id, title, commentEnabled
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        commentEnabled = try container.decode(Bool.self, forKey: .commentEnabled)
    }
}

struct Video5: Decodable {
    enum State: String, Decodable {
        case streaming
        case archived
    }

    let state: State
}

struct Video6: Decodable {
    enum State: String, Decodable {
        case streaming
        case archived
        case unknown
    }

    private let state: String
    var resolvedState: State {
        State(rawValue: state) ?? .unknown
    }
}


// Default property wrapper
@propertyWrapper
struct Default<T: Decodable>: Decodable {
    let value: T

    init(wrappedValue: T) {
        value = wrappedValue
    }

    var wrappedValue: T {
        set {
        }
        get {
            fatalError("Not Implementation")
        }
    }

//    init(from decoder: Decoder) throws {
//        let container = try decoder.singleValueContainer()
//        // 不可以使用
//        let v = (try? container.decode(T.self)) ?? value
//        wrappedValue = v
//    }
}

struct Video7: Decodable {
    enum State: String, Decodable {
        case streaming
        case archived
        case unknown
    }

    @Default(wrappedValue: true)
    var commentEnabled: Bool

    @Default(wrappedValue: .unknown)
    var state: State
}

protocol DefaultValue {
    associatedtype Value: Decodable
    static var defaultValue: Value { get }
}

extension Bool: DefaultValue {
    static let defaultValue = true
}

@propertyWrapper
struct Default2<T: DefaultValue> {
    var wrappedValue: T.Value
}

extension Default2: Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        wrappedValue = (try? container.decode(T.Value.self)) ?? T.defaultValue
    }
}

struct Video8: Decodable {
    let id: Int
    let title: String
    enum State: String, Decodable {
        case streaming
        case archived
        case unknown
    }

    @Default2<Bool.False> var commentEnabled: Bool
    @Default2<Bool.True> var publicVideo: Bool
    @Default2<State> var state: State
}

extension KeyedDecodingContainer {
    func decode<T>(_ type: Default2<T>.Type, forKey key: Key) throws -> Default2<T> where T: DefaultValue {
        try decodeIfPresent(type, forKey: key) ??  Default2(wrappedValue: T.defaultValue)
    }
}

extension Video8.State: DefaultValue {
    static let defaultValue = Video8.State.unknown
}

extension Default2 {
    typealias True = Default2<Bool.True>
    typealias False = Default2<Bool.False>
}

extension Bool {
    enum False: DefaultValue {
        static let defaultValue = false
    }

    enum True: DefaultValue {
        static let defaultValue = true
    }
}

struct Video9: Decodable {
    @Default2.False var commentEnabled: Bool
    @Default2.True var publicVideo: Bool
}

// API 设计
struct Video10: Decodable {
    struct State: RawRepresentable, Decodable {
        static let streaming = State(rawValue: "streaming")
        static let archived = State(rawValue: "archived")

        let rawValue: String
    }

    let state: State
}

let tVide10 = Video10(state: .archived)
tVide10.state == .archived
tVide10.state == .streaming
