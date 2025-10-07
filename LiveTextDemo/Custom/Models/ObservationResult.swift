//
//  ObservationResult.swift
//  LiveTextDemo
//
//  Created by Itsuki on 2025/10/08.
//


import Vision
import SwiftUI

nonisolated
struct ObservationResult {
    var string: String
    var boundingQuad: BoundingQuad
    var extractedData: [NSTextCheckingResult] = []
    
    static func fromBarcodeObservations(_ barcodeObservations: [BarcodeObservation]) -> [ObservationResult] {
        var results: [(String?, BoundingQuad)] = barcodeObservations.compactMap { observation in
            (observation.payloadString, BoundingQuad.fromObservation(observation.boundingRegion.boundingQuad))
        }
        
        results = results.filter({$0.0 != nil && $0.0?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false})
        
        return results.map({ObservationResult(string: $0.0!, boundingQuad: $0.1)})

    }
    
    static func fromTextObservations(_ textObservations: [RecognizedTextObservation]) -> [ObservationResult] {
        var results: [(String, BoundingQuad)] = textObservations.compactMap { observation in
            (observation.transcript, BoundingQuad.fromObservation(observation.boundingRegion.boundingQuad))
        }
        
        results = results.filter({$0.0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false})
        
        return results.map({ObservationResult(string: $0.0, boundingQuad: $0.1)})

    }
}

