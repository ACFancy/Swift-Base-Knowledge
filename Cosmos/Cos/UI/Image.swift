//
//  Image.swift
//  Cos
//
//  Created by Lee Danatech on 2021/5/19.
//

import UIKit

open class Image : View, NSCopying {
    open class ImageView : UIImageView {
        var imageLayer: ImageLayer {
            return self.layer as! ImageLayer
        }
        
        open override class var layerClass: AnyClass {
            return ImageLayer.self
        }
    }
    
    open var imageView: ImageView {
        return self.view as! ImageView
    }
    
    open var imageLayer: ImageLayer {
        return self.imageView.imageLayer
    }
    
    open var uiimage: UIImage {
        let layer = imageView.layer
        let contents = layer.contents as! CGImage
        return UIImage(cgImage: contents, scale: CGFloat(scale), orientation: imageView.image!.imageOrientation)
    }
    
    open var cgImage: CGImage {
        return uiimage.cgImage!
    }
    
    open var ciImage: CIImage {
        return CIImage(cgImage: cgImage)
    }
    
    open var contents: CGImage {
        get {
            return imageView.layer.contents as! CGImage
        }
        set {
            imageView.layer.contents = newValue
        }
    }
    
    open override var rotation: Double {
        get {
            if let numer = imageLayer.value(forKeyPath: Layer.rotationKey) as? NSNumber {
                return numer.doubleValue
            }
            return 0
        }
        set {
            imageLayer.setValue(newValue, forKey: Layer.rotationKey)
        }
    }
    
    var scale: Double {
        return Double(imageView.image!.scale)
    }
    
    public override var width: Double {
        get {
            return Double(view.frame.width)
        }
        set {
            var newSize = Size(newValue, Double(view.frame.height))
            if constrainsProportions {
                let ratio = Double(size.height / size.width)
                newSize.height = newValue * ratio
            }
            var rect = frame
            rect.size = newSize
            frame = rect
        }
    }
    
    public override var height: Double {
        get {
            return Double(view.frame.height)
        }
        set {
            var newSize = Size(Double(view.frame.width), newValue)
            if constrainsProportions {
                let ratio = Double(size.width / size.height)
                newSize.width = newValue * ratio
            }
            var rect = frame
            rect.size = newSize
            frame = rect
        }
    }
    
    open var constrainsProportions: Bool = false
    
    internal var _originalSize: Size = Size()
    public var originalSize: Size {
        return _originalSize
    }
    
    public var originalRatio: Double {
        return _originalSize.width / _originalSize.height
    }
    
    lazy internal var output: CIImage = self.ciImage
    lazy internal var filterQueue: DispatchQueue = DispatchQueue.global(qos: .background)
    lazy internal var renderImmediately = true
    
    public override init() {
        super.init()
        let uiimage = UIImage()
        self.view = ImageView(image: uiimage)
    }
    
    public override init(frame: Rect) {
        super.init(frame: frame)
        let uiimage = UIImage()
        let imageView = ImageView(image: uiimage)
        imageView.frame = self.view.bounds
        self.view = imageView
    }
    
    public convenience init?(_ name: String) {
        self.init(name, scale: 1.0)
    }
    
    public convenience init?(_ name: String, scale: Double) {
        guard let image = UIImage(named: name) else {
            return nil
        }
        self.init(uiimage: image, scale: scale)
    }
    
    convenience public init(uiimage: UIImage, scale: Double) {
        self.init()
        if scale != 1.0 {
            let scaledImage = UIImage(cgImage: uiimage.cgImage!, scale: CGFloat(scale), orientation: uiimage.imageOrientation)
            self.view = ImageView(image: scaledImage)
        } else {
            self.view = ImageView(image: uiimage)
        }
    }
    
    convenience public init(copy image: Image) {
        self.init()
        let uiimage = image.uiimage
        self.view = ImageView(image: uiimage)
        copyViewStyle(image)
    }
    
    convenience public init(uiimage: UIImage) {
        self.init(uiimage: uiimage, scale: 1.0)
    }
    
    convenience public init(cgimage: CGImage) {
        let image = UIImage(cgImage: cgimage)
        self.init(uiimage: image, scale: 1.0)
    }
    
    convenience public init(cgimage: CGImage, scale: Double) {
        let image = UIImage(cgImage: cgimage)
        self.init(uiimage: image, scale: scale)
    }
    
    convenience public init(ciimage: CIImage) {
        self.init(ciimage: ciimage, scale: 1.0)
    }
    
    convenience public init(ciimage: CIImage, scale: Double) {
        let image = UIImage(ciImage: ciimage)
        self.init(uiimage: image, scale: scale)
    }
    
    convenience public init(data: Data) {
        self.init(data: data, scale: 1.0)
    }
    
    convenience public init(data: Data, scale: Double) {
        let image = UIImage(data: data)
        self.init(uiimage: image!, scale: scale)
    }
    
    convenience public init(url: URL) {
        self.init(url: url, scale: 1.0)
    }
    
    convenience public init(url: URL, scale: Double) {
        var error: NSError?
        var data: Data?
        do {
            data = try Data(contentsOf: url, options: .mappedIfSafe)
        } catch let error1 as NSError {
            error = error1
            data = nil
        }
        if let d = data {
            self.init(data: d, scale: scale)
            return
        }
        if let e = error {
            Log("loading Image fomr url: \(url), error: \(e.localizedDescription)")
        }
        self.init()
    }
    
    convenience public init(pixels: [Pixel], size: Size) {
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo: CGBitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let bitsPerComponent: Int = 8
        let bitPerPixel: Int = 32
        let width: Int = Int(size.width)
        let height: Int = Int(size.height)
        
        assert(pixels.count == Int(width * height))
        
        var provider: CGDataProvider?
        pixels.withUnsafeBufferPointer { p in
            if let address = p.baseAddress {
                let data = Data(bytes: address, count: pixels.count * MemoryLayout<Pixel>.size)
                provider = CGDataProvider(data: data as CFData)
            }
        }
        
        let cgim = CGImage(width: width,
                           height: height,
                           bitsPerComponent: bitsPerComponent,
                           bitsPerPixel: bitPerPixel,
                           bytesPerRow: width * Int(MemoryLayout<Pixel>.size),
                           space: rgbColorSpace,
                           bitmapInfo: bitmapInfo,
                           provider: provider!,
                           decode: nil,
                           shouldInterpolate: true,
                           intent: .defaultIntent)
        self.init(cgimage: cgim!)
    }
    
    convenience public init(c4image: Image) {
        let cgim = c4image.cgImage
        self.init(cgimage: cgim, scale: c4image.scale)
    }
    
    public func copy(with zone: NSZone? = nil) -> Any {
        let uiimage = UIImage(cgImage: contents)
        let img = Image(uiimage: uiimage, scale: scale)
        img.frame = frame
        img.constrainsProportions = constrainsProportions
        img._originalSize = _originalSize
        return img
    }
}
