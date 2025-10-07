//
//  LiveTextManager.swift
//  LiveTextDemo
//
//  Created by Itsuki on 2025/10/08.
//

import SwiftUI

@Observable
class LiveTextManager {
    enum ProcessingError: Error {
        case failToGetCIImage
        case failToGetPixelBuffer
    }
    
    var error: Error? {
        didSet {
            if let error {
                print(error)
            }
        }
    }
    
    var detectionConfiguration: DetectionConfiguration = .text
    
    private let visionService = VisionService()
    
    nonisolated
    private let detector: NSDataDetector?
    
    private(set) var observationResults: [ObservationResult] = [] {
        didSet {
            if !observationResults.isEmpty {
                print(observationResults)
            }
        }
    }

    init() {
        do {
            self.detector = try NSDataDetector(types: NSTextCheckingAllTypes)
        } catch(let error) {
            self.detector = nil
            self.error = error
        }
    }
    
    
    func analyze(_ data: Data) async throws {
        guard let image = CIImage(data: data) else {
            throw ProcessingError.failToGetCIImage
        }
        try await self.analyze(image)
    }
    
    func analyze(_ image: UIImage) async throws {
        guard let ciImage = image.ciImage else {
            throw ProcessingError.failToGetCIImage
        }
        try await self.analyze(ciImage)
    }
        
    func analyze(_ pixelBuffer: CVPixelBuffer) async throws {
        try await self.analyze(CIImage(cvPixelBuffer: pixelBuffer))
    }
    
    func analyze(_ ciImage: CIImage) async throws {
        self.observationResults = []
        
        var results = try await withThrowingTaskGroup(of: ([ObservationResult]).self) { group in
            var results: [ObservationResult] = []
            
            if self.detectionConfiguration.contains(.barcode) {
                group.addTask {
                    return try await self.visionService.detectBarcode(ciImage)
                }
            }
            
            if self.detectionConfiguration.contains(.text) {
                group.addTask {
                    return try await self.visionService.detectText(ciImage)
                }
            }
        
            for try await result in group {
                results.append(contentsOf: result)
            }
            
            return results
        }
        
        
        results = try await withThrowingTaskGroup(of: (ObservationResult).self) { group in
            var final: [ObservationResult] = []
            
            for var result in results {
                group.addTask {
                    let text = result.string
                    let matches = self.detector?.matches(in: text, options: [], range: NSRange(location: 0, length: text.count))
                    result.extractedData = matches ?? []
                    return result
                }

            }
        
            for try await result in group {
                final.append(result)
            }
            
            return final
        }
        
        self.observationResults = results

    }

}
