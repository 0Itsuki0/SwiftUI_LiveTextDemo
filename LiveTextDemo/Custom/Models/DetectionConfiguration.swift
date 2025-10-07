//
//  DetectionConfiguration.swift
//  LiveTextDemo
//
//  Created by Itsuki on 2025/10/08.
//

import Foundation

struct DetectionConfiguration: OptionSet, Hashable {
    let rawValue: UInt

    static let barcode = DetectionConfiguration(rawValue: 1 << 0) // 1
    static let text = DetectionConfiguration(rawValue: 1 << 1) // 2

    static let all: DetectionConfiguration = [.barcode, .text]
}
