/*
 *    @file   CameraScannerDelegate.swift
 *    @target BoeingDistributionMobile
 */

import UIKit


public protocol CameraScannerDelegate: class {

    var videoPreview: UIView { get }
    /// rect of focus while scanning. Metadata outside of this rect will be skipped
    var rectOfInterest: UIView { get }
    func cameraScanner(_ scanner: CameraScanner, didCaptureCode code: String, time: Int64)

    func cameraScanner(_ scanner: CameraScanner, didCaptureCode code: String, type: CodeType)
    func cameraScanner(_ scanner: CameraScanner, didReceiveError error: CameraScannerError)
    func cameraScannerDidSetup(_ scanner: CameraScanner)
    func cameraScannerDidEndScanning(_ scanner: CameraScanner)
}
