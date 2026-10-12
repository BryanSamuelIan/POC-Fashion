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

// MARK: - Garment Category (The 5 Clothes Types: Top, Outer, Bottom, Shoes, Accessory)
enum GarmentCategory: String, CaseIterable, Identifiable, Codable {
    case top = "Top"
    case outer = "Outer"
    case bottom = "Bottom"
    case shoes = "Shoes"
    case accessory = "Accessory"
    
    var id: String { rawValue }
    
    var iconName: String {
        switch self {
        case .top: return "tshirt.fill"
        case .outer: return "coat.fill"
        case .bottom: return "figure.walk"
        case .shoes: return "shoe.2.fill"
        case .accessory: return "sparkles"
        }
    }
    
    var displayOrder: Int {
        switch self {
        case .top: return 1
        case .outer: return 2
        case .bottom: return 3
        case .shoes: return 4
        case .accessory: return 5
        }
    }
}

// MARK: - Garment Piece Schema (Empty by default, populated by Foundation Model JSON like Pydantic)
struct GarmentPiece: Identifiable, Codable, Equatable {
    var id: String { category.rawValue + "_" + (name.isEmpty ? UUID().uuidString : name) }
    var category: GarmentCategory
    var name: String = ""
    var cutDetail: String = ""
    var fabricMaterial: String = ""
    var colorName: String = ""
    var colorHex: String = ""
    var fitScore: Int = 10
    var rationale: String = ""
    
    init(
        category: GarmentCategory,
        name: String = "",
        cutDetail: String = "",
        fabricMaterial: String = "",
        colorName: String = "",
        colorHex: String = "",
        fitScore: Int = 10,
        rationale: String = ""
    ) {
        self.category = category
        self.name = name
        self.cutDetail = cutDetail
        self.fabricMaterial = fabricMaterial
        self.colorName = colorName
        self.colorHex = colorHex
        self.fitScore = fitScore
        self.rationale = rationale
    }
    
    static func empty(category: GarmentCategory) -> GarmentPiece {
        GarmentPiece(category: category)
    }
    
    enum CodingKeys: String, CodingKey {
        case category, name, cutDetail, fabricMaterial, colorName, colorHex, fitScore, rationale
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.category = try container.decode(GarmentCategory.self, forKey: .category)
        self.name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        self.cutDetail = try container.decodeIfPresent(String.self, forKey: .cutDetail) ?? ""
        self.fabricMaterial = try container.decodeIfPresent(String.self, forKey: .fabricMaterial) ?? ""
        self.colorName = try container.decodeIfPresent(String.self, forKey: .colorName) ?? ""
        self.colorHex = try container.decodeIfPresent(String.self, forKey: .colorHex) ?? ""
        self.fitScore = try container.decodeIfPresent(Int.self, forKey: .fitScore) ?? 10
        self.rationale = try container.decodeIfPresent(String.self, forKey: .rationale) ?? ""
    }
}

// MARK: - Palette Color
struct PaletteColor: Identifiable, Codable, Equatable {
    var id: String { hex + "_" + role }
    var name: String
    var hex: String
    var role: String // Base, Accent, Anchor, Contrast
}

// MARK: - Foundation Model Output Schemas (Pydantic Equivalent in Swift)
struct FitLookSchema: Codable, Equatable {
    var lookType: LookType
    var title: String
    var tagline: String
    var correlationAnalysisParagraph: String
    var pieces: [GarmentPiece] = []
    var palette: [PaletteColor] = []
    var weightInfluenceSummary: String
    var physicalFit: PhysicalFitEvaluation
    var visualFit: VisualFitEvaluation
    var functionalFit: FunctionalFitEvaluation
    var socialComfort: SocialComfortEvaluation
}

struct StylingGenerationSchema: Codable, Equatable {
    var looks: [FitLookSchema]
}

// MARK: - Fit Look (Populated from Foundation Model Output)
struct FitLook: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var lookType: LookType
    var title: String
    var tagline: String
    var correlationAnalysisParagraph: String
    var pieces: [GarmentPiece] = []
    var palette: [PaletteColor] = []
    var weightInfluenceSummary: String = ""
    var physicalFit: PhysicalFitEvaluation
    var visualFit: VisualFitEvaluation
    var functionalFit: FunctionalFitEvaluation
    var socialComfort: SocialComfortEvaluation
    
    var averageScore: Double {
        Double(physicalFit.score + visualFit.score + functionalFit.score + socialComfort.score) / 4.0
    }
    
    // Helper accessors for each garment category
    var topPiece: GarmentPiece? { pieces.first { $0.category == .top } }
    var outerPiece: GarmentPiece? { pieces.first { $0.category == .outer } }
    var bottomPiece: GarmentPiece? { pieces.first { $0.category == .bottom } }
    var shoesPiece: GarmentPiece? { pieces.first { $0.category == .shoes } }
    var accessoryPiece: GarmentPiece? { pieces.first { $0.category == .accessory } }
}

// MARK: - Complete Styling Result
struct StylingResult: Equatable {
    var id: UUID = UUID()
    var generatedAt: Date = Date()
    var profileSnapshot: UserStylingProfile
    var looks: [FitLook] // Populated from Foundation Model
    
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

// MARK: - Color Hex Extensions
extension UIColor {
    convenience init(hex: String) {
        var cleanHex = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if cleanHex.hasPrefix("#") {
            cleanHex.remove(at: cleanHex.startIndex)
        }
        var rgbValue: UInt64 = 0
        Scanner(string: cleanHex).scanHexInt64(&rgbValue)
        
        let r, g, b, a: CGFloat
        if cleanHex.count == 6 {
            r = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgbValue & 0x0000FF) / 255.0
            a = 1.0
        } else if cleanHex.count == 8 {
            r = CGFloat((rgbValue & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgbValue & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgbValue & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgbValue & 0x000000FF) / 255.0
        } else {
            r = 0.5; g = 0.5; b = 0.5; a = 1.0
        }
        self.init(red: r, green: g, blue: b, alpha: a)
    }
}

extension Color {
    init(hex: String) {
        self.init(uiColor: UIColor(hex: hex))
    }
}
