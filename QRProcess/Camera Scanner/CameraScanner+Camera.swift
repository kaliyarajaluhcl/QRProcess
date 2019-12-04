/*
 *    @file   CameraScanner+Camera.swift
 *    @target BoeingDistributionMobile
 */

import Foundation
import AVFoundation

extension CameraScanner {

    class Camera {

        static func device(for position: CameraPosition) -> AVCaptureDevice? {
            switch position {
            case .front:
                return Camera.front
            case .back:
                return Camera.back
            default:
                return nil
            }
        }

        private static var front: AVCaptureDevice? {
            return AVCaptureDevice.default(AVCaptureDevice.DeviceType.builtInWideAngleCamera,
                                           for: AVMediaType.video,
                                           position: CameraPosition.front)
        }

        private static var back: AVCaptureDevice? {
            return AVCaptureDevice.default(for: .video)
        }
    }
}
