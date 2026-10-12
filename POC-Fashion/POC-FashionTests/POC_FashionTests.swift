//
//  POC_FashionTests.swift
//  POC-FashionTests
//
//  Created by Bryan Samuel on 12/10/26.
//

import Testing
import UIKit
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
        
        // Verify 3 Rules of Fit constraint
        #expect(prompt.contains("Physical Fit"))
        #expect(prompt.contains("Visual Fit"))
        #expect(prompt.contains("Functional Fit"))
    }

    @Test func testThreeDistinctFitsAndUniqueDiagnosticParagraphs() async throws {
        let profile = StylePresets.invertedTriangleExample
        let result = try await StylingRecommenderService.shared.generateRecommendations(for: profile)
        
        // Must contain exactly 3 distinct looks
        #expect(result.looks.count == 3)
        
        let look1 = try #require(result.look1)
        let look2 = try #require(result.look2)
        let look3 = try #require(result.look3)
        
        #expect(look1.lookType == .look1Balanced)
        #expect(look2.lookType == .look2Vision)
        #expect(look3.lookType == .look3Preference)
        
        // Diagnostic paragraphs MUST be DIFFERENT for each look
        #expect(look1.diagnosticParagraph != look2.diagnosticParagraph)
        #expect(look2.diagnosticParagraph != look3.diagnosticParagraph)
        #expect(look1.diagnosticParagraph != look3.diagnosticParagraph)
        
        // Each paragraph must analyze body shape, torso type, and color season
        for look in [look1, look2, look3] {
            let paragraph = look.diagnosticParagraph.lowercased()
            #expect(paragraph.contains("inverted triangle"))
            #expect(paragraph.contains("torso"))
            #expect(paragraph.contains("autumn") || paragraph.contains("burgundy"))
        }
    }

    @Test func testMandatoryThreeFitConstraintsCompliance() async throws {
        let profile = StylePresets.invertedTriangleExample
        let result = try await StylingRecommenderService.shared.generateRecommendations(for: profile)
        
        for look in result.looks {
            // All looks, including Look 2 (Vision) and Look 3 (Preference), must pass all 3 fit rules!
            #expect(look.physicalFit.score >= 90)
            #expect(look.visualFit.score >= 90)
            #expect(look.functionalFit.score >= 90)
            #expect(look.socialComfort.score >= 90)
            
            // Check that ease, line, grain, set, and activity details are populated
            #expect(!look.physicalFit.easeDetail.isEmpty)
            #expect(!look.physicalFit.grainDetail.isEmpty)
            #expect(!look.visualFit.proportionDetail.isEmpty)
            #expect(!look.functionalFit.activitySuitability.isEmpty)
            #expect(!look.socialComfort.dressCodeCompliance.isEmpty)
        }
    }

    @Test func testSilhouetteCompositing() async throws {
        let profile = StylePresets.invertedTriangleExample
        let baseImage = try #require(profile.bodyScanImageData.flatMap { UIImage(data: $0) })
        
        let composited = VisionService.shared.compositeGarmentsOnBody(
            bodyImage: baseImage,
            look: .look1Balanced,
            profile: profile,
            paletteColors: [
                PaletteColor(name: "Burgundy", hex: "#800020", role: "Anchor"),
                PaletteColor(name: "Forest", hex: "#2E3A23", role: "Accent")
            ]
        )
        
        #expect(composited.size.width > 0)
        #expect(composited.size.height > 0)
    }
}
