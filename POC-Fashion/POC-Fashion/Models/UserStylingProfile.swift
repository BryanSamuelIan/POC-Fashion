//
//  UserStylingProfile.swift
//  POC-Fashion
//
//  Created by Bryan Samuel on 12/10/26.
//

import SwiftUI

// MARK: - Body Type (Strictly Respected - Never Re-Analyzed)
enum BodyType: String, CaseIterable, Identifiable, Codable {
    case invertedTriangle = "Inverted Triangle"
    case hourglass = "Hourglass"
    case pear = "Pear / Triangle"
    case rectangle = "Rectangle"
    case round = "Round / Apple"
    
    var id: String { rawValue }
    
    var visualGoal: String {
        switch self {
        case .invertedTriangle:
            return "Soften dominant upper frame, build visual volume on lower half to establish balanced proportions."
        case .hourglass:
            return "Emphasize natural waist definition without distorting upper-to-lower balance."
        case .pear:
            return "Draw eye upward with upper-body detail, elongate torso, and smooth lower-hip curve."
        case .rectangle:
            return "Create illusion of waist definition and curvature through diagonal/cross lines and structured layers."
        case .round:
            return "Elongate vertical silhouette with unbroken lines, open necklines, and fluid vertical drape."
        }
    }
}

// MARK: - Torso Type (Strictly Respected - Never Re-Analyzed)
enum TorsoType: String, CaseIterable, Identifiable, Codable {
    case shortTorso = "Short Torso"
    case balancedTorso = "Balanced / Mid Torso"
    case longTorso = "Long Torso"
    
    var id: String { rawValue }
    
    var stylingDirective: String {
        switch self {
        case .shortTorso:
            return "Elongate upper body visually; use mid-to-low rise bottoms, untucked or semi-tucked tops, dropped waistlines, and vertical necklines."
        case .balancedTorso:
            return "Proportions are naturally balanced; maintain standard golden ratio (1:1.6) waist definition and classic rises."
        case .longTorso:
            return "Shorten visual torso and elongate legs; utilize high-waisted bottoms, cropped jackets, wide belts, and tuck-ins."
        }
    }
}

// MARK: - Color Season (Strictly Respected - Never Re-Analyzed)
enum ColorSeason: String, CaseIterable, Identifiable, Codable {
    case deepAutumn = "Deep Autumn"
    case warmAutumn = "Warm Autumn"
    case softAutumn = "Soft Autumn"
    case deepWinter = "Deep Winter"
    case coolWinter = "Cool Winter"
    case brightWinter = "Bright Winter"
    case lightSpring = "Light Spring"
    case warmSpring = "Warm Spring"
    case brightSpring = "Bright Spring"
    case lightSummer = "Light Summer"
    case coolSummer = "Cool Summer"
    case softSummer = "Soft Summer"
    
    var id: String { rawValue }
    
    var paletteDescription: String {
        switch self {
        case .deepAutumn:
            return "Warm, deep, rich tones: Burgundy Red, Burnt Terracotta, Olive Green, Espresso, Mustard Gold."
        case .warmAutumn:
            return "Rich warm tones: Pumpkin, Camel, Rust, Golden Olive, Warm Amber."
        case .softAutumn:
            return "Muted warm tones: Sage, Dusty Rose, Soft Khaki, Warm Grey, Peach."
        case .deepWinter:
            return "High contrast cool tones: Black, True White, Midnight Navy, Ruby Red, Emerald."
        case .coolWinter:
            return "Icy cool tones: Cobalt Blue, Fuchsia, Pure Slate, Electric Purple, Crisp White."
        case .brightWinter:
            return "Vibrant high-contrast: Magenta, Royal Blue, Bright Turquoise, Onyx Black, Silver."
        case .lightSpring:
            return "Fresh warm pastel tones: Peach, Buttercup Yellow, Warm Mint, Coral Pink."
        case .warmSpring:
            return "Vivid warm tones: Coral, Sunflower, Kelly Green, Bright Camel, Aqua."
        case .brightSpring:
            return "Crisp bright warm tones: Tangerine, Poppy Red, Chartreuse, Warm Turquoise."
        case .lightSummer:
            return "Delicate cool pastel tones: Powder Blue, Lavender, Soft Periwinkle, Dusty Pink."
        case .coolSummer:
            return "Cool medium tones: Slate Blue, Plum, Cool Raspberry, Greyed Teal."
        case .softSummer:
            return "Gentle muted cool tones: Dove Grey, Muted Rose, Heather Lavender, Smoked Seafoam."
        }
    }
    
    var signatureHexColors: [String] {
        switch self {
        case .deepAutumn: return ["#800020", "#2E3A23", "#C47A2B", "#382416", "#C99700"]
        case .warmAutumn: return ["#C35214", "#A25F2A", "#655931", "#8C3B1B", "#E3A857"]
        case .softAutumn: return ["#8E9775", "#C28585", "#9B8B70", "#B36B5E", "#D4A373"]
        case .deepWinter: return ["#0B0C10", "#800020", "#0B3C5D", "#1D2731", "#FFFFFF"]
        case .coolWinter: return ["#0020C2", "#C71585", "#708090", "#2E0854", "#F5F5F5"]
        case .brightWinter: return ["#FF007F", "#0047AB", "#00D2D3", "#111111", "#E0E0E0"]
        case .lightSpring: return ["#FFB7B2", "#FFDAC1", "#E2F0CB", "#B5EAD7", "#FFF2B2"]
        case .warmSpring: return ["#FF6F61", "#FFA500", "#4CAF50", "#20B2AA", "#D2B48C"]
        case .brightSpring: return ["#FF3366", "#FF9900", "#76FF03", "#00E5FF", "#FFD700"]
        case .lightSummer: return ["#B0E0E6", "#E6E6FA", "#D8BFD8", "#FFB6C1", "#E0FFFF"]
        case .coolSummer: return ["#4682B4", "#6A5ACD", "#C71585", "#5F9EA0", "#778899"]
        case .softSummer: return ["#708090", "#BC8F8F", "#B0C4DE", "#8FBC8F", "#DCDCDC"]
        }
    }
}

// MARK: - Dedicated Body Measurements (6 Separate Fields in cm)
struct BodyMeasurements: Codable, Equatable {
    var shoulder: Double   // cm
    var torsoLength: Double // cm
    var bust: Double       // cm
    var waist: Double      // cm
    var hip: Double        // cm
    var armLength: Double  // cm
    
    static var `default`: BodyMeasurements {
        BodyMeasurements(
            shoulder: 43.0,
            torsoLength: 39.0,
            bust: 92.0,
            waist: 70.0,
            hip: 90.0,
            armLength: 56.0
        )
    }
}

// MARK: - Occasion Activity
enum OccasionActivity: String, CaseIterable, Identifiable, Codable {
    case standing = "Standing"
    case sitting = "Sitting"
    case walking = "Walking"
    case dancing = "Dancing"
    case mixed = "Mixed"
    
    var id: String { rawValue }
    
    var ergonomicImpact: String {
        switch self {
        case .standing:
            return "Requires stable footwear, non-restrictive waist ease, and balanced vertical drape."
        case .sitting:
            return "Demands generous seated abdominal ease, wrinkle-resistant textile, and comfortable rise."
        case .walking:
            return "Requires leg stride freedom, flexible seams, breathable fabrics, and low-friction hems."
        case .dancing:
            return "High dynamic range; requires stretch textiles, high armhole mobility, and secure waist anchoring."
        case .mixed:
            return "Versatile ease: balanced blend of structural poise and active flex."
        }
    }
}

// MARK: - Dynamic Variable Weights (Normalized Matrix)
struct VariableWeights: Codable, Equatable {
    var visionWeight: Double          // e.g. 30%
    var occasionWeight: Double        // e.g. 20%
    var preferenceWeight: Double      // e.g. 20%
    var bodyBalanceWeight: Double     // e.g. 15%
    var personalityWeight: Double     // e.g. 10%
    var colorSeasonWeight: Double     // e.g. 5%
    
    static var balanced: VariableWeights {
        VariableWeights(
            visionWeight: 25.0,
            occasionWeight: 20.0,
            preferenceWeight: 20.0,
            bodyBalanceWeight: 20.0,
            personalityWeight: 10.0,
            colorSeasonWeight: 5.0
        )
    }
    
    static var visionFocused: VariableWeights {
        VariableWeights(
            visionWeight: 45.0,
            occasionWeight: 15.0,
            preferenceWeight: 10.0,
            bodyBalanceWeight: 15.0,
            personalityWeight: 10.0,
            colorSeasonWeight: 5.0
        )
    }
    
    static var preferenceFocused: VariableWeights {
        VariableWeights(
            visionWeight: 15.0,
            occasionWeight: 15.0,
            preferenceWeight: 45.0,
            bodyBalanceWeight: 15.0,
            personalityWeight: 5.0,
            colorSeasonWeight: 5.0
        )
    }
    
    static var comfortAndOccasionFirst: VariableWeights {
        VariableWeights(
            visionWeight: 15.0,
            occasionWeight: 45.0,
            preferenceWeight: 10.0,
            bodyBalanceWeight: 15.0,
            personalityWeight: 10.0,
            colorSeasonWeight: 5.0
        )
    }
    
    var total: Double {
        visionWeight + occasionWeight + preferenceWeight + bodyBalanceWeight + personalityWeight + colorSeasonWeight
    }
    
    var normalized: VariableWeights {
        let sum = max(total, 0.001)
        return VariableWeights(
            visionWeight: (visionWeight / sum) * 100.0,
            occasionWeight: (occasionWeight / sum) * 100.0,
            preferenceWeight: (preferenceWeight / sum) * 100.0,
            bodyBalanceWeight: (bodyBalanceWeight / sum) * 100.0,
            personalityWeight: (personalityWeight / sum) * 100.0,
            colorSeasonWeight: (colorSeasonWeight / sum) * 100.0
        )
    }
}

// MARK: - Environmental Context (Option A: Smart Defaults based on ASHRAE 55 & de Dear & Brager 2002)
enum OccasionLocation: String, CaseIterable, Identifiable, Codable {
    case indoor = "Indoor"
    case outdoor = "Outdoor"
    var id: String { rawValue }
}

enum TimePeriod: String, CaseIterable, Identifiable, Codable {
    case morning = "Morning"
    case afternoon = "Afternoon"
    case evening = "Evening"
    case night = "Night"
    var id: String { rawValue }
}

enum AmbientTemperature: String, CaseIterable, Identifiable, Codable {
    case cold = "Cold (<18°C)"
    case neutral = "Neutral AC (21-24°C)"
    case hot = "Hot (>26°C)"
    var id: String { rawValue }
}

enum RelativeHumidity: String, CaseIterable, Identifiable, Codable {
    case low = "Low (<30%)"
    case moderate = "Moderate (30-60%)"
    case high = "High (>60%)"
    var id: String { rawValue }
}

struct EnvironmentContext: Codable, Equatable {
    var location: OccasionLocation = .indoor
    var timePeriod: TimePeriod = .evening
    var temperature: AmbientTemperature = .neutral
    var humidity: RelativeHumidity = .moderate
    
    static var smartDefault: EnvironmentContext {
        EnvironmentContext(
            location: .indoor,
            timePeriod: .evening,
            temperature: .neutral,
            humidity: .moderate
        )
    }
}

// MARK: - User Styling Profile (Dedicated Granular Fields + Weights)
struct UserStylingProfile: Equatable {
    // 1. Identity & Physical Profile
    var bodyScanImageData: Data?
    var age: Int
    var weight: Double        // kg
    var height: Double        // cm
    var bodyType: BodyType
    var torsoType: TorsoType
    var colorSeason: ColorSeason
    
    // 2. Body Measurements (6 Dedicated Fields)
    var measurements: BodyMeasurements
    
    // 3. Occasion & Social Context (Dedicated Fields + Environment)
    var occasionName: String
    var occasionDuration: Double    // hours
    var occasionActivity: OccasionActivity
    var dressCode: String
    var environment: EnvironmentContext = .smartDefault
    
    // 4. Personal Style, Vision & Reference (List of Reference Images)
    var referenceImagesData: [Data] = []
    var personalityKeywords: String
    var visionStatement: String
    
    // 5. Decision Weights
    var weights: VariableWeights
    
    static var standardExample: UserStylingProfile {
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
                torsoLength: 38.5,
                bust: 92.0,
                waist: 68.0,
                hip: 89.0,
                armLength: 57.0
            ),
            occasionName: "Tech Leadership Gala & Keynote",
            occasionDuration: 4.5,
            occasionActivity: .standing,
            dressCode: "Creative Smart Formal",
            environment: .smartDefault,
            referenceImagesData: [],
            personalityKeywords: "Sharp, Minimalist, Effortless, Confident",
            visionStatement: "Smart Creative",
            weights: .balanced
        )
    }
}

// MARK: - Vision & Foundation Model Embedding Extension
extension UserStylingProfile {
    /// Extracts on-device vector embeddings, dominant tones, and aesthetic feature prints
    /// for the user's reference images so they can be processed by Apple Foundation Models.
    func extractImageEmbeddings() async -> [VisionEmbeddingService.PreferenceImageAnalysis] {
        return await VisionEmbeddingService.shared.analyzePreferenceImages(imageDatas: referenceImagesData)
    }
}

