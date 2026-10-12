//
//  POC_FashionTests.swift
//  POC-FashionTests
//
//  Created by Bryan Samuel on 12/10/26.
//

import Testing
import UIKit
import Vision
#if canImport(FoundationModels)
import FoundationModels
#endif
@testable import POC_Fashion

struct POC_FashionTests {

    @Test func test18DedicatedFieldsInitialization() async throws {
        let profile = StylePresets.invertedTriangleExample
        
        // 1. Identity & Physical
        #expect(profile.age == 28)
        #expect(profile.weight == 56.0)
        #expect(profile.height == 167.0)
        #expect(profile.bodyType == .invertedTriangle)
        #expect(profile.torsoType == .shortTorso)
        #expect(profile.colorSeason == .deepAutumn)
        
        // 2. 6 Dedicated Measurements (cm)
        #expect(profile.measurements.shoulder == 43.5)
        #expect(profile.measurements.torsoLength == 38.0)
        #expect(profile.measurements.bust == 92.0)
        #expect(profile.measurements.waist == 68.0)
        #expect(profile.measurements.hip == 89.0)
        #expect(profile.measurements.armLength == 57.0)
        
        // 3. Occasion & Social Context
        #expect(profile.occasionName.contains("Gala"))
        #expect(profile.occasionDuration == 4.5)
        #expect(profile.occasionActivity == .standing)
        #expect(profile.dressCode == "Creative Smart Formal")
        
        // 4. Personal Style, Vision & Reference
        #expect(profile.personalityKeywords.contains("Sharp"))
        #expect(profile.visionStatement.contains("Authoritative"))
        
        // 5. Weight Matrix normalization
        let norm = profile.weights.normalized
        #expect(abs(norm.total - 100.0) < 0.1)
    }

    @Test func testPromptGuardrailsAndImmutability() async throws {
        let profile = StylePresets.invertedTriangleExample
        let prompt = StylingRecommenderService.shared.buildStructuredPrompt(for: profile)
        
        // Verify temperature constraint
        #expect(prompt.contains("temperature 0.2"))
        
        // Verify strict immutability guardrails
        #expect(prompt.contains("DO NOT RE-ANALYZE OR OVERRIDE"))
        #expect(prompt.contains(profile.bodyType.rawValue))
        #expect(prompt.contains(profile.torsoType.rawValue))
        #expect(prompt.contains(profile.colorSeason.rawValue))
        #expect(prompt.contains("43.5 cm")) // Shoulder measurement
        #expect(prompt.contains("38.0 cm")) // Torso measurement
        
        // Verify weight injection
        #expect(prompt.contains("WEIGHTED PRIORITY HIERARCHY"))
        #expect(prompt.contains("30.0%")) // Vision weight
        
        // Verify 3 Rules of Fit constraint and Structured JSON schema
        #expect(prompt.contains("3 Rules of Fit"))
        #expect(prompt.contains("STRUCTURED JSON SCHEMA"))
    }

    @Test func testThreeDistinctFitsAndCorrelationParagraphs() async throws {
        let profile = StylePresets.invertedTriangleExample
        
        guard AppleFoundationModelService.shared.isFoundationModelAvailable else {
            // Confirm 100% Foundation Model dependency: throws error when model is unavailable
            await #expect(throws: (any Error).self) {
                try await StylingRecommenderService.shared.generateRecommendations(for: profile)
            }
            return
        }
        
        let result = try await StylingRecommenderService.shared.generateRecommendations(for: profile)
        
        // Must contain exactly 3 distinct looks
        #expect(result.looks.count == 3)
        
        let look1 = try #require(result.look1)
        let look2 = try #require(result.look2)
        let look3 = try #require(result.look3)
        
        #expect(look1.lookType == .look1Balanced)
        #expect(look2.lookType == .look2Vision)
        #expect(look3.lookType == .look3Preference)
        
        // Correlation paragraphs MUST be DIFFERENT for each look
        #expect(look1.correlationAnalysisParagraph != look2.correlationAnalysisParagraph)
        #expect(look2.correlationAnalysisParagraph != look3.correlationAnalysisParagraph)
        #expect(look1.correlationAnalysisParagraph != look3.correlationAnalysisParagraph)
        
        // Each paragraph must explain correlation between body shape, torso type, color season, and overall look
        for look in [look1, look2, look3] {
            let paragraph = look.correlationAnalysisParagraph.lowercased()
            #expect(paragraph.contains("inverted triangle"))
            #expect(paragraph.contains("torso"))
            #expect(paragraph.contains("autumn") || paragraph.contains("palette"))
            #expect(paragraph.contains("overall look") || paragraph.contains("look"))
        }
    }

    @Test func testFiveGarmentCategoriesAndRationales() async throws {
        let profile = StylePresets.invertedTriangleExample
        
        guard AppleFoundationModelService.shared.isFoundationModelAvailable else {
            // Confirm 100% Foundation Model dependency: throws error when model is unavailable
            await #expect(throws: (any Error).self) {
                try await StylingRecommenderService.shared.generateRecommendations(for: profile)
            }
            return
        }
        
        let result = try await StylingRecommenderService.shared.generateRecommendations(for: profile)
        
        for look in result.looks {
            // Must contain at least the 5 required categories: Top, Outer, Bottom, Shoes, Accessory
            let categories = Set(look.pieces.map { $0.category })
            #expect(categories.contains(.top))
            #expect(categories.contains(.outer))
            #expect(categories.contains(.bottom))
            #expect(categories.contains(.shoes))
            #expect(categories.contains(.accessory))
            
            #expect(look.topPiece != nil)
            #expect(look.outerPiece != nil)
            #expect(look.bottomPiece != nil)
            #expect(look.shoesPiece != nil)
            #expect(look.accessoryPiece != nil)
            
            // Verify each piece has rich rationales and details
            for piece in look.pieces {
                #expect(!piece.name.isEmpty)
                #expect(!piece.cutDetail.isEmpty)
                #expect(!piece.fabricMaterial.isEmpty)
                #expect(!piece.colorName.isEmpty)
                #expect(!piece.colorHex.isEmpty)
                #expect(!piece.rationale.isEmpty)
                #expect(piece.rationale.count > 20)
            }
        }
    }

    @Test func testMandatoryThreeFitConstraintsCompliance() async throws {
        let profile = StylePresets.invertedTriangleExample
        
        guard AppleFoundationModelService.shared.isFoundationModelAvailable else {
            // Confirm 100% Foundation Model dependency: throws error when model is unavailable
            await #expect(throws: (any Error).self) {
                try await StylingRecommenderService.shared.generateRecommendations(for: profile)
            }
            return
        }
        
        let result = try await StylingRecommenderService.shared.generateRecommendations(for: profile)
        
        for look in result.looks {
            // All looks must pass all 3 fit rules with high scores
            #expect(look.physicalFit.score >= 90)
            #expect(look.visualFit.score >= 90)
            #expect(look.functionalFit.score >= 90)
            #expect(look.socialComfort.score >= 90)
            
            // Empirical Functional Fit validations
            #expect(look.functionalFit.suitability == .suitable)
            #expect(!look.functionalFit.insulationLevel.isEmpty)
            #expect(!look.functionalFit.moistureManagement.isEmpty)
            #expect(!look.functionalFit.mobilityRequirement.isEmpty)
            #expect(!look.functionalFit.garmentFitProfile.isEmpty)
            #expect(!look.functionalFit.textileEngineering.isEmpty)
            #expect(!look.functionalFit.physiologicalComfortExplanation.isEmpty)
            
            // Check that ease, line, grain, set, and activity details are populated
            #expect(!look.physicalFit.easeDetail.isEmpty)
            #expect(!look.physicalFit.grainDetail.isEmpty)
            #expect(!look.visualFit.proportionDetail.isEmpty)
            #expect(!look.functionalFit.activitySuitability.isEmpty)
            #expect(!look.socialComfort.dressCodeCompliance.isEmpty)
            
            // Weight influence summary is populated
            #expect(!look.weightInfluenceSummary.isEmpty)
        }
    }

    @Test func testMultiImagePreferenceListAndOptionAEnvironment() async throws {
        let profile = StylePresets.invertedTriangleExample
        
        // Multi-image preference list verification
        #expect(profile.referenceImagesData.count >= 2)
        
        // Option A Smart Defaults Verification
        #expect(profile.environment.location == .indoor)
        #expect(profile.environment.timePeriod == .evening)
        #expect(profile.environment.temperature == .neutral)
    }
    
    @Test func testAppleFoundationModelAvailability() async throws {
        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            let model = SystemLanguageModel()
            let available = model.isAvailable
            print(">>> SystemLanguageModel.isAvailable: \(available)")
        }
        #endif
    }
    
    @Test func testFoundationModelsGenerableClothingAnalysisSchema() async throws {
        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            // Verify FoundationModels GenerationSchema is synthesized and serializable
            let analysisSchema = ClothingAnalysis.generationSchema
            let analysisData = try JSONEncoder().encode(analysisSchema)
            #expect(!analysisData.isEmpty)
            
            let garmentSchema = GarmentRecommendationItem.generationSchema
            let garmentData = try JSONEncoder().encode(garmentSchema)
            #expect(!garmentData.isEmpty)
            
            let lookSchema = LookRecommendationItem.generationSchema
            let lookData = try JSONEncoder().encode(lookSchema)
            #expect(!lookData.isEmpty)
            
            let stylingSchema = FullStylingRecommendation.generationSchema
            let stylingData = try JSONEncoder().encode(stylingSchema)
            #expect(!stylingData.isEmpty)
            
            // Verify ClothingAnalysis instance with user's exact properties
            let sampleAnalysis = ClothingAnalysis(
                category: "Top",
                fitScore: 9,
                explanation: "Loose drape flatters broad shoulders while aligning with short torso."
            )
            #expect(sampleAnalysis.category == "Top")
            #expect(sampleAnalysis.fitScore == 9)
            #expect(!sampleAnalysis.explanation.isEmpty)
            print("Verified ClothingAnalysis: \(sampleAnalysis.category), score: \(sampleAnalysis.fitScore), explanation: \(sampleAnalysis.explanation)")
        }
        #endif
    }
    
    @Test func testFoundationModelsAnalyzeClothingPiece() async throws {
        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            guard AppleFoundationModelService.shared.isFoundationModelAvailable else {
                // Confirm 100% Foundation Model dependency: throws FoundationModelError.modelNotAvailable
                await #expect(throws: FoundationModelError.self) {
                    _ = try await AppleFoundationModelService.shared.analyzeClothingPiece(description: "a loose-fitting white shirt")
                }
                return
            }
            let analysis = try await AppleFoundationModelService.shared.analyzeClothingPiece(description: "a loose-fitting white shirt")
            #expect(!analysis.category.isEmpty)
            #expect(analysis.fitScore >= 1 && analysis.fitScore <= 10)
            #expect(!analysis.explanation.isEmpty)
        }
        #endif
    }
    
    @Test func testArchitectureStrictlyFailsWhenFoundationModelUnavailable() async throws {
        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            let profile = StylePresets.invertedTriangleExample
            if !AppleFoundationModelService.shared.isFoundationModelAvailable {
                // Proves 100% dependency on Foundation Model: no mock or fake fallback is returned
                await #expect(throws: FoundationModelError.self) {
                    _ = try await AppleFoundationModelService.shared.generateFullStylingWithFoundationModels(prompt: "Generate 3 fits")
                }
                await #expect(throws: (any Error).self) {
                    try await StylingRecommenderService.shared.generateRecommendations(for: profile)
                }
            }
        }
        #endif
    }
    
    @Test func testFoundationModelsFullStylingGenerationToResultConversion() async throws {
        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            let profile = StylePresets.invertedTriangleExample
            
            let mockTop = GarmentRecommendationItem(
                category: "Top",
                name: "Fluid Silk Notch Popover",
                cutDetail: "Deep vertical V-notch falling past high hip",
                fabricMaterial: "Silk-crepe fluid twill",
                colorName: "Deep Espresso",
                colorHex: "#382416",
                fitScore: 10,
                explanation: "Vertical notch directs eye along central axis, balancing shoulder width."
            )
            let mockOuter = GarmentRecommendationItem(
                category: "Outer",
                name: "Unstructured Column Duster",
                cutDetail: "Straight-cut calf duster",
                fabricMaterial: "Tropical worsted wool",
                colorName: "Forest Olive",
                colorHex: "#2E3A23",
                fitScore: 9,
                explanation: "Elongates torso without adding shoulder bulk."
            )
            let mockBottom = GarmentRecommendationItem(
                category: "Bottom",
                name: "High-Rise Wide Trouser",
                cutDetail: "Full drape straight trouser",
                fabricMaterial: "Wool-viscose blend",
                colorName: "Burnt Terracotta",
                colorHex: "#C47A2B",
                fitScore: 9,
                explanation: "Builds lower-half grounding to balance inverted triangle."
            )
            let mockShoes = GarmentRecommendationItem(
                category: "Shoes",
                name: "Sculptural Block-Heel Loafer",
                cutDetail: "Almond-toe 4cm heel",
                fabricMaterial: "Calfskin leather",
                colorName: "Espresso",
                colorHex: "#382416",
                fitScore: 9,
                explanation: "Provides stable ergonomic posture for gala standing."
            )
            let mockAccessory = GarmentRecommendationItem(
                category: "Accessory",
                name: "Linear Brass Drop Pendant",
                cutDetail: "Long vertical geometric chain",
                fabricMaterial: "Brushed brass",
                colorName: "Warm Gold",
                colorHex: "#C99700",
                fitScore: 10,
                explanation: "Reinforces vertical centerline, harmonizing with Deep Autumn."
            )
            
            let lookItem = LookRecommendationItem(
                title: "Architectural Column Poise",
                tagline: "Elongated vertical equilibrium",
                correlationAnalysisParagraph: "This overall look balances your inverted triangle frame with lower visual grounding, while adapting to your short torso and Deep Autumn palette.",
                weightInfluenceSummary: "30% Vision prioritized architectural drape.",
                top: mockTop,
                outer: mockOuter,
                bottom: mockBottom,
                shoes: mockShoes,
                accessory: mockAccessory
            )
            
            let fullRec = FullStylingRecommendation(
                look1Balanced: lookItem,
                look2Vision: lookItem,
                look3Preference: lookItem
            )
            
            let result = StylingRecommenderService.shared.convertFoundationModelOutput(fullRec, for: profile)
            #expect(result.looks.count == 3)
            let look1 = try #require(result.look1)
            #expect(look1.pieces.count == 5)
            #expect(look1.topPiece?.fitScore == 10)
            #expect(look1.outerPiece?.fitScore == 9)
            #expect(look1.bottomPiece?.category == .bottom)
            #expect(look1.shoesPiece?.category == .shoes)
            #expect(look1.accessoryPiece?.category == .accessory)
        }
        #endif
    }
    
    @Test func testVisionEmbeddingServiceExtraction() async throws {
        let profile = StylePresets.invertedTriangleExample
        #expect(profile.referenceImagesData.count >= 2)
        
        // 1. Extract on-device Vision feature prints & aesthetic taxonomy
        let analyses = await VisionEmbeddingService.shared.analyzePreferenceImages(imageDatas: profile.referenceImagesData)
        #expect(analyses.count == profile.referenceImagesData.count)
        
        for analysis in analyses {
            #expect(analysis.elementCount > 0)
            #expect(!analysis.embeddingData.isEmpty)
            #expect(!analysis.visualSummary.isEmpty)
            print("Extracted Vision Feature Print: \(analysis.elementCount) dims, Summary: \(analysis.visualSummary)")
        }
        
        // 2. Verify prompt integration contains vision multimodal embeddings section
        let promptWithVision = StylingRecommenderService.shared.buildStructuredPrompt(for: profile, visualAnalyses: analyses)
        #expect(promptWithVision.contains("VISION MODEL MULTIMODAL EMBEDDINGS"))
        #expect(promptWithVision.contains("Vector embedded"))
    }
}

