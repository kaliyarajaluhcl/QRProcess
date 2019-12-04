/*
 *    @file   CameraScanner.swift
 *    @target BoeingDistributionMobile
 **
 */

import Foundation
import AVFoundation

open class CameraScanner: NSObject {
    
    open weak var delegate: CameraScannerDelegate? {
        didSet { self.prepareCamera() }
    }
    var isFirstFrameCaptured: Bool = false
    var firstFrameCaptureTime: Int64 = 0
    private let scannerQueue = DispatchQueue(label: ViewConstant.scanner.cameraScannerQueue)
    private let metadataScannerQueue = DispatchQueue(label: ViewConstant.scanner.metadataCameraScannerQueue)
    
    private var captureSession: AVCaptureSession
    private var captureDevice: AVCaptureDevice?
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    private var output: AVCaptureMetadataOutput?
    
    private var videoPermission: VideoPermission
    private var codeTypes: [CodeType]
    
    /// Rect for scanning focus area. It calculate coordinates of ROI based on coordinates of videoPreview.
    private var roiBounds: CGRect {
        guard let roi = delegate?.rectOfInterest, let videoPreview = delegate?.videoPreview else {
            return CGRect.zero
        }
        return roi.convert(roi.bounds, to: videoPreview)
    }
    
    open var isCapturing: Bool {
        return captureSession.isRunning
    }
    
    deinit {
        captureSession.stopRunning()
        videoPreviewLayer?.removeFromSuperlayer()
        delegate = nil
        
        if let output = output {
            captureSession.removeOutput(output)
        }
    }
    
    /// Initialize the captureSession object.
    public init(codeTypes: [CodeType]) {
        captureSession = AVCaptureSession()
        videoPermission = VideoPermission()
        self.codeTypes = codeTypes
    }
    
    /// prepareCamera method should be executed only when delegate is set.
    private func prepareCamera() {
        self.scannerQueue.async {
            self.videoPermission.checkPersmission { [weak self] error in
                guard let `self` = self else { return }
                
                guard error == nil else {
                    DispatchQueue.main.async {
                        self.delegate?.cameraScanner(self, didReceiveError: CameraScannerError.notAuthorizedToUseCamera)
                    }
                    return
                }
                
                self.prepareVideoPreviewLayer()
                self.setupSessionInput(for: .back)
                self.setupSessionOutput()
                
                DispatchQueue.main.async {
                    self.insertPreviewLayer()
                    self.layoutFrames()
                    self.delegate?.cameraScannerDidSetup(self)
                }
            }
        }
    }
    
    /// Initialize the video preview layer and set its videoGravity
    private func prepareVideoPreviewLayer() {
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
    }
    
    /// Layout videoPreviewLayer. This method should be executed in main thread.
    func layoutFrames() {
        self.videoPreviewLayer.frame = self.delegate?.videoPreview.bounds ?? .zero
        self.delegate?.videoPreview.setNeedsLayout()
    }
    
    fileprivate func insertPreviewLayer() {
        self.delegate?.videoPreview.layer.insertSublayer(self.videoPreviewLayer, at: 0)
    }
    
    /**
     Setup instance of the AVCaptureDevice class to initialize a device object
     and provide the video as the media type parameter.
     */
    private func setupSessionInput(for position: CameraPosition) {
        if DeviceEnvironment.current == .simulator { return }
        
        guard let device = CameraScanner.Camera.device(for: position) else {
            delegate?.cameraScanner(self, didReceiveError: CameraScannerError.cameraNotFound)
            return
        }
        
        // Get an instance of the AVCaptureDeviceInput class using the previous device object.
        do {
            let input = try AVCaptureDeviceInput(device: device)
            try device.lockForConfiguration()
            captureSession.beginConfiguration()
            
            // autofocus settings and focus on middle point
            device.autoFocusRangeRestriction = .near
            device.focusMode = .continuousAutoFocus
            device.exposureMode = .continuousAutoExposure
            
            if let currentInput = captureSession.inputs.filter({$0 is AVCaptureDeviceInput}).first {
                captureSession.removeInput(currentInput)
            }
            
            // Set the input device on the capture session.
            
            if device.supportsSessionPreset(.hd1920x1080) == true {
                captureSession.sessionPreset = .hd1920x1080
            } else if device.supportsSessionPreset(.high) == true {
                captureSession.sessionPreset = .high
            }
            
            captureSession.usesApplicationAudioSession = false
            captureSession.addInput(input)
            captureSession.commitConfiguration()
            captureSession.automaticallyConfiguresCaptureDeviceForWideColor = true
            if device.isLowLightBoostSupported == true {
                device.automaticallyEnablesLowLightBoostWhenAvailable = true
            }
            device.unlockForConfiguration()
            captureDevice = device
            
        } catch(let error) {
            
            delegate?.cameraScanner(self, didReceiveError: CameraScannerError.system(error))
            return
        }
    }
    
    private func setupSessionOutput() {
        if DeviceEnvironment.current == .simulator { return }
        
        let captureOutput = AVCaptureMetadataOutput()
        captureSession.addOutput(captureOutput)
        captureOutput.setMetadataObjectsDelegate(self, queue: metadataScannerQueue)
        captureOutput.metadataObjectTypes = self.codeTypes
        
        output = captureOutput
    }
    
    /// Remember to use in main thread
    private func configurePointOfInterests() {
        guard let device = self.captureDevice else { return }
        guard let videoPreviewLayer = self.videoPreviewLayer else { return }
        
        do {
            try device.lockForConfiguration()
            let point = CGPoint(x: roiBounds.midX, y: roiBounds.midY)
            let convPoint = videoPreviewLayer.captureDevicePointConverted(fromLayerPoint: point)
            
            device.exposurePointOfInterest = convPoint
            device.focusPointOfInterest = convPoint
            device.unlockForConfiguration()
        } catch {
            delegate?.cameraScanner(self, didReceiveError: .system(error))
        }
    }
    
    private func configureRectOfInterest() {
        let roi = videoPreviewLayer.metadataOutputRectConverted(fromLayerRect: roiBounds)
        output?.rectOfInterest = roi
    }
    
    // MARK: - Open functions to use framework
    open func startCapturing() {
        self.scannerQueue.async {
            self.videoPermission.checkPersmission { [weak self] error in
                guard let `self` = self else { return }
                
                guard error == nil else {
                    DispatchQueue.main.async {
                        self.delegate?.cameraScanner(self, didReceiveError: CameraScannerError.notAuthorizedToUseCamera)
                    }
                    return
                }
                
                self.captureSession.startRunning()
                
                DispatchQueue.main.async {
                    self.configurePointOfInterests()
                    self.configureRectOfInterest()
                }
            }
        }
    }
    
    open func stopCapturing() {
        scannerQueue.async {
            self.captureSession.stopRunning()
            DispatchQueue.main.async {
                self.delegate?.cameraScannerDidEndScanning(self)
            }
        }
    }
}
extension CameraScanner: AVCaptureMetadataOutputObjectsDelegate {
    open func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        for metaData in metadataObjects {
            let value = metaData.time.value as Int64
            let timescale = Int64(metaData.time.timescale)
            let time = value / timescale
            let transformed = videoPreviewLayer?.transformedMetadataObject(for: metaData) as? AVMetadataMachineReadableCodeObject
            if let unwraped = transformed,
                let scancode = unwraped.stringValue {
                self.delegate?.cameraScanner(self, didCaptureCode: scancode, time: time)
            }
        }
    }
}
