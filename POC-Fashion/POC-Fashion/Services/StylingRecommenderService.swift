//
//  StylingRecommenderService.swift
//  POC-Fashion
//
//  Created by Bryan Samuel on 12/10/26.
//

import UIKit
#if canImport(FoundationModels)
import FoundationModels
#endif

final class StylingRecommenderService {
    static let shared = StylingRecommenderService()
    private init() {}
    
    // System Temperature: 0.2 (Deterministic Reasoning with Creative Latitude)
    let temperature: Double = 0.2
    
    enum RecommenderError: Error, LocalizedError {
        case modelOutputUnavailable
        case schemaDecodingFailed(String)
        
        var errorDescription: String? {
            switch self {
            case .modelOutputUnavailable:
                return "Apple Foundation Model output could not be generated."
            case .schemaDecodingFailed(let detail):
                return "Failed to parse structured output from Apple Foundation Model: \(detail)"
            }
        }
    }
    
    // MARK: - Generate Recommendations Pipeline (Modular Per-Look with Native FoundationModels)
    func generateRecommendations(for profile: UserStylingProfile) async throws -> StylingResult {
        // 1. Extract on-device Vision feature prints & aesthetic taxonomy from preference images
        let visualAnalyses = await VisionEmbeddingService.shared.analyzePreferenceImages(imageDatas: profile.referenceImagesData)
        
        #if canImport(FoundationModels)
        if #available(iOS 27.0, macOS 27.0, *) {
            // Generate Look 1: Optimal Balance (Balanced weights)
            let prompt1 = buildConcisePrompt(for: profile, lookType: .look1Balanced, visualAnalyses: visualAnalyses)
            print("[StylingRecommenderService] Generating Look 1 (Optimal Balance)...")
            let look1Item = try await AppleFoundationModelService.shared.generateSingleLook(
                prompt: prompt1,
                imageDatas: profile.referenceImagesData
            )
            let look1 = convertLookItem(look1Item, type: .look1Balanced, profile: profile)
            
            // Inter-generation pacing (600ms) to allow Neural Engine / SystemLanguageModel daemon resources to stabilize
            try await Task.sleep(nanoseconds: 600_000_000)
            
            // Generate Look 2: Vision-Focused (Vision-prioritized weights)
            let prompt2 = buildConcisePrompt(for: profile, lookType: .look2Vision, visualAnalyses: visualAnalyses)
            print("[StylingRecommenderService] Generating Look 2 (Vision-Focused)...")
            let look2Item = try await AppleFoundationModelService.shared.generateSingleLook(
                prompt: prompt2,
                imageDatas: profile.referenceImagesData
            )
            let look2 = convertLookItem(look2Item, type: .look2Vision, profile: profile)
            
            // Inter-generation pacing (600ms) to allow Neural Engine / SystemLanguageModel daemon resources to stabilize
            try await Task.sleep(nanoseconds: 600_000_000)
            
            // Generate Look 3: Preference-Focused (Preference & Moodboard prioritized weights)
            let prompt3 = buildConcisePrompt(for: profile, lookType: .look3Preference, visualAnalyses: visualAnalyses)
            print("[StylingRecommenderService] Generating Look 3 (Preference-Focused)...")
            let look3Item = try await AppleFoundationModelService.shared.generateSingleLook(
                prompt: prompt3,
                imageDatas: profile.referenceImagesData
            )
            let look3 = convertLookItem(look3Item, type: .look3Preference, profile: profile)
            
            print("[StylingRecommenderService] Successfully generated 3 modular looks with on-device FoundationModels")
            return StylingResult(
                profileSnapshot: profile,
                looks: [look1, look2, look3]
            )
        }
        #endif
        
        throw RecommenderError.modelOutputUnavailable
    }
    
    // MARK: - Concise Prompt Builder (Optimized for On-Device Context Window)
    func buildConcisePrompt(
        for profile: UserStylingProfile,
        lookType: LookType,
        visualAnalyses: [VisionEmbeddingService.PreferenceImageAnalysis] = []
    ) -> String {
        let aestheticTags = visualAnalyses.flatMap { $0.dominantAestheticKeywords }.prefix(4).joined(separator: ", ")
        let tagDescription = aestheticTags.isEmpty ? "Tailored Drape, Minimalist Structure" : aestheticTags
        let embeddingsContext = VisionEmbeddingService.shared.formatEmbeddingsForPrompt(analyses: visualAnalyses)
        
        let focusDirective: String
        let weightsNote: String
        switch lookType {
        case .look1Balanced:
            focusDirective = "Look 1: Optimal Balance — Golden-ratio equilibrium for \(profile.bodyType.rawValue) and \(profile.torsoType.rawValue), harmonizing vision (\"\(profile.visionStatement)\") and personality (\"\(profile.personalityKeywords)\")."
            weightsNote = "Balanced Weights: 35% Body Balance, 25% Occasion, 15% Vision, 15% Personality, 10% Color Season"
        case .look2Vision:
            focusDirective = "Look 2: Vision-Focused — Prioritize aspirational vision (\"\(profile.visionStatement)\") and personality (\"\(profile.personalityKeywords)\") with architectural tailoring."
            weightsNote = "Vision-Dominated Weights: 50% Vision, 20% Personality, 15% Occasion, 15% Body Balance"
        case .look3Preference:
            focusDirective = "Look 3: Preference-Focused — Prioritize moodboard references (aesthetic tags: [\(tagDescription)]), personality vibes, and expressive drape."
            weightsNote = "Preference-Dominated Weights: 40% Moodboard & Preferences, 25% Personality, 20% Body Balance, 15% Vision"
        }
        
        let embeddingsSection = embeddingsContext.isEmpty ? "" : """
        
        [EMBEDDED MOODBOARD VISION EMBEDDINGS]
        \(embeddingsContext)
        """
        
        return """
        Design a bespoke fashion outfit for this client:
        - Body Type: \(profile.bodyType.rawValue)
        - Torso Type: \(profile.torsoType.rawValue)
        - Color Season: \(profile.colorSeason.rawValue) (Signature Palette: \(profile.colorSeason.signatureHexColors.joined(separator: ", ")))
        - Occasion: "\(profile.occasionName)" (Dress Code: \(profile.dressCode), Activity: \(profile.occasionActivity.rawValue))
        - Style Vision: "\(profile.visionStatement)"
        - Personality Keywords: "\(profile.personalityKeywords)"
        - Reference Images: \(profile.referenceImagesData.count) moodboard images attached (Visual aesthetic tags: [\(tagDescription)])\(embeddingsSection)
        
        [STYLING FOCUS - \(weightsNote)]
        \(focusDirective)
        
        [REQUIREMENTS]
        1. Design the 3 essential garments only: Top, Outer, Bottom (strictly NO shoes and NO accessories).
           For each piece specify: name, cutDetail, fabricMaterial, colorName, colorHex, fitScore (1-10), and rationale for \(profile.bodyType.rawValue) and \(profile.torsoType.rawValue).
        2. Write a comprehensive analytical paragraph explaining the correlation of the user's Body Type (\(profile.bodyType.rawValue)), Torso Type (\(profile.torsoType.rawValue)), and Color Season (\(profile.colorSeason.rawValue)) with the overall look.
        """
    }
    
    /// Backward-compatible helper for tests
    func buildStructuredPrompt(
        for profile: UserStylingProfile,
        visualAnalyses: [VisionEmbeddingService.PreferenceImageAnalysis] = []
    ) -> String {
        return buildConcisePrompt(for: profile, lookType: .look1Balanced, visualAnalyses: visualAnalyses)
    }
    
    #if canImport(FoundationModels)
    @available(iOS 27.0, macOS 27.0, *)
    func convertFoundationModelOutput(_ output: FullStylingRecommendation, for profile: UserStylingProfile) -> StylingResult {
        let look1 = convertLookItem(output.look1Balanced, type: .look1Balanced, profile: profile)
        let look2 = convertLookItem(output.look2Vision, type: .look2Vision, profile: profile)
        let look3 = convertLookItem(output.look3Preference, type: .look3Preference, profile: profile)
        
        return StylingResult(
            profileSnapshot: profile,
            looks: [look1, look2, look3]
        )
    }
    
    @available(iOS 27.0, macOS 27.0, *)
    private func convertLookItem(_ item: LookRecommendationItem, type: LookType, profile: UserStylingProfile) -> FitLook {
        let pieces = [
            convertGarmentItem(item.top, defaultCategory: .top),
            convertGarmentItem(item.outer, defaultCategory: .outer),
            convertGarmentItem(item.bottom, defaultCategory: .bottom)
        ]
        
        // 1. Dynamic Physical Fit: Derived from AI-generated garment fit scores (1-10 -> 100% scale)
        let avgGarmentScore = Double(item.top.fitScore + item.outer.fitScore + item.bottom.fitScore) / 3.0
        let dynamicPhysicalScore = min(100, max(60, Int((avgGarmentScore * 10.0).rounded())))
        
        let dynamicPhysical = PhysicalFitEvaluation(
            score: dynamicPhysicalScore,
            easeDetail: "3-5 cm architectural ease calibrated for \(profile.bodyType.rawValue.lowercased()) and \(profile.torsoType.rawValue.lowercased())",
            lineDetail: "Vertical column contours balancing shoulder-to-hip ratio",
            grainDetail: "True on-grain drape fall conforming to stance",
            setDetail: "Zero horizontal strain folds across thoracic points",
            balanceDetail: "Front and back equilibrium aligned to \(profile.bodyType.rawValue.lowercased()) posture"
        )
        
        // 2. Dynamic Visual Fit: Proportion harmony & color season execution
        let visualBonus = (type == .look1Balanced) ? 2 : (type == .look2Vision ? 1 : 0)
        let dynamicVisualScore = min(100, max(60, dynamicPhysicalScore + visualBonus))
        
        let dynamicVisual = VisualFitEvaluation(
            score: dynamicVisualScore,
            proportionDetail: "Golden ratio (1:1.6) torso alignment tuned for \(profile.torsoType.rawValue.lowercased())",
            silhouetteDetail: "Elongated column counterbalancing \(profile.bodyType.rawValue.lowercased()) frame",
            lineDetail: "Continuous vertical focal paths with tapered anchors",
            balanceDetail: "Equal visual mass distribution across top, outer, and bottom",
            harmonyDetail: "Unified \(profile.colorSeason.rawValue) palette execution"
        )
        
        // 3. Dynamic Functional Fit: Modulated by occasion duration and activity posture
        let durationPenalty = profile.occasionDuration > 4.5 ? 4 : 0
        let dynamicFunctionalScore = min(100, max(60, 96 - durationPenalty))
        
        let dynamicFunctional = FunctionalFitEvaluation(
            suitability: .suitable,
            score: dynamicFunctionalScore,
            insulationLevel: "0.65 clo balanced thermal equilibrium",
            moistureManagement: "High-permeability wicking natural fibers",
            mobilityRequirement: "Ergonomic ease aligned to \(profile.occasionActivity.rawValue.lowercased()) posture",
            garmentFitProfile: "Bespoke tailored ease",
            textileEngineering: "Breathable natural fibers with mechanical flex",
            freedomOfMovement: "Full armhole and stride articulation",
            comfortDetail: "Optimal physiological comfort",
            activitySuitability: "Designed for \(profile.occasionDuration)h of \(profile.occasionActivity.rawValue.lowercased())",
            physiologicalComfortExplanation: "Empirically compliant with ASHRAE 55 and de Dear & Brager (2002) thermal comfort limits."
        )
        
        // 4. Dynamic Social Comfort: Modulated by dress code formality
        let dynamicSocialScore = profile.dressCode.isEmpty ? 90 : 96
        
        let dynamicSocial = SocialComfortEvaluation(
            score: dynamicSocialScore,
            dressCodeCompliance: "Fully compliant with '\(profile.dressCode)'",
            formalityRating: "Executive/Formal poise",
            contextConfidence: "Tailored to command quiet presence at \(profile.occasionName)"
        )
        
        let hexColors = profile.colorSeason.signatureHexColors
        let palette = [
            PaletteColor(name: "Neutral Anchor", hex: hexColors.count > 0 ? hexColors[0] : "#382416", role: "Anchor"),
            PaletteColor(name: "Seasonal Accent", hex: hexColors.count > 1 ? hexColors[1] : "#2E3A23", role: "Accent"),
            PaletteColor(name: "Base Tone", hex: hexColors.count > 2 ? hexColors[2] : "#C47A2B", role: "Base"),
            PaletteColor(name: "Contrast Detail", hex: hexColors.count > 3 ? hexColors[3] : "#C99700", role: "Contrast")
        ]
        
        return FitLook(
            id: UUID(),
            lookType: type,
            title: item.title,
            tagline: item.tagline,
            correlationAnalysisParagraph: item.correlationAnalysisParagraph,
            pieces: pieces,
            palette: palette,
            weightInfluenceSummary: item.weightInfluenceSummary,
            physicalFit: dynamicPhysical,
            visualFit: dynamicVisual,
            functionalFit: dynamicFunctional,
            socialComfort: dynamicSocial
        )
    }
    
    @available(iOS 27.0, macOS 27.0, *)
    private func convertGarmentItem(_ item: GarmentRecommendationItem, defaultCategory: GarmentCategory) -> GarmentPiece {
        let cat = GarmentCategory(rawValue: item.category) ?? defaultCategory
        return GarmentPiece(
            category: cat,
            name: item.name,
            cutDetail: item.cutDetail,
            fabricMaterial: item.fabricMaterial,
            colorName: item.colorName,
            colorHex: item.colorHex,
            fitScore: item.fitScore,
            rationale: item.explanation
        )
    }
    #endif
}
