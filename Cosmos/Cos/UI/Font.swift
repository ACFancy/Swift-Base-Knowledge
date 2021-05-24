//
//  Font.swift
//  Cos
//
//  Created by Lee Danatech on 2021/5/19.
//

import UIKit

public class Font {
    internal var internalFont: UIFont!
    
    public var uifont: UIFont {
        return internalFont
    }
    
    public init?(name: String, size: Double) {
        guard let font = UIFont(name: name, size: CGFloat(size)) else {
            return nil
        }
        internalFont = font
    }
    
    public convenience init?(name: String) {
        self.init(name: name, size: 12.0)
    }
    
    public init(font: UIFont) {
        internalFont = font
    }
    
    public class func familyNames() -> [String] {
        return UIFont.familyNames
    }
    
    public class func fontNames(_ familyName: String) -> [String] {
        return UIFont.fontNames(forFamilyName: familyName)
    }
    
    public class func systemFont(_ size: Double) -> Font {
        return Font(font: .systemFont(ofSize: CGFloat(size)))
    }
    
    public class func boldSystemFont(_ size: Double) -> Font {
        return Font(font: .boldSystemFont(ofSize: CGFloat(size)))
    }
    
    public class func italicSystemFont(_ size: Double) -> Font {
        return Font(font: .italicSystemFont(ofSize: CGFloat(size)))
    }
    
    public func font(_ size: Double) -> Font {
        return Font(font: internalFont.withSize(CGFloat(size)))
    }
    
    public var familyName: String {
        return internalFont.familyName
    }
    
    public var fontName: String {
        return internalFont.fontName
    }
    
    public var pointSize: Double {
        return Double(internalFont.pointSize)
    }
    
    public var ascender: Double {
        return Double(internalFont.ascender)
    }
    
    public var descender: Double {
        return Double(internalFont.descender)
    }
    
    public var capHeight: Double {
        return Double(internalFont.capHeight)
    }
    
    public var xHeight: Double {
        return Double(internalFont.xHeight)
    }
    
    public var lineHeight: Double {
        return Double(internalFont.lineHeight)
    }
    
    public var leading: Double {
        return Double(internalFont.leading)
    }
    
    #if os(iOS)
    public class var labelFontSize: Double {
        return Double(UIFont.labelFontSize)
    }
    
    public class var buttonFontSize: Double {
        return Double(UIFont.buttonFontSize)
    }
    
    public class var systemFontSize: Double {
        return Double(UIFont.systemFontSize)
    }
    
    public class var smallSystemFontSize: Double {
        return Double(UIFont.smallSystemFontSize)
    }
    #endif
    
    public var cgFont: CGFont? {
        return CGFont(fontName as CFString)
    }
    
    public var ctFont: CTFont {
        return CTFontCreateWithNameAndOptions(fontName as CFString, CGFloat(pointSize), nil, [])
    }
}
