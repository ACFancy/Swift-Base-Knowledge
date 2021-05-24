//
//  TextShape.swift
//  Cos
//
//  Created by Lee Danatech on 2021/5/19.
//

import QuartzCore
import UIKit

public class TextShape : Shape {
    public var text: String = "C4" {
        didSet {
            updatePath()
        }
    }
    
    public var font = Font(name: "AvenirNext-DemiBold", size: 80)! {
        didSet {
            updatePath()
        }
    }
    
    public override init() {
        super.init()
        lineWidth = 0
        fillColor = C4Pink
    }
    
    public convenience init?(text: String, font: Font) {
        self.init()
        self.text = text
        self.font = font
        updatePath()
        origin = Point()
    }
    
    public convenience init?(text: String) {
        guard let font = Font(name: "AvenirNext-DemiBold", size: 80) else {
            return nil
        }
        self.init(text: text, font: font)
    }
    
    override func updatePath() {
        path = Self.createTextPath(text: text, font: font)
        adjustToFitPath()
    }
    
    internal class func createTextPath(text: String, font: Font) -> Path? {
        guard let ctfont = (font.ctFont as CTFont?) else {
            return nil
        }
        
        var unichars = [UniChar](text.utf16)
        var glyphs = [CGGlyph](repeating: 0, count: unichars.count)
        if !CTFontGetGlyphsForCharacters(ctfont, &unichars, &glyphs, unichars.count) {
            return nil
        }
        
        var advances = [CGSize](repeating: CGSize(), count: glyphs.count)
        CTFontGetAdvancesForGlyphs(ctfont, .default, &glyphs, &advances, glyphs.count)
        let textPath = CGMutablePath()
        var invert = CGAffineTransform(scaleX: 1, y: -1)
        var origin = CGPoint()
        for (advance, glphy) in zip(advances, glyphs) {
            if let glyphPath = CTFontCreatePathForGlyph(ctfont, glphy, &invert) {
                let translation = CGAffineTransform(translationX: origin.x, y: origin.y)
                textPath.addPath(glyphPath, transform: translation)
            }
            origin.x += advance.width
            origin.y += advance.height
        }
        return Path(path: textPath)
    }
}
