//
/*
 *	@file   BarcodeViewController.swift
 *	@target BoeingDistributionMobile
 */

import UIKit
import AVFoundation
class BarcodeViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var cameraScanner: CameraScanner!
    @IBOutlet weak var barCodeScanHintLineView: UIView!
    @IBOutlet weak var focusAreaImageView: UIImageView!
    @IBOutlet weak var viewPreview: UIView!
//    @IBOutlet weak var barcodeValueLabel: UILabel!
    @IBOutlet weak var flashLightButton: UIButton!
    
    // ** Storyboard properties for QR Code **
    // Properties related to swipe segment control
    @IBOutlet weak var textHeightConstraint : NSLayoutConstraint!
    @IBOutlet weak var actionButtonHeightConstraint : NSLayoutConstraint!
    @IBOutlet weak var btnAction          : UIButton!
    @IBOutlet weak var lblType            : UILabel!
    @IBOutlet weak var txtGeneratorText   : UITextField!
    @IBOutlet weak var segmentControl     : UISegmentedControl!
    
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialiseView()
        viewPreview.layer.cornerRadius = 5
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.flashLightButton.setImage(UIImage(named: ViewConstant.scanner.flashIconOn), for: .selected)
        self.flashLightButton.setImage(UIImage(named: ViewConstant.scanner.flashIconOff), for: .normal)
        self.flashLightButton.isSelected = false
        self.flashLightButton.backgroundColor = .lightGray

        UIApplication.shared.isIdleTimerDisabled = true
            self.viewPreview.frame = self.view.frame
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.dismissCameraScanView()
    }
    // MARK: Dismiss Camera View
    func dismissCameraScanView() {
            UIApplication.shared.isIdleTimerDisabled = false
            self.stopReading()
            self.dismiss(animated: false, completion: nil)
    }
    // MARK: Initial Set Up
    func initialiseView() {
        let types: [CodeType] = [
            CodeType.aztec,
            CodeType.code128,
            CodeType.code39,
            CodeType.code39Mod43,
            CodeType.code93,
            CodeType.dataMatrix,
            CodeType.ean13,
            CodeType.ean8,
            CodeType.interleaved2of5,
            CodeType.itf14,
            CodeType.pdf417,
            CodeType.qr,
            CodeType.upce]
        cameraScanner = CameraScanner(codeTypes: types)
        cameraScanner.delegate = self
        
        // QR Segment related default values
        // Text Constraint
        textHeightConstraint.constant = 0
        
        // Design button
        btnAction.layer.cornerRadius = btnAction.frame.size.height / 2
        btnAction.clipsToBounds = true
        
        // Default value
        if segmentControl.selectedSegmentIndex == 0 {
            lblType.text = "QR Code Scanner"
            actionButtonHeightConstraint.constant = 0
        }
        
        // Navigation bar image
        let img = #imageLiteral(resourceName: "icon-navigationTopBar")
        navigationController?.navigationBar.setBackgroundImage(img, for: .default)
    }
    @objc func stopReading() {
        UIApplication.shared.isIdleTimerDisabled = false
        self.cameraScanner.stopCapturing()
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func flashLightButtonAction(_ sender: Any) {
        self.toggleFlash()
    }
    func toggleFlash() {
        guard let device = AVCaptureDevice.default(for: AVMediaType.video) else { return }
        guard device.hasTorch else { return }
        
        do {
            try device.lockForConfiguration()
            
            if (device.torchMode == AVCaptureDevice.TorchMode.on) {
                device.torchMode = AVCaptureDevice.TorchMode.off
                self.flashLightButton.isSelected = false
                self.flashLightButton.backgroundColor = .lightGray
            } else {
                do {
                    try device.setTorchModeOn(level: 1.0)
                    self.flashLightButton.isSelected = true
                    self.flashLightButton.backgroundColor = .white
                    
                } catch {
                    print(error)
                }
            }
            
            device.unlockForConfiguration()
        } catch {
            print(error)
        }
    }
    
    // MARK: - Actions
    @IBAction func indexChanged(_ sender: Any) {
        switch segmentControl.selectedSegmentIndex {
        case 0:
            initialiseView()
            lblType.text = "QR Code Scanner"
            actionButtonHeightConstraint.constant = 0
            textHeightConstraint.constant = 0
            focusAreaImageView.image = #imageLiteral(resourceName: "scanLayout")
            focusAreaImageView.backgroundColor = .clear
            flashLightButton.isHidden = false
            viewPreview.isHidden = false
            barCodeScanHintLineView.isHidden = false
            break
        case 1:
            dismissCameraScanView()
            lblType.text = "QR Code Generator"
            btnAction.setTitle("Generate Now", for: .normal)
            actionButtonHeightConstraint.constant = 44
            textHeightConstraint.constant = 34
            focusAreaImageView.image = nil
            focusAreaImageView.backgroundColor = #colorLiteral(red: 0.6227783561, green: 0.5634429455, blue: 0.5223922133, alpha: 1)
            flashLightButton.isHidden = true
            viewPreview.isHidden = true
            barCodeScanHintLineView.isHidden = true
            break
        default:
            break
        }
        
        // Clear Existing values if any
        txtGeneratorText.text = ""
    }
    
    // Generate QR Code
    @IBAction func btnAction_Touch(_ sender: Any) {
        if segmentControl.selectedSegmentIndex == 1 {
            if let text = txtGeneratorText.text {
                focusAreaImageView.image = self.generateQRCode(from: text)
            }
        }
    }
}
extension BarcodeViewController: CameraScannerDelegate {
    func cameraScanner(_ scanner: CameraScanner, didCaptureCode code: String, type: CodeType) {
    }
    func cameraScanner(_ scanner: CameraScanner, didCaptureCode code: String, time: Int64) {
        DispatchQueue.main.async {
            print("Scanned QR Code: \(code)")
            // Navigate to external browser "Safari"
            if let url = URL(string: code) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    func cameraScanner(_ scanner: CameraScanner, didReceiveError error: CameraScannerError) {
       

    }
    func cameraScannerDidSetup(_ scanner: CameraScanner) {
       
        scanner.startCapturing()
    }
    func cameraScannerDidEndScanning(_ scanner: CameraScanner) {
    }
    var videoPreview: UIView {
        return self.viewPreview
    }
    var rectOfInterest: UIView {
        return self.focusAreaImageView
    }
    
}

// MARK: - QR Code Generator
extension BarcodeViewController {
    func generateQRCode(from text:String) -> UIImage? {
        // Clear imageview before generating code
        focusAreaImageView.image = nil
        
        // validate text
        let qrText = text
        
        // Convert as NSData
        let qrData = qrText.data(using: String.Encoding.ascii)
        
        // Initialize CI Filter of Core image framework
        // You can generate QR Code or Bar codes etc.
        guard let qrFilter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        
        // Apply Filter
        qrFilter.setValue(qrData, forKey: "inputMessage")
        
        // Output
        guard let qrCodeImage = qrFilter.outputImage else { return nil }
        
        // Transform Code for scalling image
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        
        // Apply
        let scallingQRImage = qrCodeImage.transformed(by: transform)
        
        
        // Finally convert into image
        let processedImage = UIImage(ciImage: scallingQRImage)
        
        // Return output
        return processedImage
    }
}

// MARK: - TextField Delegate
extension BarcodeViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
