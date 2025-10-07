//
//  BoundingQuad.swift
//  LiveTextDemo
//
//  Created by Itsuki on 2025/10/08.
//

import SwiftUI
import Vision

nonisolated
struct BoundingQuad {
    var topLeft: NormalizedPoint
    var topRight: NormalizedPoint
    var bottomRight: NormalizedPoint
    var bottomLeft: NormalizedPoint
    
    static func fromObservation(_ observation: RectangleObservation) -> BoundingQuad {
        return BoundingQuad(
            topLeft: observation.topLeft,
            topRight: observation.topRight,
            bottomRight: observation.bottomRight,
            bottomLeft: observation.bottomLeft
        )
    }
    
}
