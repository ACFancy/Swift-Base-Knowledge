//
//  ScreenRecorder.swift
//  Cos
//
//  Created by Lee Danatech on 2021/5/19.
//

import ReplayKit

public class ScreenRecorder : NSObject, RPPreviewViewControllerDelegate {
    public typealias PreviewControllerFinishedAction = (_ activities: Set<String>?) -> Void
    public typealias RecorderStoppedAction = () -> Void
    
    let recorder = RPScreenRecorder.shared()
    var preview: RPPreviewViewController?
    var activities: Set<String>?
    
    public var previewFinishedAction: PreviewControllerFinishedAction?
    public var recordingEndedAction: RecorderStoppedAction?
    public var enableMicrophone = false
    
    public var recording: Bool {
        return recorder.isRecording
    }
    
    public var available: Bool {
        return recorder.isAvailable
    }
    
    public func start() {
        guard !recording, available else {
            return
        }
        guard #available(iOS 13, *) else {
            recorder.startRecording(withMicrophoneEnabled: enableMicrophone) { error in
                guard let error = error else {
                    return
                }
                debugPrint(error.localizedDescription)
            }
            return
        }
        recorder.isMicrophoneEnabled = enableMicrophone
        recorder.startRecording { error in
            guard let error = error else {
                return
            }
            debugPrint(error.localizedDescription)
        }
    }
    
    public func start(_ duration: Double) {
        start()
        wait(duration) { [weak self] in
            self?.stop()
        }
    }
    
    public func stop() {
        recorder.stopRecording { [weak self] previewViewController, _ in
            guard let self = self else { return }
            self.preview = previewViewController
            self.preview?.previewControllerDelegate = self
            self.recordingEndedAction?()
        }
    }
    
    public func showPreviewInController(_ controller: UIViewController) {
        guard let preview = preview else {
            return
        }
        controller.present(preview, animated: true)
    }
    
    #if os(iOS)
    public func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
        previewFinishedAction?(activities)
        preview?.presentingViewController?.dismiss(animated: true)
    }
    
    public func previewController(_ previewController: RPPreviewViewController, didFinishWithActivityTypes activityTypes: Set<String>) {
        activities = activityTypes
    }
    #endif
}
