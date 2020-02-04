//
//  ViewController.swift
//  QRProcess
//
//  Created by Kaliyarajalu G on 03/12/19.
//  Copyright © 2019 Kaliyarajalu G. All rights reserved.
//

import UIKit
import CoreImage

class ViewController: UIViewController {

    // Storyboard properties
    @IBOutlet weak var textHeightConstraint : NSLayoutConstraint!
    @IBOutlet weak var segmentControl     : UISegmentedControl!
    @IBOutlet weak var lblType            : UILabel!
    @IBOutlet weak var txtGeneratorText   : UITextField!
    @IBOutlet weak var imgQRCode          : UIImageView!
    @IBOutlet weak var btnAction          : UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Initialize view
        self.initializeSetup()
    }
    
    // MARK: - Initial Setup
    func initializeSetup() {
        // Text Constraint
        textHeightConstraint.constant = 0
        
        // Design button
        btnAction.layer.cornerRadius = btnAction.frame.size.height / 2
        btnAction.clipsToBounds = true
        
        // Default value
        imgQRCode.image = nil
        if segmentControl.selectedSegmentIndex == 0 {
            lblType.text = "QR Code Scanner"
            btnAction.setTitle("Scan Now", for: .normal)
        }
        
        print("Test realtime installations")
    }
    
    // MARK: - Actions
    @IBAction func indexChanged(_ sender: Any) {
        switch segmentControl.selectedSegmentIndex {
        case 0:
            lblType.text = "QR Code Scanner"
            btnAction.setTitle("Scan Now", for: .normal)
            textHeightConstraint.constant = 0
            break
        case 1:
            lblType.text = "QR Code Generator"
            btnAction.setTitle("Generate Now", for: .normal)
            textHeightConstraint.constant = 34
            break
        default:
            break
        }
        
        // Clear Existing values if any
        imgQRCode.image = nil
        txtGeneratorText.text = ""
    }
    
    @IBAction func btnAction_Touch(_ sender: Any) {
        if segmentControl.selectedSegmentIndex == 0 {
            
        } else {
            if let text = txtGeneratorText.text {
                imgQRCode.image = self.generateQRCode(from: text)
            }
        }
    }
}

// MARK: - TextField Delegate
extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - QR Code Generator
extension ViewController {
    func generateQRCode(from text:String) -> UIImage? {
        // Clear imageview before generating code
        imgQRCode.image = nil
        
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
