//
//  Camera.swift
//  Cos
//
//  Created by Lee Danatech on 2021/5/19.
//

import UIKit
import AVFoundation

public enum CameraPosition: Int {
    case unspecified = 0
    case back
    case front
}

public class Camera : View {
    class CameraView : UIView {
        var previewLayer: PreviewLayer {
            return self.layer as! PreviewLayer
        }

        override class var layerClass: AnyClass {
            return PreviewLayer.self
        }
    }

    public var capturedImage: Image?
    public var quality: AVCaptureSession.Preset = .photo
    public var position: CameraPosition = .front

    var imageOutput: AVCaptureStillImageOutput?
    var captureDevice: AVCaptureDevice?
    var previewView: CameraView?
    var input: AVCaptureDeviceInput?
    var stillImageOutput: AVCaptureStillImageOutput?
    var captureSession: AVCaptureSession?
    var didCaptureAction: (() -> Void)?
    var orientationObserver: Any?

    var previewLayer: PreviewLayer {
        return cameraView.previewLayer
    }

    var cameraView: CameraView {
        return self.view as! CameraView
    }

    public override init(frame: Rect) {
        super.init()
        view = CameraView()
        view.frame = CGRect(frame)
        previewLayer.backgroundColor = clear.cgColor
        previewLayer.videoGravity = .resizeAspectFill

        orientationObserver = on(event: UIDevice.orientationDidChangeNotification) { [unowned self] in
            self.updateOrientation()
        }
    }

    deinit {
        if let observer = orientationObserver {
            cancel(observer)
        }
    }

    public func startCapture(_ position: CameraPosition = .front) {
        self.position = position
        guard let cd = captureDevice(position) else {
            return
        }
        initializeInput(cd)
        guard input != nil else {
            return
        }
        initializeOutput(cd)
        captureDevice = cd
        initializeCaptureSession()
        captureSession?.startRunning()
        updateOrientation()
    }

    public func captureImage() {
        guard stillImageOutput?.isCapturingStillImage == false else {
            return
        }
        guard let connnection = stillImageOutput?.connection(with: .video), connnection.isActive else {
            return
        }
        updateOrientation()
        connnection.videoOrientation = previewLayer.connection!.videoOrientation
        stillImageOutput?.captureStillImageAsynchronously(from: connnection, completionHandler: { imageSampleBuffer, _ in
            guard let buffer = imageSampleBuffer, buffer.isValid else {
                return
            }
            let data = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer)
            if let tdata = data, let image = UIImage(data: tdata) {
                self.capturedImage = Image(uiimage: self.orientRaowImage(image))
                self.didCaptureAction?()
            }
        })
    }

    public func didCaptureImage(_ action: (() -> Void)?) {
        didCaptureAction = action
    }

    func captureDevice(_ position: CameraPosition) -> AVCaptureDevice? {
        guard #available(iOS 10, *) else {
            return AVCaptureDevice.devices(for: .video).first(where: { $0.position.rawValue == position.rawValue })
        }
        return AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera],
                                                mediaType: .video,
                                                position: AVCaptureDevice.Position(rawValue: position.rawValue)!).devices.first

    }

    func updateOrientation() {
        guard let connection = previewLayer.connection, connection.isVideoOrientationSupported else {
            return
        }
        guard #available(iOS 13, *) else {
            switch UIApplication.shared.statusBarOrientation {
            case .portraitUpsideDown:
                connection.videoOrientation = .portraitUpsideDown
            case .landscapeLeft:
                connection.videoOrientation = .landscapeLeft
            case .landscapeRight:
                connection.videoOrientation = .landscapeRight
            default:
                connection.videoOrientation = .portrait
            }
            return
        }
        let orientation = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.windowScene?.interfaceOrientation ?? .portrait
        switch orientation {
        case .landscapeLeft:
            connection.videoOrientation = .landscapeLeft
        case .landscapeRight:
            connection.videoOrientation = .landscapeRight
        case .portraitUpsideDown:
            connection.videoOrientation = .portraitUpsideDown
        default:
            connection.videoOrientation = .portrait
        }
    }

    func initializeInput(_ device: AVCaptureDevice) {
        guard input == nil else {
            return
        }
        do {
            input = try AVCaptureDeviceInput(device: device)
        } catch {
            return
        }
    }

    func initializeOutput(_ device: AVCaptureDevice) {
        guard stillImageOutput == nil else {
            return
        }
        stillImageOutput = AVCaptureStillImageOutput()
        stillImageOutput?.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
    }

    func initializeCaptureSession() {
        if captureSession == nil {
            captureSession = AVCaptureSession()
            previewLayer.session = captureSession
        }
        let session = captureSession!
        session.sessionPreset = quality
        for input in session.inputs {
            session.removeInput(input)
        }
        session.addInput(input!)
        for output in session.outputs {
            session.removeOutput(output)
        }
        session.addOutput(stillImageOutput!)
    }

    func orientRaowImage(_ image: UIImage) -> UIImage {
        guard let cgimg = image.cgImage, let videoOrientation = previewLayer.connection?.videoOrientation else {
            return image
        }
        var orientation: UIImage.Orientation
        let shouldFlip = position == .front

        switch videoOrientation {
        case .landscapeLeft:
            orientation = shouldFlip ? .upMirrored : .down
        case .landscapeRight:
            orientation = shouldFlip ? .downMirrored : .up
        case .portrait:
            orientation = shouldFlip ? .leftMirrored : .right
        case .portraitUpsideDown:
            orientation = shouldFlip ? .rightMirrored : .left
        @unknown default:
            orientation = shouldFlip ? .leftMirrored : .right
        }
        return UIImage(cgImage: cgimg, scale: image.scale, orientation: orientation)
    }
    
}


class PreviewLayer : AVCaptureVideoPreviewLayer {}

