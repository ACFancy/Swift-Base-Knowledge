import UIKit

/*
extension Array {
    func map<R>(transform (Element) -> R) ->[R] {}
}

extension Optional {
    func map<R>(transform: (Wrapped) -> R) ->R? {}
}

extension Parser {
    func map<T>(_ transform: @escaping(Result) -> T) -> Parser<T> {}
}

 extension Array {
     func map<R>(transform (Element) -> R) ->Array<R> {}
 }

 extension Optional {
     func map<R>(transform: (Wrapped) -> R) ->Optional<R> {}
 }

 extension Parser {
     func map<T>(_ transform: @escaping(Result) -> T) -> Parser<T> {}
 }

 extension Result {
     func map<U, T>(f: (T) -> U) -> Result<U, Error> {
         switch self {
         case let .success(value): return .succcess(f(value))
         case let .failure(error): return .failure(error)
         }
     }
 }
 */


func curry<A, B, C>(_ f: @escaping(A, B) -> C) -> (A) -> (B) -> C {
    return {x in { y in f(x, y) }}
}

/// Functor 可以是容器，可以是函数
struct Position {
    var x: Double
    var y: Double
}

struct Region<T> {
    let value: (Position) -> T
}

extension Region {
    func map<U>(transform: @escaping (T) -> U) -> Region<U> {
        return Region<U> { pos in
            transform(self.value(pos))
        }
    }
}

// Adpplicative Functor
/*
 func <*><A, B>(lhs: Parser<(A) -> B>, rhs: Parser<A>) -> Parser<B> {}

 “对于任意的类型构造体，如果我们可以为其定义恰当的 pure 与 <*> 运算，我们就可以将其称之为一个适用函子”
 “再严谨一些，对任意一个函子 F，如果能支持以下运算，该函子就是一个适用函子：”
 func pure<A>(_ value: A) -> F<A>
 func <*><A, B>(f: F<A -> B>, x: F<A>) -> F<B>
*/

precedencegroup Apply {
    associativity: left
}
infix operator <*>: Apply

func pure<A>(_ value: A) -> Region<A> {
    return Region { pos in
        value
    }
}

func <*><A, B>(regionF: Region<(A) -> B>, regionX: Region<A>) -> Region<B> {
    return Region { pos in
        regionF.value(pos)(regionX.value(pos))
    }
}

func everywhere() -> Region<Bool> {
    return pure(true)
}

func invert(region: Region<Bool>) -> Region<Bool> {
    return pure(!)<*>region
}

func intersection(region1: Region<Bool>, region2: Region<Bool>) -> Region<Bool> {
    let and: (Bool, Bool) -> Bool = { $0 && $1 }
    return pure(curry(and)) <*> region1 <*> region2
}


func pure<A>(_ value: A) -> A? {
    return value
}

func <*><A, B>(optionalTransform: ((A) -> B)?, optionalValue: A?) -> B? {
    guard let transform = optionalTransform, let value = optionalValue else {
        return nil
    }
    return transform(value)
}

func addOptionals(optionalX: Int?, optionalY: Int?) -> Int? {
    guard let x = optionalX, let y = optionalY else {
        return nil
    }
    return x + y
}

func addOptionals2(optionalX: Int?, optionalY: Int?) -> Int? {
    return pure(curry(+)) <*> optionalX <*> optionalY
}

//func populationOfCapital(country: String) -> Int? {
//    guard let capital = capitals[country], let population = cities[capital] else {
//        return nil
//    }
//    return population * 1000
//}

// Monad

//func populationOfCapital3(country: String) -> Int? {
//    return capitals[country].flapMap { capital in
//        return cities[capital]
//    }.flatMap { population in
//        return population * 1000
//    }
//}
/**
 “如果一个类型构造体 F 定义了下面两个函数，它就是一个单子 (Monad)”
 func pure<A>(_ value: A) -> F<A>

 func flatMap<A, B>(x: F<A>)(_f: (A) -> F<B>) -> F<B>
 */

func pure<A>(_ value: A) ->[A] {
    return [value]
}

extension Array {
    func flatMap2<B>(_ f:(Element) ->[B]) ->[B] {
        return map(f).reduce([], +)
    }
}


func cartesianProduct1<A, B>(xs: [A], ys: [B]) ->[(A, B)] {
    var result: [(A, B)] = []
    for x in xs {
        for y in ys {
            result += [(x, y)]
        }
    }
    return result
}

func cartesianProduct2<A, B>(xs: [A], ys: [B]) ->[(A, B)] {
    return xs.flatMap { x in
        ys.flatMap { y in
            [(x, y)]
        }
    }
}
