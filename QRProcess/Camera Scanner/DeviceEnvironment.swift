/*
 *    @file   DeviceEnvironment.swift
 *    @target BoeingDistributionMobile
 */

import Foundation

enum DeviceEnvironment {

    case simulator
    case device

    static var current: DeviceEnvironment {

        #if targetEnvironment(simulator)
            return .simulator
        #else
            return .device
        #endif
    }
}
