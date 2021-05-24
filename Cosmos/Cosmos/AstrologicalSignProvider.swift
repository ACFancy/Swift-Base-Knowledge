//
//  AstrologicalSignProvider.swift
//  Cosmos
//
//  Created by Lee Danatech on 2021/5/21.
//

import Foundation
import Cos

typealias AstrologicalSignFunction = () -> AstrologicalSign


struct AstrologicalSign {
    var shape: Shape!
    var big: [Point]!
    var small: [Point]!
    var lines: [[Point]]!
}

class AstrologicalSignProvider : NSObject {
    static let shared = AstrologicalSignProvider()

    let order = ["pisces", "aries", "taurus", "gemini", "cancer", "leo", "virgo",
                 "libra", "scorpio", "sagittarius", "capricorn", "aquarius"]
    internal var mapping: [String: AstrologicalSignFunction] = [:]

    override init() {
        super.init()
        mapping = ["pisces": pisces,
                   "aries": aries,
                   "taurus": taurus,
                   "gemini": gemini,
                   "cancer": cancer,
                   "leo": leo,
                   "virgo": virgo,
                   "libra": libra,
                   "scorpio": scorpio,
                   "sagittarius": sagittarius,
                   "capricorn": capricorn,
                   "aquarius": aquarius]
    }

    func get(sign: String) -> AstrologicalSign? {
        guard let function = mapping[sign.lowercased()] else {
            return nil
        }
        return function()
    }

    func taurus() -> AstrologicalSign {
        let bezier = Path()

        bezier.moveToPoint(Point(0, 0))
        bezier.addCurveToPoint(Point(6.3, 0), control1:Point(6.4, 10.2), control2: Point(15.2, 10.2))
        bezier.addCurveToPoint(Point(20.8, 10.2), control1:Point(25.4, 14.8), control2: Point(25.4, 20.4))
        bezier.addCurveToPoint(Point(25.4, 26), control1:Point(20.8, 30.6), control2: Point(15.2, 30.6))
        bezier.addCurveToPoint(Point(9.6, 30.6), control1:Point(5, 26), control2: Point(5, 20.4))
        bezier.addCurveToPoint(Point(5, 14.8), control1:Point(9.6, 10.2), control2: Point(15.2, 10.2))
        bezier.addCurveToPoint(Point(24, 10.2), control1:Point(24.1, 0), control2: Point(30.4, 0))

        var sign = AstrologicalSign()
        sign.shape = Shape(bezier)

        let big = [
            Point(-53.25,-208.2),
            Point(-56.75,-26.2)]
        sign.big = big

        let small = [
            Point(-134.75,-174.2),
            Point(-24.25,-32.2),
            Point(-24.25,-9.2),
            Point(-32.75,10.8),
            Point(87.75,-6.2),
            Point(-15.75,67.3),
            Point(31.75,142.3)]
        sign.small = small

        let lines = [
            [big[0],small[1]],
            [big[1],small[0]],
            [small[1],small[4]],
            [small[1],small[2]],
            [small[2],small[3]],
            [big[1],small[3]],
            [small[3],small[5]],
            [small[5],small[6]]]
        sign.lines = lines

        return sign
    }

    func aries() -> AstrologicalSign {
        let bezier = Path()

        bezier.moveToPoint(Point(2.8, 15.5))
        bezier.addCurveToPoint(Point(1.1, 13.9), control1:Point(0, 11.6), control2: Point(0, 9))
        bezier.addCurveToPoint(Point(0, 4), control1:Point(4, 0), control2: Point(9, 0))
        bezier.addCurveToPoint(Point(14, 0), control1:Point(18, 4), control2: Point(18, 9))
        bezier.addLineToPoint(Point(18, 28.9))

        bezier.moveToPoint(Point(18, 28.9))
        bezier.addLineToPoint(Point(18, 9))
        bezier.addCurveToPoint(Point(18, 4), control1:Point(22, 0), control2: Point(27, 0))
        bezier.addCurveToPoint(Point(32, 0), control1:Point(36, 4), control2: Point(36, 9))
        bezier.addCurveToPoint(Point(36, 11.6), control1:Point(34.9, 13.9), control2: Point(33.2, 15.5))

        var sign = AstrologicalSign()
        sign.shape = Shape(bezier)

        let big = [
            Point(58.0,-57.7),
            Point(125.50,    -17.7)]
        sign.big = big

        let small = [
            Point(-134.5,-95.2),
            Point(137.0,11.3)]
        sign.small = small

        let lines = [
            [big[0],small[0]],
            [big[1],big[0]],
            [big[1],small[1]]]
        sign.lines = lines

        return sign
    }

    func gemini() -> AstrologicalSign {
        let bezier = Path()

        bezier.moveToPoint(Point(26, 0))
        bezier.addCurveToPoint(Point(26, 0), control1:Point(24.2, 5.3), control2: Point(13, 5.3))
        bezier.addCurveToPoint(Point(1.8, 5.3), control1:Point(0, 0), control2: Point(0, 0))

        bezier.moveToPoint(Point(0.1, 34.7))
        bezier.addCurveToPoint(Point(0.1, 34.7), control1:Point(1.9, 29.4), control2: Point(13.1, 29.4))
        bezier.addCurveToPoint(Point(24.3, 29.4), control1:Point(26.1, 34.7), control2: Point(26.1, 34.7))

        bezier.moveToPoint(Point(8.1, 5))
        bezier.addLineToPoint(Point(8.1, 29.6))

        bezier.moveToPoint(Point(18, 5))
        bezier.addLineToPoint(Point(18, 29.6))

        var sign = AstrologicalSign()
        sign.shape = Shape(bezier)

        let big = [
            Point(-96.75,-193.7),
            Point(-133.25,-142.2),
            Point(77.25,19.8)]
        sign.big = big

        let small = [
            Point(24.25,-218.7),
            Point(-29.75,-167.7),
            Point(-105.25,-125.7),
            Point(-134.75,-92.7),
            Point(54.75,-98.7),
            Point(120.75,-66.2),
            Point(145.75,-67.2),
            Point(103.75,-34.2),
            Point(-58.75,-55.7),
            Point(-9.25,-37.2),
            Point(-56.25,18.8),
            Point(53.75,67.8)]
        sign.small = small

        let lines = [
            [big[0],small[1]],
            [big[1],small[2]],
            [small[0],small[1]],
            [small[1],small[2]],
            [small[2],small[3]],
            [small[2],small[8]],
            [small[8],small[10]],
            [small[10],small[11]],
            [small[8],small[9]],
            [small[9],big[2]],
            [small[1],small[4]],
            [small[4],small[7]],
            [small[4],small[5]],
            [small[5],small[6]]]
        sign.lines = lines

        return sign
    }

    func cancer() -> AstrologicalSign {
        let bezier = Path()

        bezier.moveToPoint(Point(0, 8.1))
        bezier.addCurveToPoint(Point(1.9, 4.5), control1:Point(6.4, 0), control2: Point(14.2, 0))
        bezier.addCurveToPoint(Point(22.1, 0), control1:Point(28.4, 4), control2: Point(28.4, 8.8))
        bezier.addCurveToPoint(Point(28.4, 11.7), control1:Point(26.1, 14), control2: Point(23.2, 14))
        bezier.addCurveToPoint(Point(20.3, 14), control1:Point(18, 11.7), control2: Point(18, 8.8))
        bezier.addCurveToPoint(Point(18, 5.9), control1:Point(20.3, 3.6), control2: Point(23.2, 3.6))
        bezier.addCurveToPoint(Point(26.1, 3.6), control1:Point(28.4, 5.9), control2: Point(28.4, 8.8))

        bezier.moveToPoint(Point(28.4, 21.3))
        bezier.addCurveToPoint(Point(26.5, 24.9), control1:Point(22, 29.4), control2: Point(14.2, 29.4))
        bezier.addCurveToPoint(Point(6.3, 29.4), control1:Point(0, 25.4), control2: Point(0, 20.6))
        bezier.addCurveToPoint(Point(0, 17.7), control1:Point(2.3, 15.4), control2: Point(5.2, 15.4))
        bezier.addCurveToPoint(Point(8.1, 15.4), control1:Point(10.4, 17.7), control2: Point(10.4, 20.6))
        bezier.addCurveToPoint(Point(10.4, 23.5), control1:Point(8.1, 25.8), control2: Point(5.2, 25.8))
        bezier.addCurveToPoint(Point(2.3, 25.8), control1:Point(0, 23.5), control2: Point(0, 20.6))

        var sign = AstrologicalSign()
        sign.shape = Shape(bezier)

        let big = [
            Point(-68.25,-21.2),
            Point(46.25,141.8)]
        sign.big = big

        let small = [
            Point(-66.75,-209.2),
            Point(-59.25,-80.7),
            Point(-126.75,90.8),
            Point(5.75,81.8)]
        sign.small = small

        let lines = [
            [big[0],small[1]],
            [big[1],small[3]],
            [small[0],small[1]],
            [big[0],small[2]],
            [big[0],small[3]]]
        sign.lines = lines

        return sign
    }

    func leo() -> AstrologicalSign {
        let bezier = Path()

        bezier.moveToPoint(Point(10.4, 19.6))
        bezier.addCurveToPoint(Point(10.4, 16.7), control1:Point(8.1, 14.4), control2: Point(5.2, 14.4))
        bezier.addCurveToPoint(Point(2.3, 14.4), control1:Point(0, 16.7), control2: Point(0, 19.6))
        bezier.addCurveToPoint(Point(0, 22.5), control1:Point(2.3, 24.8), control2: Point(5.2, 24.8))
        bezier.addCurveToPoint(Point(8.1, 24.8), control1:Point(10.4, 22.4), control2: Point(10.4, 19.6))
        bezier.addCurveToPoint(Point(10.4, 14.8), control1:Point(6, 15), control2: Point(6, 9.1))
        bezier.addCurveToPoint(Point(6, 4), control1:Point(10.1, 0), control2: Point(15.1, 0))
        bezier.addCurveToPoint(Point(20.1, 0), control1:Point(24.2, 4.1), control2: Point(24.2, 9.1))
        bezier.addCurveToPoint(Point(24.2, 17.2), control1:Point(17, 18.5), control2: Point(17, 25.6))
        bezier.addCurveToPoint(Point(17, 28.5), control1:Point(19.3, 30.8), control2: Point(22.2, 30.8))
        bezier.addCurveToPoint(Point(25.1, 30.8), control1:Point(27.4, 28.5), control2: Point(27.4, 25.6))

        var sign = AstrologicalSign()
        sign.shape = Shape(bezier)

        let big = [
            Point(-60.25,-33.7),
            Point(68.75,-50.2),
            Point(110.75,50.3)]
        sign.big = big

        let small = [
            Point(138.75,-129.2),
            Point(118.75,-157.2),
            Point(66.75,-103.7),
            Point(-31.75,-34.2),
            Point(103.75,-14.7),
            Point(-55.75,40.8),
            Point(-138.25,62.3)]
        sign.small = small

        let lines = [
            [small[0],small[1]],
            [small[1],small[2]],
            [small[2],big[1]],
            [big[1],small[4]],
            [small[4],big[2]],
            [big[2],small[5]],
            [small[5],small[6]],
            [small[6],big[0]],
            [big[0],small[3]],
            [small[3],big[1]]]
        sign.lines = lines

        return sign
    }

    func virgo() -> AstrologicalSign {
        let bezier = Path()

        bezier.moveToPoint(Point(30, 12.2))
        bezier.addCurveToPoint(Point(30, 9.4), control1:Point(32.2, 7.2), control2: Point(35, 7.2))
        bezier.addCurveToPoint(Point(37.8, 7.2), control1:Point(40, 9.4), control2: Point(40, 12.2))
        bezier.addCurveToPoint(Point(40, 23.7), control1:Point(24.3, 31.5), control2: Point(24.3, 31.5))

        bezier.moveToPoint(Point(10, 24.1))
        bezier.addLineToPoint(Point(10, 5))
        bezier.addCurveToPoint(Point(10, 2.2), control1:Point(7.8, 0), control2: Point(5, 0))
        bezier.addCurveToPoint(Point(2.2, 0), control1:Point(0, 2.2), control2: Point(0, 5))

        bezier.moveToPoint(Point(20, 24.1))
        bezier.addLineToPoint(Point(20, 5))
        bezier.addCurveToPoint(Point(20, 2.2), control1:Point(17.8, 0), control2: Point(15, 0))
        bezier.addCurveToPoint(Point(12.2, 0), control1:Point(10, 2.2), control2: Point(10, 5))

        bezier.moveToPoint(Point(39.1, 29.8))
        bezier.addCurveToPoint(Point(34.5, 29.8), control1:Point(30, 28), control2: Point(30, 19.2))
        bezier.addLineToPoint(Point(30, 5))
        bezier.addCurveToPoint(Point(30, 2.2), control1:Point(27.8, 0), control2: Point(25, 0))
        bezier.addCurveToPoint(Point(22.2, 0), control1:Point(20, 2.2), control2: Point(20, 5))

        var sign = AstrologicalSign()
        sign.shape = Shape(bezier)

        let big = [
            Point(-28.75,-248.2),
            Point(-134.75,-109.2),
            Point(93.75,-56.7),
            Point(-53.25,98.8)]
        sign.big = big

        let small = [
            Point(-9.25,-186.7),
            Point(-2.25,-144.7),
            Point(-56.25,-116.7),
            Point(39.25,-86.7),
            Point(-18.25,-39.7),
            Point(-44.25,10.3),
            Point(87.25,35.8),
            Point(33.75,42.3),
            Point(31.75,68.8),
            Point(24.25,94.8)]
        sign.small = small

        let lines = [
            [big[0],small[0]],
            [small[0],small[1]],
            [small[1],small[3]],
            [small[3],big[2]],
            [big[2],small[6]],
            [small[6],small[7]],
            [small[7],small[8]],
            [small[8],small[9]],
            [small[1],small[2]],
            [small[2],big[1]],
            [small[2],small[4]],
            [big[2],small[4]],
            [small[4],small[5]],
            [small[5],big[3]]]
        sign.lines = lines

        return sign
    }

    func libra() -> AstrologicalSign {
        let bezier = Path()

        bezier.moveToPoint(Point(37.5, 11.3))
        bezier.addLineToPoint(Point(30, 11.3))
        bezier.addCurveToPoint(Point(30, 5.1), control1:Point(24.9, 0), control2: Point(18.7, 0))
        bezier.addCurveToPoint(Point(12.5, 0), control1:Point(7.4, 5.1), control2: Point(7.4, 11.3))
        bezier.addLineToPoint(Point(0, 11.3))

        bezier.moveToPoint(Point(0, 20.2))
        bezier.addLineToPoint(Point(37.5, 20.2))

        var sign = AstrologicalSign()
        sign.shape = Shape(bezier)

        let big = [
            Point(-26.25,-121.7)]
        sign.big = big

        let small = [
            Point(-141.25,-37.7),
            Point(-16.75,-35.7),
            Point(96.75,-39.2),
            Point(-70.75,65.3),
            Point(-64.75,102.3),
            Point(-53.25,147.3),
            Point(120.75,92.3),
            Point(118.75,109.3),
            Point(141.25,117.8)]
        sign.small = small

        let lines = [
            [big[0],small[0]],
            [big[0],small[2]],
            [small[0],small[1]],
            [small[2],small[1]],
            [small[0],small[3]],
            [small[3],small[4]],
            [small[4],small[5]],
            [small[2],small[6]],
            [small[6],small[7]],
            [small[7],small[8]]]
        sign.lines = lines

        return sign
    }

    func pisces() -> AstrologicalSign {
        let bezier = Path()

        bezier.moveToPoint(Point(2.8, 0.1))
        bezier.addCurveToPoint(Point(2.8, 0.1), control1:Point(9.2, 1.9), control2: Point(9.2, 13.1))
        bezier.addCurveToPoint(Point(9.2, 24.3), control1:Point(2.8, 26.1), control2: Point(2.8, 26.1))

        bezier.moveToPoint(Point(25.4, 26))
        bezier.addCurveToPoint(Point(25.4, 26), control1:Point(19, 24.2), control2: Point(19, 13))
        bezier.addCurveToPoint(Point(19, 1.8), control1:Point(25.4, 0), control2: Point(25.4, 0))

        bezier.moveToPoint(Point(0, 13.1))
        bezier.addLineToPoint(Point(28.2, 13.1))

        var sign = AstrologicalSign()
        sign.shape = Shape(bezier)

        let big = [
            Point(-103.0,-81.7),
            Point(120.5,-168.2)]
        sign.big = big

        sign.big = big

        let small = [
            Point(-127.5,-161.2),
            Point(-129.0,-143.2),
            Point(-112.0,-136.2),
            Point(-103.0,-38.2),
            Point(-107.5,11.3),
            Point(-82.0,-20.2),
            Point(-66.0,-32.7),
            Point(-28.5,-67.7),
            Point(-8.0,-78.7),
            Point(58.0,-129.7),
            Point(84.5,-147.7),
            Point(92.5,-163.7),
            Point(106.0,-130.2),
            Point(125.5,-149.2),
            Point(129.5,-188.2)]
        sign.small = small

        let lines = [
            [big[0],small[3]],
            [big[1],small[14]],
            [small[0],small[1]],
            [small[1],small[2]],
            [small[2],big[0]],
            [small[3],small[4]],
            [small[4],small[5]],
            [small[5],small[6]],
            [small[6],small[7]],
            [small[7],small[8]],
            [small[8],small[9]],
            [small[9],small[10]],
            [small[10],small[11]],
            [small[11],big[1]],
            [small[10],small[12]],
            [small[12],small[13]],
            [small[13],big[1]]]
        sign.lines = lines

        return sign
    }

    func aquarius() -> AstrologicalSign {
        let bezier = Path()

        bezier.moveToPoint(Point(0, 5.4))
        bezier.addCurveToPoint(Point(4.5, 5.4), control1:Point(3.6, 0), control2: Point(8.2, 0))
        bezier.addCurveToPoint(Point(12.7, 0), control1:Point(11.8, 5.4), control2: Point(16.3, 5.4))
        bezier.addCurveToPoint(Point(20.8, 5.4), control1:Point(19.9, 0), control2: Point(24.5, 0))
        bezier.addCurveToPoint(Point(29, 0), control1:Point(28.1, 5.4), control2: Point(32.6, 5.4))
        bezier.addCurveToPoint(Point(37.1, 5.4), control1:Point(36.2, 0), control2: Point(40.7, 0))

        bezier.moveToPoint(Point(40.7, 15.1))
        bezier.addCurveToPoint(Point(36.2, 15.1), control1:Point(37.1, 20.5), control2: Point(32.6, 20.5))
        bezier.addCurveToPoint(Point(28.1, 20.5), control1:Point(29, 15.1), control2: Point(24.5, 15.1))
        bezier.addCurveToPoint(Point(19.9, 15.1), control1:Point(20.8, 20.5), control2: Point(16.3, 20.5))
        bezier.addCurveToPoint(Point(11.8, 20.5), control1:Point(12.7, 15.1), control2: Point(8.2, 15.1))
        bezier.addCurveToPoint(Point(3.6, 15.1), control1:Point(4.5, 20.5), control2: Point(0, 20.5))

        var sign = AstrologicalSign()
        sign.shape = Shape(bezier)

        let big = [
            Point(-140.25,-148.7),
            Point(-10.75,-203.7),
            Point(54.25,-158.2),
            Point(140.25,-127.7)]
        sign.big = big

        let small = [
            Point(-128.75,-17.7),
            Point(-93.25,-87.7),
            Point(-97.75,-135.7),
            Point(-67.75,-202.2),
            Point(-53.75,-206.2),
            Point(-41.75,-193.7),
            Point(-34.25,-136.2),
            Point(-18.75,-103.2),
            Point(-9.75,-85.7)]
        sign.small = small

        let lines = [
            [small[0],small[1]],
            [small[1],small[2]],
            [small[2],big[0]],
            [big[0],small[3]],
            [small[3],small[4]],
            [small[4],small[5]],
            [small[5],big[1]],
            [big[1],big[2]],
            [big[2],big[3]],
            [big[1],small[6]],
            [small[6],small[7]],
            [small[7],small[8]]]
        sign.lines = lines

        return sign
    }

    func sagittarius() -> AstrologicalSign {
        let bezier = Path()

        bezier.moveToPoint(Point(30.4, 10.6))
        bezier.addLineToPoint(Point(30.4, 0))
        bezier.addLineToPoint(Point(19.8, 0))

        bezier.moveToPoint(Point(7.8, 10.5))
        bezier.addLineToPoint(Point(13.9, 16.5))
        bezier.addLineToPoint(Point(0, 30.4))

        bezier.moveToPoint(Point(30.3, 0.1))
        bezier.addLineToPoint(Point(13.9, 16.5))
        bezier.addLineToPoint(Point(20, 22.7))

        var sign = AstrologicalSign()
        sign.shape = Shape(bezier)

        let big = [
            Point(-69.75,78.3),
            Point(-98.25,-98.2)]
        sign.big = big

        let small = [
            Point(0.75,81.8),
            Point(-18.75,44.3),
            Point(-102.25,22.3),
            Point(-109.25,10.8),
            Point(-142.25,-50.2),
            Point(-129.75,-62.7),
            Point(-27.75,-93.7),
            Point(-10.75,-77.7),
            Point(-6.25,-112.7),
            Point(-42.75,-152.2),
            Point(-57.75,-159.7),
            Point(-78.75,-171.7),
            Point(-93.25,-178.7),
            Point(17.75,-112.7),
            Point(52.75,-140.7),
            Point(87.25,-202.7),
            Point(76.75,-100.2),
            Point(110.75,-102.7),
            Point(142.25,-132.7),
            Point(82.25,-54.2),
            Point(101.25,-33.7)]
        sign.small = small

        let lines = [
            [small[1],big[0]],
            [small[0],big[0]],
            [big[0],small[2]],
            [small[2],small[3]],
            [small[3],small[4]],
            [small[4],small[5]],
            [small[5],big[1]],
            [big[1],small[6]],
            [small[6],small[9]],
            [small[9],small[10]],
            [small[10],small[11]],
            [small[11],small[12]],
            [small[6],small[8]],
            [small[8],small[13]],
            [small[13],small[14]],
            [small[14],small[15]],
            [small[6],small[7]],
            [small[7],small[13]],
            [small[14],small[16]],
            [small[16],small[17]],
            [small[17],small[18]],
            [small[16],small[19]],
            [small[19],small[20]]]
        sign.lines = lines

        return sign
    }

    func capricorn() -> AstrologicalSign {
        let bezier = Path()

        bezier.moveToPoint(Point(13, 22.3))
        bezier.addLineToPoint(Point(13, 6.5))
        bezier.addCurveToPoint(Point(13, 2.9), control1:Point(10.1, 0), control2: Point(6.5, 0))
        bezier.addCurveToPoint(Point(2.9, 0), control1:Point(0, 2.9), control2: Point(0, 6.5))

        bezier.moveToPoint(Point(13, 6.5))
        bezier.addCurveToPoint(Point(13, 2.9), control1:Point(15.9, 0), control2: Point(19.5, 0))
        bezier.addCurveToPoint(Point(23.1, 0), control1:Point(26, 2.9), control2: Point(26, 6.5))
        bezier.addCurveToPoint(Point(26, 16.3), control1:Point(27.6, 19.6), control2: Point(29.9, 22.9))
        bezier.addCurveToPoint(Point(32.2, 26.3), control1:Point(35.2, 27.7), control2: Point(37.7, 27.7))
        bezier.addCurveToPoint(Point(41.8, 27.7), control1:Point(45.2, 24.4), control2: Point(45.2, 20.3))
        bezier.addCurveToPoint(Point(45.2, 16.2), control1:Point(41.9, 12.9), control2: Point(37.8, 12.9))
        bezier.addCurveToPoint(Point(32.1, 12.9), control1:Point(30.7, 18.5), control2: Point(29.9, 22.9))
        bezier.addCurveToPoint(Point(28.3, 31.7), control1:Point(22.4, 33.6), control2: Point(17.1, 33.6))

        var sign = AstrologicalSign()
        sign.shape = Shape(bezier)

        let big = [
            Point(136.25,-41.2),
            Point(133.25,-9.69999999999999),
            Point(1.25,50.3),
            Point(-129.75,73.8),
        ]
        sign.big = big

        let small = [
            Point(-51.25,59.3),
            Point(-105.75,72.8),
            Point(-84.75,103.8),
            Point(-50.75,122.8),
            Point(-36.25,128.8),
            Point(27.75,144.8),
            Point(81.25,156.8),
            Point(91.25,133.3)]
        sign.small = small

        let lines = [
            [big[1],big[0]],
            [big[1],big[2]],
            [big[2],small[0]],
            [small[0],small[1]],
            [small[1],big[3]],
            [big[3],small[2]],
            [small[2],small[3]],
            [small[3],small[4]],
            [small[4],small[5]],
            [small[5],small[6]],
            [small[6],small[7]],
            [small[7],big[1]]]
        sign.lines = lines

        return sign
    }

    func scorpio() -> AstrologicalSign {
        let bezier = Path()

        bezier.moveToPoint(Point(10, 24.1))
        bezier.addLineToPoint(Point(10, 5))
        bezier.addCurveToPoint(Point(10, 2.2), control1:Point(7.8, 0), control2: Point(5, 0))
        bezier.addCurveToPoint(Point(2.2, 0), control1:Point(0, 2.2), control2: Point(0, 5))

        bezier.moveToPoint(Point(20, 24.1))
        bezier.addLineToPoint(Point(20, 5))
        bezier.addCurveToPoint(Point(20, 2.2), control1:Point(17.8, 0), control2: Point(15, 0))
        bezier.addCurveToPoint(Point(12.2, 0), control1:Point(10, 2.2), control2: Point(10, 5))

        bezier.moveToPoint(Point(39.1, 31.1))
        bezier.addCurveToPoint(Point(36, 28.1), control1:Point(30, 23.9), control2: Point(30, 15.1))
        bezier.addLineToPoint(Point(30, 5))
        bezier.addCurveToPoint(Point(30, 2.2), control1:Point(27.8, 0), control2: Point(25, 0))
        bezier.addCurveToPoint(Point(22.2, 0), control1:Point(20, 2.2), control2: Point(20, 5))

        bezier.moveToPoint(Point(39.2, 20.5))
        bezier.addLineToPoint(Point(39.2, 31.1))
        bezier.addLineToPoint(Point(28.6, 31.1))

        var sign = AstrologicalSign()
        sign.shape = Shape(bezier)

        let big = [
            Point(-85.75,32.3),
            Point(-64.75,103.8),
            Point(38.75,-136.2)]
        sign.big = big

        let small = [
            Point(-70.75,34.8),
            Point(-97.75,61.3),
            Point(-100.75,76.8),
            Point(-9.25,86.8),
            Point(28.75,69.8),
            Point(29.25,54.8),
            Point(19.75,15.3),
            Point(10.75,-28.7),
            Point(24.75,-108.7),
            Point(56.25,-151.2),
            Point(103.75,-197.7),
            Point(81.75,-230.7),
            Point(61.75,-230.7),
            Point(119.25,-156.7),
            Point(130.25,-117.2)]
        sign.small = small

        let lines = [
            [small[0],big[0]],
            [big[0],small[1]],
            [small[1],small[2]],
            [small[2],big[1]],
            [big[1],small[3]],
            [small[3],small[4]],
            [small[4],small[5]],
            [small[5],small[6]],
            [small[6],small[7]],
            [small[7],small[8]],
            [small[8],big[2]],
            [big[2],small[9]],
            [small[9],small[10]],
            [small[10],small[11]],
            [small[11],small[12]],
            [small[10],small[13]],
            [small[13],small[14]]]
        sign.lines = lines

        return sign
    }
}
