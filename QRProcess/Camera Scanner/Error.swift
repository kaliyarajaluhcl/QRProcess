/*
 *    @file   Error.swift
 *    @target BoeingDistributionMobile
 */

import Foundation

public enum CameraScannerError: Swift.Error {
    case notAuthorizedToUseCamera
    case cameraInvalid
    case cameraNotFound
    case invalidCodeScanned
    case system(_: Swift.Error)
    case other
}
