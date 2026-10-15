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
            age: 24,
            weight: 50.0,
            height: 163.0,
            bodyType: .rectangle,
            torsoType: .longTorso,
            colorSeason: .softAutumn,
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
            referenceImagesData: [],
            personalityKeywords: "Sharp, Confident, Modern, Sophisticated",
            visionStatement: "Creative, Smart",
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
            referenceImagesData: [],
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
            referenceImagesData: [],
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
}
