import UIKit

enum Encoding {
    case ascii
    case nextstep
    case japaneseEUC
    case utf8
}

//// error opetation
//let myEncoding = Encoding.ascii + Encoding.utf8

extension Encoding {
    var nsStringencoding: String.Encoding {
        switch self {
        case .ascii: return .ascii
        case .nextstep: return .nextstep
        case .japaneseEUC: return .japaneseEUC
        case .utf8: return .utf8
        }
    }
}

extension Encoding {
    init?(encoding: String.Encoding) {
        switch encoding {
        case .ascii: self = .ascii
        case .nextstep: self = .nextstep
        case .japaneseEUC: self = .japaneseEUC
        case .utf8: self = .utf8
        default: return nil
        }
    }
}

extension Encoding {
    var localizedName: String {
        return String.localizedName(of: nsStringencoding)
    }
}

enum LookupError: Error {
    case capitalNotFound
    case populationNotFound
}

enum PopulationResult {
    case success(Int)
    case error(LookupError)
}

let exampleSuccess: PopulationResult = .success(100)

let cities = ["Paris": 2241, "Madrid": 3165, "Amsterdam": 827, "Berlin": 3562]
let capitals = ["France": "Paris",
                "Spain": "Madrid",
                "The Netherlands": "Amsterdam",
                "Belgium": "Brussels"]

func populationOfCapital(country: String) -> PopulationResult {
    guard let capital = capitals[country] else {
        return .error(.capitalNotFound)
    }
    guard let population = cities[capital] else {
        return .error(.populationNotFound)
    }
    return .success(population)
}

switch populationOfCapital(country: "France") {
case let .success(population):
    debugPrint(population)
case let .error(error):
    debugPrint("\(error)")
}

let mayors = ["Paris": "Hidalgo",
              "Madrid": "Carmena",
              "Amsterdam": "van der laan",
              "Berlin": "Müller"]
func mayorOfCapital(country: String) -> String? {
    return capitals[country].flatMap { mayors[$0] }
}


enum MayorResult {
    case success(String)
    case error(Error)
}

//泛型
enum Result<T> {
    case success(T)
    case error(Error)
}

//func populationOfCapital(country: String) -> Result<Int>
//func mayorOfCapital(country: String) -> Result<String>

func populationOfCapital2(country: String) throws -> Int {
    guard let capital = capitals[country] else {
        throw LookupError.capitalNotFound
    }
    guard let population = cities[capital] else {
        throw LookupError.populationNotFound
    }
    return population
}

do {
    let population = try populationOfCapital2(country: "France")
    debugPrint(population)
} catch {
    debugPrint("\(error)")
}

func ??<T>(result: Result<T>, handleError: (Error) -> T) -> T {
    switch result {
    case let .success(value):
        return value
    case let .error(error):
        return handleError(error)
    }
}

// “和“类型
enum Add<T, U> {
    case inLeft(T)
    case inRight(U)
}

enum Zero {}

typealias Times<T, U> = (T, U)
typealias One = ()

//同构
/**
 Times<One, T> T
 Times<Zero, T> Zero (需要思考下)
 Timer<T, U> Times<U, T>
 */
