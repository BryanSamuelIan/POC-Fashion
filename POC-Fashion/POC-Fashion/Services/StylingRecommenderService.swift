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
    
    // MARK: - Generate Recommendations Pipeline (100% Native Apple FoundationModels)
    func generateRecommendations(for profile: UserStylingProfile) async throws -> StylingResult {
        // 1. Extract on-device Vision feature prints & aesthetic taxonomy from preference images
        let visualAnalyses = await VisionEmbeddingService.shared.analyzePreferenceImages(imageDatas: profile.referenceImagesData)
        
        // 2. Build prompt containing user profile, guidelines, and on-device visual embedding signals
        let prompt = buildStructuredPrompt(for: profile, visualAnalyses: visualAnalyses)
        print("Generated System Prompt for Apple Foundation Model:\n\(prompt)")
        
        #if canImport(FoundationModels)
        if #available(iOS 26.0, macOS 26.0, *) {
            // 3. 100% Native Apple Foundation Model invocation via @Generable:
            let structuredRec = try await AppleFoundationModelService.shared.generateFullStylingWithFoundationModels(
                prompt: prompt,
                imageDatas: profile.referenceImagesData
            )
            print("[StylingRecommenderService] Generated styling using Apple FoundationModels @Generable with multimodal attachments")
            return convertFoundationModelOutput(structuredRec, for: profile)
        }
        #endif
        
        throw RecommenderError.modelOutputUnavailable
    }
    
    // MARK: - Prompt Builder for Apple Foundation Model
    func buildStructuredPrompt(
        for profile: UserStylingProfile,
        visualAnalyses: [VisionEmbeddingService.PreferenceImageAnalysis] = []
    ) -> String {
        let normalizedWeights = profile.weights.normalized
        
        let visionEmbeddingsSection: String
        if !visualAnalyses.isEmpty {
            let items = visualAnalyses.map { "- \($0.visualSummary)" }.joined(separator: "\n")
            visionEmbeddingsSection = """
            
            [VISION MODEL MULTIMODAL EMBEDDINGS & AESTHETIC RECOGNITION]
            On-device Apple Vision framework (VNGenerateImageFeaturePrintRequest & VNClassifyImageRequest) extracted the following vector embeddings & visual aesthetic signals:
            \(items)
            Directive: Ground garment silhouettes, texture nuances, and style details in these visual preference signals while strictly respecting the user's verified proportions.
            """
        } else {
            visionEmbeddingsSection = ""
        }
        
        return """
        [ROLE: MASTER HAUTE COUTURE FASHION DIRECTOR & FIT THEORIST]
        You are Apple Intelligence's advanced styling foundation model operating at temperature \(temperature).
        Your mission is to creatively conceptualize and engineer bespoke fashion recommendations.
        Do NOT use rigid, generic templates or cliché lists. Think deeply about clothing cuts, drapery dynamics, textile compositions, and chromatic harmonies.
        
        [VERIFIED USER ATTRIBUTES - GROUND TRUTH IMMUTABILITY]
        CRITICAL GUARDRAIL: DO NOT RE-ANALYZE OR OVERRIDE the user's verified Body Type, Torso Type, Color Season, or Measurements.
        Treat these parameters as immutable ground-truth facts:
        - Stature & Mass: Height \(profile.height) cm, Weight \(profile.weight) kg, Age \(profile.age)
        - Body Type: \(profile.bodyType.rawValue)
        - Torso Type: \(profile.torsoType.rawValue)
        - Certified Color Season: \(profile.colorSeason.rawValue) (Signature Palette: \(profile.colorSeason.signatureHexColors.joined(separator: ", ")))
        - Physical Body Measurements:
          * Shoulder Span: \(profile.measurements.shoulder) cm
          * Torso Length: \(profile.measurements.torsoLength) cm
          * Bust Circumference: \(profile.measurements.bust) cm
          * Waist Circumference: \(profile.measurements.waist) cm
          * Hip Circumference: \(profile.measurements.hip) cm
          * Arm Length: \(profile.measurements.armLength) cm
        
        [OCCASION & ENVIRONMENTAL CONTEXT - ASHRAE 55]
        - Occasion: "\(profile.occasionName)"
        - Dress Code: "\(profile.dressCode)"
        - Duration: \(profile.occasionDuration) hours
        - Activity: \(profile.occasionActivity.rawValue) (Ergonomics: \(profile.occasionActivity.ergonomicImpact))
        - Environment: \(profile.environment.location.rawValue) (\(profile.environment.temperature.rawValue), \(profile.environment.humidity.rawValue))
        
        [PERSONAL ASPIRATIONS & STYLE VISION]
        - Personal Vision: "\(profile.visionStatement)"
        - Personality Keywords: "\(profile.personalityKeywords)"
        - Preference Reference Count: \(profile.referenceImagesData.count) moodboard images\(visionEmbeddingsSection)
        
        [WEIGHTED PRIORITY HIERARCHY]
        - Vision Priority: \(String(format: "%.1f", normalizedWeights.visionWeight))%
        - Occasion & Ergonomics Priority: \(String(format: "%.1f", normalizedWeights.occasionWeight))%
        - Preference / Moodboard Priority: \(String(format: "%.1f", normalizedWeights.preferenceWeight))%
        - Body Balance & Torso Proportion Priority: \(String(format: "%.1f", normalizedWeights.bodyBalanceWeight))%
        - Personality Keywords Priority: \(String(format: "%.1f", normalizedWeights.personalityWeight))%
        - Color Season Palette Priority: \(String(format: "%.1f", normalizedWeights.colorSeasonWeight))%
        
        [STYLING OBJECTIVES - THE 3 RULES OF FIT]
        Synthesize 3 distinct looks complying with the 3 Rules of Fit (Physical Fit, Visual Fit, Functional Fit):
        - Look 1: Optimal Balance (Golden-ratio harmony balancing upper and lower silhouette)
        - Look 2: Vision-Focused (Amplifying "\(profile.visionStatement)" with aspirational tailoring)
        - Look 3: Preference-Focused (Translating moodboard texture and directional drapery into balanced proportions)
        
        For EACH look:
        1. Design all 5 essential garments: Top, Outer, Bottom, Shoes, and Accessory.
           Specify cut & construction, high-grade textile fabric, color name and hex code from their palette, and an in-depth rationale grounded in their exact measurements and decision weights.
        2. Write a comprehensive analytical paragraph explaining the correlation of the user's Body Type, Torso Type, and Color Season with the overall look.
        3. Evaluate Physical, Visual, Functional (FS = f(F, Icl, M, Mob, E)), and Social fit.
        
        [OUTPUT FORMAT - STRUCTURED JSON SCHEMA]
        Return ONLY valid JSON matching this schema:
        {
          "looks": [
            {
              "lookType": "Look 1: Optimal Balance" | "Look 2: Vision-Focused" | "Look 3: Preference-Focused",
              "title": "string",
              "tagline": "string",
              "correlationAnalysisParagraph": "string",
              "pieces": [
                {
                  "category": "Top" | "Outer" | "Bottom" | "Shoes" | "Accessory",
                  "name": "string",
                  "cutDetail": "string",
                  "fabricMaterial": "string",
                  "colorName": "string",
                  "colorHex": "#RRGGBB",
                  "rationale": "string"
                }
              ],
              "palette": [
                { "name": "string", "hex": "#RRGGBB", "role": "string" }
              ],
              "weightInfluenceSummary": "string",
              "physicalFit": { "score": 96, "easeDetail": "string", "lineDetail": "string", "grainDetail": "string", "setDetail": "string", "balanceDetail": "string" },
              "visualFit": { "score": 97, "proportionDetail": "string", "silhouetteDetail": "string", "lineDetail": "string", "balanceDetail": "string", "harmonyDetail": "string" },
              "functionalFit": {
                "suitability": "Suitable",
                "score": 97,
                "insulationLevel": "string",
                "moistureManagement": "string",
                "mobilityRequirement": "string",
                "garmentFitProfile": "string",
                "textileEngineering": "string",
                "freedomOfMovement": "string",
                "comfortDetail": "string",
                "activitySuitability": "string",
                "physiologicalComfortExplanation": "string"
              },
              "socialComfort": { "score": 98, "dressCodeCompliance": "string", "formalityRating": "string", "contextConfidence": "string" }
            }
          ]
        }
        """
    }
    
    #if canImport(FoundationModels)
    @available(iOS 26.0, macOS 26.0, *)
    func convertFoundationModelOutput(_ output: FullStylingRecommendation, for profile: UserStylingProfile) -> StylingResult {
        let look1 = convertLookItem(output.look1Balanced, type: .look1Balanced, profile: profile)
        let look2 = convertLookItem(output.look2Vision, type: .look2Vision, profile: profile)
        let look3 = convertLookItem(output.look3Preference, type: .look3Preference, profile: profile)
        
        return StylingResult(
            profileSnapshot: profile,
            looks: [look1, look2, look3]
        )
    }
    
    @available(iOS 26.0, macOS 26.0, *)
    private func convertLookItem(_ item: LookRecommendationItem, type: LookType, profile: UserStylingProfile) -> FitLook {
        let pieces = [
            convertGarmentItem(item.top, defaultCategory: .top),
            convertGarmentItem(item.outer, defaultCategory: .outer),
            convertGarmentItem(item.bottom, defaultCategory: .bottom),
            convertGarmentItem(item.shoes, defaultCategory: .shoes),
            convertGarmentItem(item.accessory, defaultCategory: .accessory)
        ]
        
        let defaultPhysical = PhysicalFitEvaluation(
            score: 95,
            easeDetail: "3-5 cm architectural ease engineered for balance",
            lineDetail: "Vertical column contours",
            grainDetail: "True on-grain drape fall",
            setDetail: "Zero horizontal strain or pull folds",
            balanceDetail: "Front and back equilibrium aligned to posture"
        )
        
        let defaultVisual = VisualFitEvaluation(
            score: 96,
            proportionDetail: "Golden ratio (1:1.6) torso alignment",
            silhouetteDetail: "Elongated column counterbalancing frame",
            lineDetail: "Continuous vertical focal paths",
            balanceDetail: "Equal visual mass distribution",
            harmonyDetail: "Unified \(profile.colorSeason.rawValue) palette execution"
        )
        
        let defaultFunctional = FunctionalFitEvaluation(
            suitability: .suitable,
            score: 94,
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
        
        let defaultSocial = SocialComfortEvaluation(
            score: 98,
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
            physicalFit: defaultPhysical,
            visualFit: defaultVisual,
            functionalFit: defaultFunctional,
            socialComfort: defaultSocial
        )
    }
    
    @available(iOS 26.0, macOS 26.0, *)
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
