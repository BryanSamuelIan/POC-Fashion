//
//  StylePresets.swift
//  POC-Fashion
//
//  Created by Bryan Samuel on 12/10/26.
//

import SwiftUI
import UIKit

struct StylePresets {
    
    // MARK: - Preset 1: Inverted Triangle (Matches User's Provided Example)
    static var invertedTriangleExample: UserStylingProfile {
        UserStylingProfile(
            bodyScanImageData: nil,
            age: 28,
            weight: 56.0,
            height: 167.0,
            bodyType: .invertedTriangle,
            torsoType: .shortTorso,
            colorSeason: .deepAutumn,
            measurements: BodyMeasurements(
                shoulder: 43.5,
                torsoLength: 38.0,
                bust: 92.0,
                waist: 68.0,
                hip: 89.0,
                armLength: 57.0
            ),
            occasionName: "Annual Tech Leadership Gala & Keynote",
            occasionDuration: 4.5,
            occasionActivity: .standing,
            dressCode: "Creative Smart Formal",
            environment: .smartDefault,
            referenceImagesData: [
                generateDummyMoodboard(title: "Style Ref 1: Tailored Minimalism", primaryColor: UIColor(red: 0.5, green: 0.0, blue: 0.12, alpha: 1.0))!,
                generateDummyMoodboard(title: "Style Ref 2: Deep Autumn Textures", primaryColor: UIColor(red: 0.18, green: 0.23, blue: 0.14, alpha: 1.0))!,
                generateDummyMoodboard(title: "Style Ref 3: Architectural Drape", primaryColor: UIColor(red: 0.77, green: 0.48, blue: 0.17, alpha: 1.0))!
            ],
            personalityKeywords: "Sharp, Confident, Modern, Sophisticated",
            visionStatement: "Authoritative, elongated, and modern chic with soft upper poise",
            weights: VariableWeights(
                visionWeight: 30.0,
                occasionWeight: 20.0,
                preferenceWeight: 20.0,
                bodyBalanceWeight: 15.0,
                personalityWeight: 10.0,
                colorSeasonWeight: 5.0
            )
        )
    }
    
    // MARK: - Preset 2: Pear Shape Pitch Presentation
    static var pearShapeExample: UserStylingProfile {
        UserStylingProfile(
            bodyScanImageData: nil,
            age: 26,
            weight: 61.0,
            height: 163.0,
            bodyType: .pear,
            torsoType: .longTorso,
            colorSeason: .coolSummer,
            measurements: BodyMeasurements(
                shoulder: 37.0,
                torsoLength: 43.0,
                bust: 86.0,
                waist: 67.0,
                hip: 99.0,
                armLength: 54.0
            ),
            occasionName: "Series A Investor Pitch & Networking",
            occasionDuration: 5.0,
            occasionActivity: .mixed,
            dressCode: "Business Casual Elevated",
            environment: EnvironmentContext(location: .indoor, timePeriod: .morning, temperature: .neutral, humidity: .moderate),
            referenceImagesData: [
                generateDummyMoodboard(title: "Ref 1: Soft Tailoring", primaryColor: UIColor(red: 0.27, green: 0.51, blue: 0.71, alpha: 1.0))!,
                generateDummyMoodboard(title: "Ref 2: Slate Palette", primaryColor: UIColor(red: 0.45, green: 0.55, blue: 0.60, alpha: 1.0))!
            ],
            personalityKeywords: "Approachable, Strategic, Poised, Polished",
            visionStatement: "Leg-elongated, dynamic presence with structured shoulder balance",
            weights: VariableWeights(
                visionWeight: 25.0,
                occasionWeight: 25.0,
                preferenceWeight: 20.0,
                bodyBalanceWeight: 15.0,
                personalityWeight: 10.0,
                colorSeasonWeight: 5.0
            )
        )
    }
    
    // MARK: - Preset 3: Hourglass Design Symposium
    static var hourglassExample: UserStylingProfile {
        UserStylingProfile(
            bodyScanImageData: nil,
            age: 30,
            weight: 55.0,
            height: 168.0,
            bodyType: .hourglass,
            torsoType: .balancedTorso,
            colorSeason: .brightSpring,
            measurements: BodyMeasurements(
                shoulder: 40.0,
                torsoLength: 40.0,
                bust: 91.0,
                waist: 64.0,
                hip: 92.0,
                armLength: 58.0
            ),
            occasionName: "Design Council Symposium Dinner",
            occasionDuration: 3.5,
            occasionActivity: .sitting,
            dressCode: "Cocktail Avant-Garde",
            environment: EnvironmentContext(location: .indoor, timePeriod: .evening, temperature: .neutral, humidity: .moderate),
            referenceImagesData: [
                generateDummyMoodboard(title: "Ref 1: Radiant Drape", primaryColor: UIColor(red: 1.0, green: 0.4, blue: 0.0, alpha: 1.0))!,
                generateDummyMoodboard(title: "Ref 2: Vivid Contrast", primaryColor: UIColor(red: 0.0, green: 0.8, blue: 0.8, alpha: 1.0))!
            ],
            personalityKeywords: "Artistic, Radiant, Bold, Effortless",
            visionStatement: "Architectural poise that celebrates natural curves without restriction",
            weights: VariableWeights(
                visionWeight: 35.0,
                occasionWeight: 15.0,
                preferenceWeight: 25.0,
                bodyBalanceWeight: 15.0,
                personalityWeight: 5.0,
                colorSeasonWeight: 5.0
            )
        )
    }
    
    // MARK: - Helper: Procedural Dummy Moodboard
    static func generateDummyMoodboard(title: String = "AESTHETIC REFERENCE", primaryColor: UIColor) -> Data? {
        let size = CGSize(width: 400, height: 400)
        let renderer = UIGraphicsImageRenderer(size: size)
        let img = renderer.image { ctx in
            let cg = ctx.cgContext
            cg.setFillColor(primaryColor.cgColor)
            cg.fill(CGRect(x: 0, y: 0, width: 400, height: 400))
            
            // Fabric swatch aesthetic overlay
            cg.setFillColor(UIColor(white: 0.1, alpha: 0.25).cgColor)
            cg.fill(CGRect(x: 20, y: 20, width: 360, height: 180))
            
            cg.setFillColor(UIColor(white: 0.9, alpha: 0.35).cgColor)
            cg.fill(CGRect(x: 20, y: 220, width: 170, height: 160))
            
            cg.setFillColor(UIColor(white: 0.2, alpha: 0.3).cgColor)
            cg.fill(CGRect(x: 210, y: 220, width: 170, height: 160))
            
            let attrs: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor.white,
                .font: UIFont.systemFont(ofSize: 16, weight: .bold)
            ]
            let str = NSString(string: title)
            str.draw(at: CGPoint(x: 35, y: 85), withAttributes: attrs)
        }
        return img.pngData()
    }
}
