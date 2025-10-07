//
//  VisionService.swift
//  LiveTextDemo
//
//  Created by Itsuki on 2025/10/08.
//


import Vision
import SwiftUI

nonisolated
class VisionService {
    
    // https://developer.apple.com/documentation/vision/detectbarcodesrequest
    // A request that detects barcodes in an image.
    private var barcodesRequest: DetectBarcodesRequest = DetectBarcodesRequest()
    
    // https://developer.apple.com/documentation/vision/recognizetextrequest
    private var textRequest: RecognizeTextRequest = RecognizeTextRequest()

    // a flag to avoid processing multiple requests at once
    private var isProcessingBarcode: Bool = false
    private var isProcessingText: Bool = false


    init() {
        // configure barcode request
        self.barcodesRequest.symbologies = self.barcodesRequest.supportedSymbologies

        // configure text request
        textRequest.recognitionLanguages = Locale.Language.systemLanguages
        textRequest.automaticallyDetectsLanguage = true
        textRequest.usesLanguageCorrection = true
        textRequest.recognitionLevel = .accurate
        
    }
    
    
    // MARK:
    // NOTE: Barcode request required real device
    // when running on simulator: we will receive the following error
    // internalError("Vision.VisionError.operationFailed(\"Failed to create barcode detector.\")")
    func detectBarcode(_ ciImage: CIImage) async throws -> [ObservationResult] {
        guard !self.isProcessingBarcode else { return [] }
        self.isProcessingBarcode = true
        
        defer {
            self.isProcessingBarcode = false
        }
        
        let results: [BarcodeObservation] = try await self.barcodesRequest.perform(on: ciImage, orientation: .up)
        return ObservationResult.fromBarcodeObservations(results)
    }
    
    // // NOTE: RecognizedTextObservation can perform on simulators
    func detectText(_ ciImage: CIImage) async throws -> [ObservationResult] {
        guard !self.isProcessingText else { return [] }
        self.isProcessingText = true
        
        defer {
            self.isProcessingText = false
        }
        
        let results: [RecognizedTextObservation] = try await self.textRequest.perform(on: ciImage, orientation: .up)
        return ObservationResult.fromTextObservations(results)

    }
}
