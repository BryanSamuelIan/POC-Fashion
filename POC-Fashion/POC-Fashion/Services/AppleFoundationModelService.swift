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

@available(iOS 26.0, macOS 26.0, *)
@Generable
public struct ClothingAnalysis {
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

@available(iOS 26.0, macOS 26.0, *)
@Generable
public struct GarmentRecommendationItem {
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

@available(iOS 26.0, macOS 26.0, *)
@Generable
public struct LookRecommendationItem {
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

@available(iOS 26.0, macOS 26.0, *)
@Generable
public struct FullStylingRecommendation {
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
            return "Apple Foundation Model generation failed: \(msg)"
        }
    }
}

/// Service integrating Apple's on-device Foundation Models (Apple Intelligence LLM)
/// to analyze user styling profile inputs and generate fit recommendations with zero third-party tokens.
final class AppleFoundationModelService {
    static let shared = AppleFoundationModelService()
    private init() {}
    
    public enum ComputeTarget: String, Sendable {
        case privateCloudCompute = "Private Cloud Compute (Expanded Context Window & Deep Reasoning)"
        case onDeviceSystemLanguageModel = "On-Device Apple Neural Engine (SystemLanguageModel)"
    }
    
    /// Returns the active compute target: Apple's Private Cloud Compute if available and within quota, or on-device SystemLanguageModel.
    var activeComputeTarget: ComputeTarget {
        #if canImport(FoundationModels)
        if #available(iOS 27.0, macOS 27.0, *) {
            let pcc = PrivateCloudComputeLanguageModel()
            if pcc.isAvailable && !pcc.quotaUsage.isLimitReached {
                return .privateCloudCompute
            }
        }
        #endif
        return .onDeviceSystemLanguageModel
    }
    
    /// Checks whether Apple's Private Cloud Compute is available on this device/environment
    var isPrivateCloudComputeAvailable: Bool {
        #if canImport(FoundationModels)
        if #available(iOS 27.0, macOS 27.0, *) {
            return PrivateCloudComputeLanguageModel().isAvailable
        }
        #endif
        return false
    }
    
    /// Checks whether Apple's Foundation Models (Private Cloud Compute or on-device SystemLanguageModel) are available
    var isFoundationModelAvailable: Bool {
        #if canImport(FoundationModels)
        if #available(iOS 27.0, macOS 27.0, *) {
            if PrivateCloudComputeLanguageModel().isAvailable {
                return true
            }
        }
        if #available(iOS 26.0, *) {
            return SystemLanguageModel().isAvailable
        }
        #endif
        return false
    }
    
    /// Creates an optimized Foundation Model session connecting to Apple's Private Cloud Compute
    /// whenever available for larger context window capacity and deeper reasoning, falling back to on-device.
    @available(iOS 26.0, macOS 26.0, *)
    func createSession() -> LanguageModelSession {
        #if canImport(FoundationModels)
        if #available(iOS 27.0, macOS 27.0, *) {
            let pcc = PrivateCloudComputeLanguageModel()
            if pcc.isAvailable && !pcc.quotaUsage.isLimitReached {
                print("[AppleFoundationModelService] Connected to Apple Private Cloud Compute (PCC) — Expanded Context Window active")
                return LanguageModelSession(model: pcc)
            }
        }
        #endif
        print("[AppleFoundationModelService] Connected to on-device SystemLanguageModel")
        return LanguageModelSession()
    }
    
    /// Analyzes an individual garment using Apple's FoundationModels @Generable ClothingAnalysis
    func analyzeClothingPiece(description: String) async throws -> ClothingAnalysis {
        #if canImport(FoundationModels)
        if #available(iOS 26.0, macOS 26.0, *) {
            guard isFoundationModelAvailable else {
                throw FoundationModelError.modelNotAvailable
            }
            do {
                let session = createSession()
                #if canImport(FoundationModels)
                if #available(iOS 27.0, macOS 27.0, *) {
                    let contextOptions = ContextOptions(includeSchemaInPrompt: true, reasoningLevel: .deep)
                    let result = try await session.respond(
                        to: "Analyze \(description).",
                        generating: ClothingAnalysis.self,
                        contextOptions: contextOptions
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
            } catch {
                print("[AppleFoundationModelService] analyzeClothingPiece failed: \(error)")
                throw FoundationModelError.sessionError(error.localizedDescription)
            }
        }
        #endif
        throw FoundationModelError.modelNotAvailable
    }
    
    /// Generates a single look with 3 garments (Top, Outer, Bottom) and correlation paragraph using Apple's FoundationModels @Generable LookRecommendationItem.
    /// Connects to Private Cloud Compute for expanded context capacity and deep reasoning when available.
    func generateSingleLook(prompt: String, imageDatas: [Data] = []) async throws -> LookRecommendationItem {
        #if canImport(FoundationModels)
        if #available(iOS 26.0, macOS 26.0, *) {
            guard isFoundationModelAvailable else {
                throw FoundationModelError.modelNotAvailable
            }
            
            do {
                let session = createSession()
                
                #if canImport(FoundationModels)
                if #available(iOS 27.0, macOS 27.0, *) {
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
                            do {
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
                            } catch {
                                print("[AppleFoundationModelService] Multimodal session notice: \(error). Falling back to vision-embedded prompt.")
                            }
                        }
                    }
                    
                    let result = try await session.respond(
                        to: prompt,
                        generating: LookRecommendationItem.self,
                        contextOptions: contextOptions
                    )
                    return result.content
                }
                #endif
                
                let result = try await session.respond(
                    to: prompt,
                    generating: LookRecommendationItem.self
                )
                return result.content
            } catch {
                print("[AppleFoundationModelService] generateSingleLook failed: \(error)")
                throw FoundationModelError.sessionError(error.localizedDescription)
            }
        }
        #endif
        throw FoundationModelError.modelNotAvailable
    }
    
    /// Generates structured styling recommendations for all 3 looks using Apple's FoundationModels @Generable FullStylingRecommendation,
    /// accepting prompt string and optional multimodal preference image attachments with expanded Private Cloud Compute context.
    func generateFullStylingWithFoundationModels(prompt: String, imageDatas: [Data] = []) async throws -> FullStylingRecommendation {
        #if canImport(FoundationModels)
        if #available(iOS 26.0, macOS 26.0, *) {
            guard isFoundationModelAvailable else {
                throw FoundationModelError.modelNotAvailable
            }
            
            do {
                let session = createSession()
                
                #if canImport(FoundationModels)
                if #available(iOS 27.0, macOS 27.0, *) {
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
                            do {
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
                            } catch {
                                print("[AppleFoundationModelService] Multimodal session notice: \(error). Falling back to vision-embedded prompt.")
                            }
                        }
                    }
                    
                    let result = try await session.respond(
                        to: prompt,
                        generating: FullStylingRecommendation.self,
                        contextOptions: contextOptions
                    )
                    return result.content
                }
                #endif
                
                let result = try await session.respond(
                    to: prompt,
                    generating: FullStylingRecommendation.self
                )
                return result.content
            } catch {
                print("[AppleFoundationModelService] generateFullStyling failed: \(error)")
                throw FoundationModelError.sessionError(error.localizedDescription)
            }
        }
        #endif
        throw FoundationModelError.modelNotAvailable
    }
}

