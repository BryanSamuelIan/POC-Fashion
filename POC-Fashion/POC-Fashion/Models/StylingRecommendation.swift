//
//  StylingRecommendation.swift
//  POC-Fashion
//
//  Created by Bryan Samuel on 12/10/26.
//

import SwiftUI

// MARK: - Look Type
enum LookType: String, CaseIterable, Identifiable, Codable {
    case look1Balanced = "Look 1: Optimal Balance"
    case look2Vision = "Look 2: Vision-Focused"
    case look3Preference = "Look 3: Preference-Focused"
    
    var id: String { rawValue }
    
    var shortTitle: String {
        switch self {
        case .look1Balanced: return "Balanced Fit"
        case .look2Vision: return "Vision Fit"
        case .look3Preference: return "Preference Fit"
        }
    }
    
    var roleBadge: String {
        switch self {
        case .look1Balanced: return "Harmonious Golden Mean"
        case .look2Vision: return "Aspirational Silhouette"
        case .look3Preference: return "Style Preference Adaptation"
        }
    }
    
    var iconName: String {
        switch self {
        case .look1Balanced: return "scale.3d"
        case .look2Vision: return "sparkles"
        case .look3Preference: return "photo.artframe"
        }
    }
}

// MARK: - Garment Piece
struct GarmentPiece: Identifiable, Codable, Equatable {
    var id: String { name }
    var category: String     // Top, Bottom, Outerwear, Shoes, Accessory, Textile
    var name: String
    var cutDetail: String
    var colorName: String
    var colorHex: String
    var fitPillarNote: String // Why this piece satisfies the 3 fit rules
}

// MARK: - Palette Color
struct PaletteColor: Identifiable, Codable, Equatable {
    var id: String { hex + role }
    var name: String
    var hex: String
    var role: String         // Base, Accent, Anchor, Contrast
}

// MARK: - Fit Look (Contains Dedicated Unique Diagnostic Paragraph)
struct FitLook: Identifiable, Equatable {
    let id: UUID
    var lookType: LookType
    var title: String
    var tagline: String
    
    /// **CRITICAL**: The narrative analysis paragraph (integrating body shape, torso type, and color season)
    /// is UNIQUE and TAILORED for each of the 3 looks!
    var diagnosticParagraph: String
    
    var pieces: [GarmentPiece]
    var palette: [PaletteColor]
    
    // The 3 Rules of Fit Evaluations (Mandatory compliance across all looks)
    var physicalFit: PhysicalFitEvaluation
    var visualFit: VisualFitEvaluation
    var functionalFit: FunctionalFitEvaluation
    var socialComfort: SocialComfortEvaluation
    
    var imagePlaygroundPrompt: String
    var renderedSilhouetteImage: UIImage?
    
    var averageScore: Double {
        Double(physicalFit.score + visualFit.score + functionalFit.score + socialComfort.score) / 4.0
    }
}

// MARK: - Complete Styling Result
struct StylingResult: Equatable {
    var id: UUID = UUID()
    var generatedAt: Date = Date()
    var profileSnapshot: UserStylingProfile
    var looks: [FitLook] // Must contain exactly 3 distinct looks
    
    var look1: FitLook? {
        looks.first { $0.lookType == .look1Balanced }
    }
    
    var look2: FitLook? {
        looks.first { $0.lookType == .look2Vision }
    }
    
    var look3: FitLook? {
        looks.first { $0.lookType == .look3Preference }
    }
}
