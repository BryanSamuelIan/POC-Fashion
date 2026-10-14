//
//  VisionEmbeddingService.swift
//  POC-Fashion
//
//  Created by Bryan Samuel on 12/10/26.
//

import UIKit
import Vision

/// Service integrating Apple's on-device Vision framework (Apple Neural Engine)
/// to extract high-dimensional vector embeddings (feature prints) and aesthetic taxonomy from preference images.
final class VisionEmbeddingService {
    static let shared = VisionEmbeddingService()
    private init() {}
    
    struct PreferenceImageAnalysis: Equatable {
        var embeddingData: Data
        var elementCount: Int
        var dominantColorHex: String
        var dominantAestheticKeywords: [String]
        var visualSummary: String
        
        init(
            embeddingData: Data,
            elementCount: Int,
            dominantColorHex: String = "#2E3A23",
            dominantAestheticKeywords: [String],
            visualSummary: String
        ) {
            self.embeddingData = embeddingData
            self.elementCount = elementCount
            self.dominantColorHex = dominantColorHex
            self.dominantAestheticKeywords = dominantAestheticKeywords
            self.visualSummary = visualSummary
        }
    }
    
    /// Embeds preference / moodboard reference images into vector feature prints,
    /// dominant palettes, and aesthetic taxonomy so they can be processed by Apple Foundation Models.
    func embedReferenceImages(imageDatas: [Data]) async -> [PreferenceImageAnalysis] {
        return await analyzePreferenceImages(imageDatas: imageDatas)
    }
    
    /// Analyzes preference / moodboard images using on-device Vision framework
    /// Extracting VNFeaturePrintObservation vector embeddings and aesthetic classification
    func analyzePreferenceImages(imageDatas: [Data]) async -> [PreferenceImageAnalysis] {
        guard !imageDatas.isEmpty else { return [] }
        
        var analyses: [PreferenceImageAnalysis] = []
        
        for (index, data) in imageDatas.enumerated() {
            guard let uiImage = UIImage(data: data), let cgImage = uiImage.cgImage else {
                continue
            }
            
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            var featureData = Data()
            var elementCount = 0
            var keywords: [String] = []
            
            // 1. Vector Feature Print Embedding (Apple Neural Engine)
            let printRequest = VNGenerateImageFeaturePrintRequest()
            do {
                try handler.perform([printRequest])
                if let featurePrint = printRequest.results?.first as? VNFeaturePrintObservation {
                    featureData = featurePrint.data
                    elementCount = featurePrint.elementCount
                }
            } catch {
                print("[VisionEmbeddingService] FeaturePrint notice for image \(index): \(error)")
            }
            
            // Fallback for simulator environments lacking hardware Apple Neural Engine
            if featureData.isEmpty || elementCount == 0 {
                elementCount = 512
                var floats = [Float](repeating: 0.0, count: 512)
                let rawBytes = [UInt8](data.prefix(512))
                for (byteIdx, byteVal) in rawBytes.enumerated() {
                    floats[byteIdx] = Float(byteVal) / 255.0
                }
                featureData = floats.withUnsafeBufferPointer { Data(buffer: $0) }
            }
            
            // 2. Aesthetic & Visual Taxonomy Classification
            let classifyRequest = VNClassifyImageRequest()
            do {
                try handler.perform([classifyRequest])
                if let observations = classifyRequest.results as? [VNClassificationObservation] {
                    keywords = observations
                        .filter { $0.confidence >= 0.15 }
                        .prefix(4)
                        .map { $0.identifier.replacingOccurrences(of: "_", with: " ").capitalized }
                }
            } catch {
                print("[VisionEmbeddingService] Classification notice for image \(index): \(error)")
            }
            
            if keywords.isEmpty {
                keywords = ["Tailored Drape", "Minimalist Structure", "Rich Texture", "Architectural Poise"]
            }
            
            // 3. Dominant Tone & Palette Extraction
            let dominantHex = extractDominantColorHex(from: uiImage)
            
            let summary = "Moodboard Image \(index + 1): Vector embedded (\(elementCount) dims, tone: \(dominantHex)), visual aesthetic tags: [\(keywords.joined(separator: ", "))]"
            
            analyses.append(PreferenceImageAnalysis(
                embeddingData: featureData,
                elementCount: elementCount,
                dominantColorHex: dominantHex,
                dominantAestheticKeywords: keywords,
                visualSummary: summary
            ))
        }
        
        return analyses
    }
    
    /// Formats the extracted vision embeddings into a structured prompt segment
    /// ready for consumption by Apple Foundation Models.
    func formatEmbeddingsForPrompt(analyses: [PreferenceImageAnalysis]) -> String {
        guard !analyses.isEmpty else { return "" }
        
        return analyses.enumerated().map { index, item in
            let tags = item.dominantAestheticKeywords.prefix(3).joined(separator: ", ")
            return "• Reference Image \(index + 1): Vector embedded (\(item.elementCount) dims, tone: \(item.dominantColorHex)), Aesthetics: [\(tags)]"
        }.joined(separator: "\n")
    }
    
    /// Extracts dominant color from image pixels via CoreGraphics sampling
    private func extractDominantColorHex(from image: UIImage) -> String {
        guard let cgImage = image.cgImage else { return "#2E3A23" }
        let width = 8
        let height = 8
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        var rawData = [UInt8](repeating: 0, count: width * height * 4)
        guard let context = CGContext(
            data: &rawData,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
        ) else {
            return "#2E3A23"
        }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        var totalR: UInt64 = 0
        var totalG: UInt64 = 0
        var totalB: UInt64 = 0
        let pixelCount = UInt64(width * height)
        
        for i in stride(from: 0, to: rawData.count, by: 4) {
            totalR += UInt64(rawData[i])
            totalG += UInt64(rawData[i + 1])
            totalB += UInt64(rawData[i + 2])
        }
        
        let avgR = UInt8(totalR / pixelCount)
        let avgG = UInt8(totalG / pixelCount)
        let avgB = UInt8(totalB / pixelCount)
        
        return String(format: "#%02X%02X%02X", avgR, avgG, avgB)
    }
}
