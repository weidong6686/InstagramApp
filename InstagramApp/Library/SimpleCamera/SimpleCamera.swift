//
//  SimpleCamera.swift
//  SimpleCamera
//
//

/*
 
 MIT License
 
 Copyright (c) 2018 Gwinyai Nyatsoka
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 */

import AVFoundation

import Photos

import UIKit

/*
 AVCaptureSession.startRunning() is a blocking call which can
 take a long time. We dispatch session setup to the sessionQueue so
 that the main queue isn't blocked, which keeps the UI responsive.
 */


class SimpleCamera: NSObject, SimpleCameraProtocol {
    
    fileprivate lazy var session: AVCaptureSession = {
        
        return AVCaptureSession()
        
    }()
    
    fileprivate lazy var movieOutput: AVCaptureMovieFileOutput = {
        
        return AVCaptureMovieFileOutput()
        
    }()
    
    fileprivate lazy var photoOutput: AVCapturePhotoOutput = {
        
        return AVCapturePhotoOutput()
        
    }()
    
    var isVideoRecording: Bool {
        
        return movieOutput.isRecording
        
    }
    
    fileprivate var isCaptureSessionConfigured = false
    
    fileprivate var photoSampleBuffer: CMSampleBuffer?
    
    fileprivate var previewPhotoSampleBuffer: CMSampleBuffer?
    
    fileprivate var activeInput: AVCaptureDeviceInput?
    
    fileprivate var outputURL: URL?
    
    fileprivate var videoSessionPreset: AVCaptureSession.Preset = AVCaptureSession.Preset.high
    
    fileprivate var photoSessionPreset: AVCaptureSession.Preset = AVCaptureSession.Preset.photo
    
    fileprivate var cameraPosition: SimpleCameraPosition = .back
    
    fileprivate var photoCompletionHandler: PhotoCompletionHandler?
    
    fileprivate var videoCompletionHandler: VideoCompletionHandler?
    
    fileprivate var setCameraCompletionHandler: SetCameraCompletionHandler?
    
    fileprivate var setPhotoCompletionHandler: SetPhotoCompletionHandler?
    
    fileprivate var setVideoCompletionHandler: SetVideoCompletionHandler?
    
    fileprivate var flashMode: SimpleCameraFlashMode = .off
    
    fileprivate var torchMode: SimpleCameraTorchMode = .off
    
    fileprivate var cameraView: SimpleCameraView
    
    fileprivate var isCameraAuthorized: Bool {
        
        get {
            
            let cameraMediaType = AVMediaType.video
            
            let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: cameraMediaType)
            
            if cameraAuthorizationStatus == .authorized {
                
                return true
                
            }
            else {
                
                return false
                
            }
            
        }
        
    }
    
    var currentCaptureMode: SimpleCameraCaptureMode = .photo
    
    private lazy var videoDeviceDiscoverySession = {
        
        return AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera, .builtInDualCamera], mediaType: AVMediaType.video, position: .unspecified)
        
    }()
    
    private override init() {
        
        self.cameraView = SimpleCameraView()
        
    }
    
    init(cameraView: SimpleCameraView) {
        
        self.cameraView = cameraView
        
    }
    
    init(cameraView: SimpleCameraView, videoPreset: AVCaptureSession.Preset, photoPreset: AVCaptureSession.Preset, cameraPosition: SimpleCameraPosition, captureMode: SimpleCameraCaptureMode) {
        
        self.videoSessionPreset = videoPreset
        
        self.photoSessionPreset = photoPreset
        
        self.cameraPosition = cameraPosition
        
        self.currentCaptureMode = captureMode
        
        self.cameraView = cameraView
        
    }
    
    init(cameraView: SimpleCameraView, cameraPosition: SimpleCameraPosition, captureMode: SimpleCameraCaptureMode) {
        
        self.cameraPosition = cameraPosition
        
        self.currentCaptureMode = captureMode
        
        self.cameraView = cameraView
        
    }
    
    func toggleCamera(completion: @escaping SetCameraCompletionHandler) {
        
        setCameraCompletionHandler = completion
        
        sessionQueue().async { [unowned self] in
            
            guard let activeInput = self.activeInput else {
                
                self.setCameraCompletionHandler!(false)
                
                return
                
            }
            
            let currentVideoDevice = activeInput.device
            
            let currentPosition = currentVideoDevice.position
            
            let preferredPosition: AVCaptureDevice.Position
            
            let preferredDeviceType: AVCaptureDevice.DeviceType
            
            switch currentPosition {
                
            case .unspecified, .front:
                
                preferredPosition = .back
                
                preferredDeviceType = .builtInDualCamera
                
            case .back:
                
                preferredPosition = .front
                
                preferredDeviceType = .builtInWideAngleCamera
                
            }
            
            self.changeCameraPosition(activeInput: activeInput, preferredPosition: preferredPosition, preferredDeviceType: preferredDeviceType)
            
        }
        
    }
    
    func setCamera(position: SimpleCameraPosition, completion: @escaping SetCameraCompletionHandler) {
        
        setCameraCompletionHandler = completion
        
        if cameraPosition == position {
            
            setCameraCompletionHandler!(true)
            
            return
            
        }
        
        sessionQueue().async { [unowned self] in
            
            guard let activeInput = self.activeInput else { return }
            
            let preferredPosition: AVCaptureDevice.Position
            
            let preferredDeviceType: AVCaptureDevice.DeviceType
            
            switch position {
                
            case .back:
                
                preferredDeviceType = .builtInDualCamera
                
                preferredPosition = AVCaptureDevice.Position.back
                
            case .front:
                
                preferredDeviceType = .builtInDualCamera
                
                preferredPosition = AVCaptureDevice.Position.front
                
            case .unspecified:
                
                self.setCameraCompletionHandler!(false)
                
                return
                
            }
            
            self.changeCameraPosition(activeInput: activeInput, preferredPosition: preferredPosition, preferredDeviceType: preferredDeviceType)
            
        }
        
    }
    
    fileprivate func changeCameraPosition(activeInput: AVCaptureDeviceInput, preferredPosition: AVCaptureDevice.Position, preferredDeviceType: AVCaptureDevice.DeviceType) {
        
        let devices = self.videoDeviceDiscoverySession.devices
        
        var newVideoDevice: AVCaptureDevice? = nil
        
        if let device = devices.filter({ $0.position == preferredPosition && $0.deviceType == preferredDeviceType }).first {
            
            newVideoDevice = device
            
        }
        else if let device = devices.filter({ $0.position == preferredPosition }).first {
            
            newVideoDevice = device
            
        }
        
        if let videoDevice = newVideoDevice {
            
            do {
                
                if videoDevice.position == .front || videoDevice.position == .unspecified {
                    
                    self.setTorchMode(newTorchMode: SimpleCameraTorchMode.na)
                    
                    self.setFlashMode(newFlashMode: SimpleCameraFlashMode.na)
                    
                    self.flashMode = .na
                    
                    self.torchMode = .na
                    
                }
                else {
                    
                    self.setTorchMode(newTorchMode: SimpleCameraTorchMode.off)
                    
                    self.setFlashMode(newFlashMode: SimpleCameraFlashMode.off)
                    
                    self.flashMode = .off
                    
                    self.torchMode = .off
                    
                }
                
                let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
                
                self.session.beginConfiguration()
                
                self.session.removeInput(activeInput)
                
                if self.session.canAddInput(videoDeviceInput) {
                    
                    self.session.addInput(videoDeviceInput)
                    
                    self.activeInput = videoDeviceInput
                    
                }
                else {
                    
                    self.session.addInput(activeInput)
                    
                }
                
                if let connection = self.movieOutput.connection(with: AVMediaType.video) {
                    
                    if connection.isVideoStabilizationSupported {
                        
                        connection.preferredVideoStabilizationMode = .auto
                        
                    }
                    
                }
                
                self.session.commitConfiguration()
                
                switch self.cameraPosition {
                    
                case .back:
                    
                    self.cameraPosition = SimpleCameraPosition.front
                    
                case .front:
                    
                    self.cameraPosition = SimpleCameraPosition.back
                    
                case .unspecified:
                    
                    self.cameraPosition = SimpleCameraPosition.unspecified
                    
                }
                
                if let cameraCompletionHandler = setCameraCompletionHandler {
                    
                    cameraCompletionHandler(true)
                    
                }
                
            }
            catch {
                
                print("Error occured while creating video device input: \(error)")
                
                if let cameraCompletionHandler = setCameraCompletionHandler {
                    
                    cameraCompletionHandler(false)
                    
                }
                
            }
            
        }
        else {
            
            if let cameraCompletionHandler = setCameraCompletionHandler {
                
                cameraCompletionHandler(false)
                
            }
            
        }
        
    }
    
    func setPhotoMode(completion: @escaping SetPhotoCompletionHandler) {
        
        setPhotoCompletionHandler = completion
        
        setCamera(position: .back) { [unowned self] (success) in
            
            if success {
                
                self.sessionQueue().async {
                    
                    self.session.beginConfiguration()
                    
                    self.session.removeOutput(self.movieOutput)
                    
                    self.session.sessionPreset = self.photoSessionPreset
                    
                    self.setFlashMode(newFlashMode: .off)
                    
                    self.setTorchMode(newTorchMode: .off)
                    
                    self.torchMode = SimpleCameraTorchMode.off
                    
                    self.flashMode = SimpleCameraFlashMode.off
                    
                    self.currentCaptureMode = SimpleCameraCaptureMode.photo
                    
                    self.session.commitConfiguration()
                    
                    self.setPhotoCompletionHandler!(true)
                    
                }
                
            }
            else {
                
                self.setPhotoCompletionHandler!(false)
                
                return
                
            }
            
        }
        
    }
    
    func setVideoMode(completion: @escaping SetVideoCompletionHandler) {
        
        setVideoCompletionHandler = completion
        
        sessionQueue().async { [unowned self] in
            
            if self.session.canAddOutput(self.movieOutput) {
                
                self.setCamera(position: SimpleCameraPosition.back, completion: { (success) in
                    
                    if success {
                        
                        self.session.beginConfiguration()
                        
                        self.session.addOutput(self.movieOutput)
                        
                        self.session.sessionPreset = self.videoSessionPreset
                        
                        self.setTorchMode(newTorchMode: .off)
                        
                        self.setFlashMode(newFlashMode: .off)
                        
                        self.torchMode = SimpleCameraTorchMode.off
                        
                        self.flashMode = SimpleCameraFlashMode.off
                        
                        self.currentCaptureMode = SimpleCameraCaptureMode.video
                        
                        self.session.commitConfiguration()
                        
                        self.setVideoCompletionHandler!(true)
                        
                    }
                    else {
                        
                        self.setVideoCompletionHandler!(false)
                        
                    }
                    
                })
                
            }
            else {
                
                self.setVideoCompletionHandler!(false)
                
            }
            
        }
        
    }
    
    func toggleFlash() -> SimpleCameraFlashMode? {
        
        if currentCaptureMode != .photo {
            
            return nil
            
        }
        
        guard let activeInput = activeInput else {
            
            flashMode = SimpleCameraFlashMode.na
            
            return flashMode
            
        }
        
        if activeInput.device.position == .front || activeInput.device.position == .unspecified {
            
            flashMode = SimpleCameraFlashMode.na
            
            return flashMode
            
        }
        else {
            
            var currentMode = flashMode.rawValue
            
            currentMode += 1
            
            if currentMode > 2 {
                
                currentMode = 0
                
            }
            
            flashMode = SimpleCameraFlashMode(rawValue: currentMode)!
            
        }
        
        return flashMode
        
    }
    
    func toggleTorch() -> SimpleCameraTorchMode? {
        
        if currentCaptureMode != .video {
            
            return nil
            
        }
        
        guard let activeInput = activeInput else {
            
            return nil
            
        }
        
        let device = activeInput.device
        
        if device.hasTorch {
            
            var currentMode = activeInput.device.torchMode.rawValue
            
            if activeInput.device.position == .front || activeInput.device.position == .unspecified {
                
                currentMode = 0
                
            }
            else {
                
                currentMode += 1
                
                if currentMode > 1 {
                    
                    currentMode = 0
                    
                }
                
            }
            
            let newMode = AVCaptureDevice.TorchMode(rawValue: currentMode)!
            
            if device.isTorchModeSupported(newMode) {
                
                do {
                    
                    try device.lockForConfiguration()
                    
                    device.torchMode = newMode
                    
                    device.unlockForConfiguration()
                    
                    return SimpleCameraTorchMode(rawValue: newMode.rawValue)
                    
                } catch {
                    
                    print("Error setting torch mode: \(error)")
                    
                }
                
            }
            
        }
        
        return nil
        
    }
    
    func setTorchMode(newTorchMode: SimpleCameraTorchMode) {
        
        if currentCaptureMode != .video {
            
            return
            
        }
        
        guard let device = activeInput?.device else { return }
        
        if (device.hasTorch) {
            
            let newMode = AVCaptureDevice.TorchMode(rawValue: newTorchMode.rawValue)!
            
            if device.isTorchModeSupported(newMode) {
                
                do {
                    
                    try device.lockForConfiguration()
                    
                    device.torchMode = newMode
                    
                    device.unlockForConfiguration()
                    
                    torchMode = SimpleCameraTorchMode(rawValue: newMode.rawValue)!
                    
                } catch {
                    
                    print("Error setting torch mode: \(error)")
                    
                }
                
            }
            
        }
        
    }
    
    func setFlashMode(newFlashMode: SimpleCameraFlashMode) {
        
        if currentCaptureMode != .photo {
            
            return
            
        }
        
        guard let activeInput = activeInput else {
            
            return
            
        }
        
        if activeInput.device.position == .front || activeInput.device.position == .unspecified {
            
            return
            
        }
        else {
            
            flashMode = newFlashMode
            
        }
        
    }
    
    func currentFlashMode() -> SimpleCameraFlashMode {
        
        return flashMode
        
    }
    
    func currentTorchMode() -> SimpleCameraTorchMode {
        
        return torchMode
        
    }
    
    func setupPreview() -> AVCaptureSession {
        
        return session
        
    }
    
    func configureSession() -> Bool {
        
        cameraView.set(session: session)
        
        // prepare to make changes
        session.beginConfiguration()
        
        switch currentCaptureMode {
            
        case.photo:
            
            session.sessionPreset = photoSessionPreset
            
        case .video:
            
            session.sessionPreset = videoSessionPreset
            
        }
        
        let microphone = AVCaptureDevice.default(for: AVMediaType.audio)
        
        do {
            
            let micInput = try AVCaptureDeviceInput(device: microphone!)
            
            if session.canAddInput(micInput) {
                
                session.addInput(micInput)
                
            }
        } catch {
            
            print("Error setting device audio input: \(error)")
            
            return false
            
        }
        
        do {
            
            let videoCaptureDevice = AVCaptureDevice.default(for: AVMediaType.video)
            
            let videoDeviceInput = try AVCaptureDeviceInput(device: videoCaptureDevice!)
            
            if session.canAddInput(videoDeviceInput) {
                
                session.addInput(videoDeviceInput)
                
                activeInput = videoDeviceInput
                
            } else {
                
                print("Failed to add video device input")
                
                session.commitConfiguration()
                
                return false
                
            }
            
            if session.canAddOutput(photoOutput) {
                
                session.addOutput(photoOutput)
                
                photoOutput.isHighResolutionCaptureEnabled = true
                
            } else {
                
                print("Failed to add photo output")
                
                session.commitConfiguration()
                
                return false
                
            }
            
        } catch {
            
            print("Failed to create device input: \(error)")
            
            session.commitConfiguration()
            
            return false
            
        }
        
        session.commitConfiguration()
        
        self.sessionQueue().async {
            
            self.session.startRunning()
            
        }
        
        return true
        
    }
    
    func stopSession() {
        
        if session.isRunning {
            
            sessionQueue().async { [unowned self] in
                
                self.session.stopRunning()
                
            }
            
        }
        
    }
    
    func startSession() {
        
        if self.isCaptureSessionConfigured {
            
            if !self.session.isRunning {
                
                self.sessionQueue().async {
                    
                    self.session.startRunning()
                    
                }
                
            }
            
        } else {
            
            self.checkCameraAuthorization({ [weak self] authorized in
                
                guard let strongSelf = self else { return }
                
                guard authorized else {
                    
                    print("Permission to use camera denied.")
                    
                    return
                    
                }
                
                strongSelf.sessionQueue().async {
                    
                    if strongSelf.configureSession() {
                        
                        strongSelf.isCaptureSessionConfigured = true
                        
                        strongSelf.session.startRunning()
                        
                    }
                    
                }
                
            })
            
        }
        
    }
    
    func sessionQueue() -> DispatchQueue {
        
        return DispatchQueue.main
        
    }
    
    fileprivate func currentVideoOrientation() -> AVCaptureVideoOrientation {
        
        var orientation: AVCaptureVideoOrientation
        
        switch UIDevice.current.orientation {
            
        case .portrait:
            
            orientation = AVCaptureVideoOrientation.portrait
            
        case .landscapeRight:
            
            orientation = AVCaptureVideoOrientation.landscapeLeft
            
        case .portraitUpsideDown:
            
            orientation = AVCaptureVideoOrientation.portraitUpsideDown
            
        default:
            
            orientation = AVCaptureVideoOrientation.landscapeRight
            
        }
        
        return orientation
        
    }
    
    fileprivate func checkCameraAuthorization(_ completionHandler: @escaping ((_ authorized: Bool) -> Void)) {
        
        switch AVCaptureDevice.authorizationStatus(for: AVMediaType.video) {
            
        case .authorized:
            
            completionHandler(true)
            
        case .notDetermined:
            
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { success in
                
                completionHandler(success)
                
            })
            
        case .denied:
            
            completionHandler(false)
            
        case .restricted:
            
            completionHandler(false)
        }
    }
    
    func takePhoto(photoCompletionHandler: @escaping PhotoCompletionHandler) {
        
        if currentCaptureMode != .photo {
            
            return
            
        }
        
        let photoSettings = AVCapturePhotoSettings.init(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        
        var flashModeSetting: AVCaptureDevice.FlashMode!
        
        switch flashMode {
            
        case .auto:
            flashModeSetting = AVCaptureDevice.FlashMode.auto
            
        case.off:
            flashModeSetting = AVCaptureDevice.FlashMode.off
            
        case .on:
            flashModeSetting = AVCaptureDevice.FlashMode.on
            
        case .na:
            
            flashModeSetting = AVCaptureDevice.FlashMode.off
            
        }
        
        photoSettings.flashMode = flashModeSetting
        
        photoOutput.capturePhoto(with: photoSettings, delegate: self)
        
        self.photoCompletionHandler = photoCompletionHandler
        
    }
    
    func takeVideo(videoCompletionHandler: @escaping VideoCompletionHandler) {
        
        if currentCaptureMode != .video {
            
            return
            
        }
        
        if movieOutput.isRecording == false {
            
            if let connection = movieOutput.connection(with: AVMediaType.video) {
                
                if connection.isVideoOrientationSupported {
                    
                    connection.videoOrientation = currentVideoOrientation()
                    
                }
                
                if connection.isVideoStabilizationSupported {
                    
                    connection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationMode.auto
                    
                }
                
            }
            
            guard let device = activeInput?.device else {
                
                videoCompletionHandler(nil, false)
                
                return
                
            }
            
            if device.isSmoothAutoFocusSupported {
                
                do {
                    
                    try device.lockForConfiguration()
                    
                    device.isSmoothAutoFocusEnabled = false
                    
                    device.unlockForConfiguration()
                    
                } catch {
                    
                    print("Error setting configuration: \(error)")
                    
                }
                
            }
            
            outputURL = tempURL()
            
            movieOutput.startRecording(to: outputURL!, recordingDelegate: self)
            
            self.videoCompletionHandler = videoCompletionHandler
            
        }
        else {
            
            stopRecording()
            
        }
        
    }
    
    
    func stopRecording() {
        
        if movieOutput.isRecording == true {
            
            movieOutput.stopRecording()
            
        }
        
    }
    
}

extension SimpleCamera: AVCapturePhotoCaptureDelegate, AVCaptureFileOutputRecordingDelegate {
    
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        
        
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        
        if (error != nil) {
            print("Error recording movie: \(error!.localizedDescription)")
            
            videoCompletionHandler!(nil, false)
            
        } else {
            
            let videoRecorded = outputURL! as URL
            
            videoCompletionHandler!(videoRecorded, true)
            
        }
        
    }
    
    func tempURL() -> URL? {
        
        let directory = NSTemporaryDirectory() as NSString
        
        if directory != "" {
            
            let path = directory.appendingPathComponent(NSUUID().uuidString + ".mp4")
            
            return URL(fileURLWithPath: path)
            
        }
        
        return nil
        
    }
    
    func photoOutput(_ captureOutput: AVCapturePhotoOutput,
                     willBeginCaptureFor resolvedSettings:
        AVCaptureResolvedPhotoSettings) {
        // update the UI?
    }
    
    func photoOutput(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        
        guard error == nil, let photoSampleBuffer = photoSampleBuffer else {
            print("Error capturing photo: \(String(describing: error))")
            return
        }
        
        self.photoSampleBuffer = photoSampleBuffer
        
        self.previewPhotoSampleBuffer = previewPhotoSampleBuffer
        
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        guard let photoCompletionHandler = self.photoCompletionHandler else { return }
        
        guard error == nil else {
            
            print("Error in capture process: \(String(describing: error))")
            
            photoCompletionHandler(nil, false)
            
            return
            
        }
        
        guard let imageData = photo.fileDataRepresentation() else {
            
            print("Unable to create image data.")
            
            photoCompletionHandler(nil, false)
            
            return
            
        }
        
        photoCompletionHandler(imageData, true)
        
    }
    
}
