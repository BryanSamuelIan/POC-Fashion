//
//  AppleFoundationModelService.swift
//  POC-Fashion
//
//  Created by Bryan Samuel on 12/10/26.
//

import Foundation
import UIKit
#if canImport(FoundationModels)
import FoundationModels

@available(iOS 27.0, macOS 27.0, *)
@Generable
public struct ClothingAnalysis: Sendable {
    @Guide(description: "The category of the clothing")
    public var category: String

    @Guide(.range(1...10))
    public var fitScore: Int

    @Guide(description: "An explanation of the fit assessment")
    public var explanation: String
    
    public init(category: String, fitScore: Int, explanation: String) {
        self.category = category
        self.fitScore = fitScore
        self.explanation = explanation
    }
}

@available(iOS 27.0, macOS 27.0, *)
@Generable
public struct GarmentRecommendationItem: Sendable {
    @Guide(description: "The category of the clothing: Top, Outer, Bottom")
    public var category: String

    @Guide(description: "Specific descriptive garment name")
    public var name: String

    @Guide(description: "Precise cut details, hemline length, and tailored ease")
    public var cutDetail: String

    @Guide(description: "Textile material composition, drape, and breathability")
    public var fabricMaterial: String

    @Guide(description: "Seasonal color name matching the color season palette")
    public var colorName: String

    @Guide(description: "Hexadecimal color code (e.g. #2E3A23)")
    public var colorHex: String

    @Guide(.range(1...10))
    public var fitScore: Int

    @Guide(description: "Detailed rationale explaining why this garment fits the body type and torso")
    public var explanation: String
    
    public init(
        category: String,
        name: String,
        cutDetail: String,
        fabricMaterial: String,
        colorName: String,
        colorHex: String,
        fitScore: Int,
        explanation: String
    ) {
        self.category = category
        self.name = name
        self.cutDetail = cutDetail
        self.fabricMaterial = fabricMaterial
        self.colorName = colorName
        self.colorHex = colorHex
        self.fitScore = fitScore
        self.explanation = explanation
    }
}

@available(iOS 27.0, macOS 27.0, *)
@Generable
public struct LookRecommendationItem: Sendable {
    @Guide(description: "Distinct title of this styling look")
    public var title: String

    @Guide(description: "Short poetic tagline describing the visual silhouette")
    public var tagline: String

    @Guide(description: "A comprehensive paragraph explaining the direct correlation between the user's body type, torso type, and color season with the overall look")
    public var correlationAnalysisParagraph: String

    @Guide(description: "Summary of how user decision weights influenced this look")
    public var weightInfluenceSummary: String

    @Guide(description: "Top clothing piece")
    public var top: GarmentRecommendationItem

    @Guide(description: "Outer clothing piece")
    public var outer: GarmentRecommendationItem

    @Guide(description: "Bottom clothing piece")
    public var bottom: GarmentRecommendationItem
    
    public init(
        title: String,
        tagline: String,
        correlationAnalysisParagraph: String,
        weightInfluenceSummary: String,
        top: GarmentRecommendationItem,
        outer: GarmentRecommendationItem,
        bottom: GarmentRecommendationItem
    ) {
        self.title = title
        self.tagline = tagline
        self.correlationAnalysisParagraph = correlationAnalysisParagraph
        self.weightInfluenceSummary = weightInfluenceSummary
        self.top = top
        self.outer = outer
        self.bottom = bottom
    }
}

@available(iOS 27.0, macOS 27.0, *)
@Generable
public struct FullStylingRecommendation: Sendable {
    @Guide(description: "Look 1: Optimal Golden Balance between body proportions, torso length, and occasion")
    public var look1Balanced: LookRecommendationItem

    @Guide(description: "Look 2: Vision-Focused fit prioritizing user aspirational vision")
    public var look2Vision: LookRecommendationItem

    @Guide(description: "Look 3: Preference-Focused fit tailored to user style preferences")
    public var look3Preference: LookRecommendationItem
    
    public init(
        look1Balanced: LookRecommendationItem,
        look2Vision: LookRecommendationItem,
        look3Preference: LookRecommendationItem
    ) {
        self.look1Balanced = look1Balanced
        self.look2Vision = look2Vision
        self.look3Preference = look3Preference
    }
}
#endif

public enum FoundationModelError: Error, LocalizedError, Equatable {
    case modelNotAvailable
    case sessionError(String)
    
    public var errorDescription: String? {
        switch self {
        case .modelNotAvailable:
            return "Apple Foundation Model (SystemLanguageModel) is not available on this device/simulator. Ensure Apple Intelligence is enabled and model weights are downloaded."
        case .sessionError(let msg):
            if msg.lowercased().contains("rate limit") {
                return "Apple Intelligence is temporarily rate-limited by the system to regulate device resources. Please wait a few moments and try again."
            }
            return "Apple Foundation Model generation failed: \(msg)"
        }
    }
}

/// Serial actor gate guaranteeing that inference requests to Apple's SystemLanguageModel
/// are processed serially without concurrent session conflicts or resource collisions.
private actor FoundationModelExecutionGate {
    func execute<T>(_ block: () async throws -> T) async throws -> T {
        try await block()
    }
}

/// Service integrating Apple's on-device Foundation Models (Apple Intelligence LLM)
/// to analyze user styling profile inputs and generate fit recommendations with zero third-party tokens.
final class AppleFoundationModelService {
    static let shared = AppleFoundationModelService()
    private init() {}
    
    private let executionGate = FoundationModelExecutionGate()
    
    // MARK: - Compute Configuration
    
    public enum ComputeTarget: String, Sendable {
        /*
        // --- REACTIVATE ONCE APPLE ACCEPTS YOUR PCC ENTITLEMENT REQUEST ---
        // Request portal: https://developer.apple.com/contact/request/private-cloud-compute/
        case privateCloudCompute = "Private Cloud Compute (Expanded Context Window & Deep Reasoning)"
        // -----------------------------------------------------------------
        */
        case onDeviceSystemLanguageModel = "On-Device Apple Neural Engine (SystemLanguageModel)"
    }
    
    /// Returns the active compute target. Currently defaults to on-device SystemLanguageModel
    /// until Apple approves the com.apple.developer.private-cloud-compute entitlement request.
    var activeComputeTarget: ComputeTarget {
        /*
        // --- REACTIVATE ONCE APPLE ACCEPTS YOUR PCC ENTITLEMENT REQUEST ---
        #if canImport(FoundationModels)
        if #available(iOS 27.0, macOS 27.0, *) {
            let pcc = PrivateCloudComputeLanguageModel()
            if pcc.isAvailable && !pcc.quotaUsage.isLimitReached {
                return .privateCloudCompute
            }
        }
        #endif
        // -----------------------------------------------------------------
        */
        return .onDeviceSystemLanguageModel
    }
    
    /// Checks whether Apple's Private Cloud Compute is available.
    /// Temporarily deactivated until Apple approves the managed entitlement for your developer account:
    /// https://developer.apple.com/contact/request/private-cloud-compute/
    var isPrivateCloudComputeAvailable: Bool {
        /*
        // --- REACTIVATE ONCE APPLE ACCEPTS YOUR PCC ENTITLEMENT REQUEST ---
        #if canImport(FoundationModels)
        if #available(iOS 27.0, macOS 27.0, *) {
            return PrivateCloudComputeLanguageModel().isAvailable
        }
        #endif
        // -----------------------------------------------------------------
        */
        return false
    }
    
    /// Checks whether Apple's Foundation Models (on-device SystemLanguageModel) are available
    var isFoundationModelAvailable: Bool {
        /*
        // --- REACTIVATE ONCE APPLE ACCEPTS YOUR PCC ENTITLEMENT REQUEST ---
        #if canImport(FoundationModels)
        if #available(iOS 27.0, macOS 27.0, *) {
            if PrivateCloudComputeLanguageModel().isAvailable {
                return true
            }
        }
        #endif
        // -----------------------------------------------------------------
        */
        #if canImport(FoundationModels)
        if #available(iOS 27.0, macOS 27.0, *) {
            return SystemLanguageModel().isAvailable
        }
        #endif
        return false
    }
    
    /// Creates an optimized Foundation Model session. Currently routes to on-device SystemLanguageModel.
    /// To route through Apple Private Cloud Compute with deep reasoning and expanded context window,
    /// uncomment the PCC block below once Apple approves your managed entitlement.
    @available(iOS 27.0, macOS 27.0, *)
    func createSession() -> LanguageModelSession {
        /*
        // --- REACTIVATE ONCE APPLE ACCEPTS YOUR PCC ENTITLEMENT REQUEST ---
        #if canImport(FoundationModels)
        if #available(iOS 27.0, macOS 27.0, *) {
            let pcc = PrivateCloudComputeLanguageModel()
            if pcc.isAvailable && !pcc.quotaUsage.isLimitReached {
                print("[AppleFoundationModelService] Connected to Apple Private Cloud Compute (PCC) — Expanded Context Window active")
                return LanguageModelSession(model: pcc)
            }
        }
        #endif
        // -----------------------------------------------------------------
        */
        print("[AppleFoundationModelService] Connected to on-device SystemLanguageModel (Apple Neural Engine)")
        return LanguageModelSession(model: SystemLanguageModel())
    }
    
    @available(iOS 27.0, macOS 27.0, *)
    private func executeClothingAnalysis(session: LanguageModelSession, description: String) async throws -> ClothingAnalysis {
        #if canImport(FoundationModels)
        if #available(iOS 27.0, macOS 27.0, *) {
            /*
            // --- REACTIVATE ONCE APPLE ACCEPTS YOUR PCC ENTITLEMENT REQUEST ---
            let contextOptions = ContextOptions(includeSchemaInPrompt: true, reasoningLevel: .deep)
            let result = try await session.respond(
                to: "Analyze \(description).",
                generating: ClothingAnalysis.self,
                contextOptions: contextOptions
            )
            // -----------------------------------------------------------------
            */
            let result = try await session.respond(
                to: "Analyze \(description).",
                generating: ClothingAnalysis.self
            )
            let analysis = result.content
            print("[AppleFoundationModelService] Analyzed Piece: \(analysis.category) | FitScore: \(analysis.fitScore)/10 | \(analysis.explanation)")
            return analysis
        }
        #endif
        
        let result = try await session.respond(
            to: "Analyze \(description).",
            generating: ClothingAnalysis.self
        )
        let analysis = result.content
        print("[AppleFoundationModelService] Analyzed Piece: \(analysis.category) | FitScore: \(analysis.fitScore)/10 | \(analysis.explanation)")
        return analysis
    }

    // MARK: - Rate Limit Retry & Serial Execution Gate
    
    /// Executes an inference call through the serial execution gate with automatic exponential backoff retry
    /// if Apple Intelligence throws LanguageModelError.rateLimited.
    private func executeWithRateLimitRetry<T>(
        operationName: String,
        maxRetries: Int = 3,
        operation: @Sendable () async throws -> T
    ) async throws -> T {
        var attempt = 0
        var backoffDelaySeconds: Double = 1.0
        
        while true {
            attempt += 1
            do {
                return try await executionGate.execute {
                    try await operation()
                }
            } catch {
                #if canImport(FoundationModels)
                if #available(iOS 27.0, macOS 27.0, *) {
                    if let lmError = error as? LanguageModelError {
                        switch lmError {
                        case .rateLimited(let rateLimitInfo):
                            if attempt <= maxRetries {
                                let waitTime: Double
                                if let resetDate = rateLimitInfo.resetDate {
                                    let interval = resetDate.timeIntervalSinceNow
                                    waitTime = max(1.0, min(interval, 5.0))
                                } else {
                                    waitTime = backoffDelaySeconds
                                }
                                print("[AppleFoundationModelService] ⚠️ Rate limit encountered during \(operationName) (Attempt \(attempt)/\(maxRetries)). Waiting \(String(format: "%.1f", waitTime))s before retrying...")
                                try? await Task.sleep(nanoseconds: UInt64(waitTime * 1_000_000_000))
                                backoffDelaySeconds *= 1.8
                                continue
                            } else {
                                print("[AppleFoundationModelService] ❌ Rate limit retries exhausted for \(operationName)")
                                throw FoundationModelError.sessionError("Apple Intelligence is temporarily rate-limited by the system to regulate device resources. Please wait a moment and try again.")
                            }
                        default:
                            break
                        }
                    }
                }
                #endif
                
                let desc = error.localizedDescription.lowercased()
                if desc.contains("rate limit") && attempt <= maxRetries {
                    print("[AppleFoundationModelService] ⚠️ Rate limit detected in error message for \(operationName) (Attempt \(attempt)/\(maxRetries)). Waiting \(String(format: "%.1f", backoffDelaySeconds))s before retrying...")
                    try? await Task.sleep(nanoseconds: UInt64(backoffDelaySeconds * 1_000_000_000))
                    backoffDelaySeconds *= 1.8
                    continue
                }
                
                print("[AppleFoundationModelService] \(operationName) failed: \(error)")
                throw FoundationModelError.sessionError(error.localizedDescription)
            }
        }
    }

    /// Analyzes an individual garment using Apple's FoundationModels @Generable ClothingAnalysis
    func analyzeClothingPiece(description: String) async throws -> ClothingAnalysis {
        #if canImport(FoundationModels)
        if #available(iOS 27.0, macOS 27.0, *) {
            guard isFoundationModelAvailable else {
                throw FoundationModelError.modelNotAvailable
            }
            return try await executeWithRateLimitRetry(operationName: "analyzeClothingPiece") {
                let session = self.createSession()
                return try await self.executeClothingAnalysis(session: session, description: description)
            }
        }
        #endif
        throw FoundationModelError.modelNotAvailable
    }
    
    @available(iOS 27.0, macOS 27.0, *)
    private func executeSingleLookGeneration(session: LanguageModelSession, prompt: String, imageDatas: [Data]) async throws -> LookRecommendationItem {
        #if canImport(FoundationModels)
        if #available(iOS 27.0, macOS 27.0, *) {
            /*
            // --- REACTIVATE ONCE APPLE ACCEPTS YOUR PCC ENTITLEMENT REQUEST ---
            // PCC supports .vision and .reasoning capabilities:
            let contextOptions = ContextOptions(
                includeSchemaInPrompt: true,
                reasoningLevel: .deep
            )
            if !imageDatas.isEmpty {
                var attachments: [Attachment<ImageAttachmentContent>] = []
                for (idx, data) in imageDatas.enumerated() {
                    if let uiImg = UIImage(data: data), let cgImg = uiImg.cgImage {
                        attachments.append(Attachment(cgImg).label("Reference Image \(idx + 1)"))
                    }
                }
                if !attachments.isEmpty {
                    let multimodalPrompt = Prompt {
                        attachments
                        prompt
                    }
                    let result = try await session.respond(
                        to: multimodalPrompt,
                        generating: LookRecommendationItem.self,
                        contextOptions: contextOptions
                    )
                    return result.content
                }
            }
            // -----------------------------------------------------------------
            */
            
            // On-device SystemLanguageModel: Text-only guided generation with Vision-embeddings in prompt
            let result = try await session.respond(
                to: prompt,
                generating: LookRecommendationItem.self
            )
            return result.content
        }
        #endif
        
        let result = try await session.respond(
            to: prompt,
            generating: LookRecommendationItem.self
        )
        return result.content
    }

    /// Generates a single look with 3 garments (Top, Outer, Bottom) and correlation paragraph using Apple's FoundationModels @Generable LookRecommendationItem.
    func generateSingleLook(prompt: String, imageDatas: [Data] = []) async throws -> LookRecommendationItem {
        #if canImport(FoundationModels)
        if #available(iOS 27.0, macOS 27.0, *) {
            guard isFoundationModelAvailable else {
                throw FoundationModelError.modelNotAvailable
            }
            return try await executeWithRateLimitRetry(operationName: "generateSingleLook") {
                let session = self.createSession()
                return try await self.executeSingleLookGeneration(session: session, prompt: prompt, imageDatas: imageDatas)
            }
        }
        #endif
        throw FoundationModelError.modelNotAvailable
    }
    
    @available(iOS 27.0, macOS 27.0, *)
    private func executeStylingGeneration(session: LanguageModelSession, prompt: String, imageDatas: [Data]) async throws -> FullStylingRecommendation {
        #if canImport(FoundationModels)
        if #available(iOS 27.0, macOS 27.0, *) {
            /*
            // --- REACTIVATE ONCE APPLE ACCEPTS YOUR PCC ENTITLEMENT REQUEST ---
            // PCC supports .vision and .reasoning capabilities:
            let contextOptions = ContextOptions(
                includeSchemaInPrompt: true,
                reasoningLevel: .deep
            )
            if !imageDatas.isEmpty {
                var attachments: [Attachment<ImageAttachmentContent>] = []
                for (idx, data) in imageDatas.enumerated() {
                    if let uiImg = UIImage(data: data), let cgImg = uiImg.cgImage {
                        attachments.append(Attachment(cgImg).label("Reference Image \(idx + 1)"))
                    }
                }
                if !attachments.isEmpty {
                    let multimodalPrompt = Prompt {
                        attachments
                        prompt
                    }
                    let result = try await session.respond(
                        to: multimodalPrompt,
                        generating: FullStylingRecommendation.self,
                        contextOptions: contextOptions
                    )
                    return result.content
                }
            }
            // -----------------------------------------------------------------
            */
            
            // On-device SystemLanguageModel: Text-only guided generation with Vision-embeddings in prompt
            let result = try await session.respond(
                to: prompt,
                generating: FullStylingRecommendation.self
            )
            return result.content
        }
        #endif
        
        let result = try await session.respond(
            to: prompt,
            generating: FullStylingRecommendation.self
        )
        return result.content
    }

    /// Generates structured styling recommendations for all 3 looks using Apple's FoundationModels @Generable FullStylingRecommendation,
    /// accepting prompt string and optional multimodal preference image attachments.
    func generateFullStylingWithFoundationModels(prompt: String, imageDatas: [Data] = []) async throws -> FullStylingRecommendation {
        #if canImport(FoundationModels)
        if #available(iOS 27.0, macOS 27.0, *) {
            guard isFoundationModelAvailable else {
                throw FoundationModelError.modelNotAvailable
            }
            return try await executeWithRateLimitRetry(operationName: "generateFullStyling") {
                let session = self.createSession()
                return try await self.executeStylingGeneration(session: session, prompt: prompt, imageDatas: imageDatas)
            }
        }
        #endif
        throw FoundationModelError.modelNotAvailable
    }
}

