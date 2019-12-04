/*
 *    @file   VideoPermission.swift
 *    @target BoeingDistributionMobile
 */

import Foundation
import AVFoundation

final class VideoPermission {

    // MARK: - Authorization

    /// Checks authorization status of the capture device.
    func checkPersmission(completion: @escaping (Error?) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            completion(nil)
        case .notDetermined:
            askForPermissions(completion)
        default:
            completion(CameraScannerError.notAuthorizedToUseCamera)
        }
    }

    /// Asks for permission to use video.
    private func askForPermissions(_ completion: @escaping (Error?) -> Void) {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                guard granted else {
                    completion(CameraScannerError.notAuthorizedToUseCamera)
                    return
                }
                completion(nil)
            }
        }
    }
}
