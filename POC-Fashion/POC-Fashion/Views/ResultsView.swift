//
//  ResultsView.swift
//  POC-Fashion
//
//  Created by Bryan Samuel on 12/10/26.
//

import SwiftUI

struct ResultsView: View {
    let result: StylingResult
    @State private var selectedLookType: LookType = .look1Balanced
    @State private var selectedCategoryFilter: GarmentCategory? = nil
    
    init(result: StylingResult) {
        self.result = result
    }
    
    var currentLook: FitLook? {
        result.looks.first { $0.lookType == selectedLookType } ?? result.looks.first
    }
    
    var body: some View {
        VStack(spacing: 20) {
            
            // MARK: - Look Selector
            VStack(spacing: 8) {
                Picker("Select Look", selection: $selectedLookType) {
                    ForEach(LookType.allCases) { type in
                        Text(type.shortTitle).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 4)
                
                if let look = currentLook {
                    HStack {
                        Image(systemName: look.lookType.iconName)
                            .foregroundColor(.accentColor)
                            .font(.caption)
                        Text(look.lookType.roleBadge)
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("3 Fit Rules Verified")
                            .font(.caption2)
                            .foregroundColor(.green)
                    }
                    .padding(.horizontal, 8)
                }
            }
            
            if let look = currentLook {
                
                // MARK: - Look Header & Status Overview (No Image Overlay)
                VStack(alignment: .leading, spacing: 14) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(look.lookType.rawValue)
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.accentColor)
                            Text(look.title)
                                .font(.title3)
                                .fontWeight(.bold)
                            Text(look.tagline)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        
                        // Fit Compliance Score
                        VStack(spacing: 2) {
                            Text("\(Int(round(look.averageScore)))")
                                .font(.title2)
                                .fontWeight(.black)
                                .foregroundColor(.accentColor)
                            Text("Fit Score")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.accentColor.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    
                    Divider()
                    
                    // Seasonal Palette Swatches
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Label("Certified \(result.profileSnapshot.colorSeason.rawValue) Palette:", systemImage: "paintpalette.fill")
                                .font(.caption2)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(look.palette) { item in
                                    HStack(spacing: 6) {
                                        Circle()
                                            .fill(Color(uiColor: UIColor(hex: item.hex)))
                                            .frame(width: 14, height: 14)
                                        VStack(alignment: .leading, spacing: 1) {
                                            Text(item.name)
                                                .font(.system(size: 10, weight: .semibold))
                                            Text(item.role)
                                                .font(.system(size: 8))
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color(.systemGray6))
                                    .clipShape(Capsule())
                                }
                            }
                        }
                    }
                    
                    // Weight Influence Summary
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "slider.horizontal.3")
                            .font(.caption)
                            .foregroundColor(.purple)
                            .padding(.top, 2)
                        
                        Text(look.weightInfluenceSummary)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .lineSpacing(2)
                    }
                    .padding(10)
                    .background(Color.purple.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .padding(16)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
                
                // MARK: - Body Type, Torso & Color Season Correlation Hero Card
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "person.crop.rectangle.badge.checkmark")
                            .foregroundColor(.accentColor)
                            .font(.title3)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Body Type, Torso & Color Season Correlation")
                                .font(.headline)
                            Text("Synergistic analysis connecting your physical frame and color harmony to the overall look")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    
                    // Key Pillars Pills
                    HStack(spacing: 6) {
                        pillBadge(text: result.profileSnapshot.bodyType.rawValue, icon: "figure.stand", color: .orange)
                        pillBadge(text: result.profileSnapshot.torsoType.rawValue, icon: "arrow.up.and.down", color: .blue)
                        pillBadge(text: result.profileSnapshot.colorSeason.rawValue, icon: "paintpalette", color: .green)
                    }
                    .padding(.top, 2)
                    
                    // The Analytical Paragraph
                    Text(look.correlationAnalysisParagraph)
                        .font(.callout)
                        .lineSpacing(6)
                        .foregroundColor(.primary)
                        .padding(14)
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.accentColor.opacity(0.25), lineWidth: 1)
                        )
                }
                .padding(16)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
                
                // MARK: - The 3 Garment Types: Top, Outer, Bottom
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Label("Engineered Wardrobe (3 Garments)", systemImage: "hanger")
                                .font(.headline)
                            Text("Top, Outerwear, and Bottom with individual fit rationales")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    
                    // Garment Cards
                    ForEach(look.pieces) { piece in
                        garmentCard(piece: piece)
                    }
                }
                .padding(16)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
                
                // MARK: - 3 Rules of Fit Scorecard & Empirical Grounding
                VStack(alignment: .leading, spacing: 16) {
                    Label("The 3 Rules of Fit Validation", systemImage: "checkmark.seal.fill")
                        .font(.headline)
                        .foregroundColor(.accentColor)
                    
                    // 1. Physical Fit
                    fitPillarRow(
                        title: "1. Physical Fit",
                        score: look.physicalFit.score,
                        icon: "figure.stand.line.dotted.figure.stand",
                        color: .blue,
                        subDetails: [
                            ("Ease (Fit vs Design)", look.physicalFit.easeDetail),
                            ("Line (Contours)", look.physicalFit.lineDetail),
                            ("Grain (Drape Alignment)", look.physicalFit.grainDetail),
                            ("Set (Smoothness/No Pulling)", look.physicalFit.setDetail),
                            ("Balance (Equilibrium)", look.physicalFit.balanceDetail)
                        ]
                    )
                    
                    Divider()
                    
                    // 2. Visual Fit
                    fitPillarRow(
                        title: "2. Visual Fit",
                        score: look.visualFit.score,
                        icon: "eye.fill",
                        color: .purple,
                        subDetails: [
                            ("Proportion (Torso Balancing)", look.visualFit.proportionDetail),
                            ("Silhouette Counterweight", look.visualFit.silhouetteDetail),
                            ("Line Direction (Neck/Waist)", look.visualFit.lineDetail),
                            ("Balance (Visual Weight)", look.visualFit.balanceDetail),
                            ("Harmony & Seasonal Palette", look.visualFit.harmonyDetail)
                        ]
                    )
                    
                    Divider()
                    
                    // 3. Functional Fit (Empirical Literature Framework)
                    empiricalFunctionalFitSection(look.functionalFit)
                    
                    Divider()
                    
                    // 4. Social Comfort
                    fitPillarRow(
                        title: "Social Context & Comfort",
                        score: look.socialComfort.score,
                        icon: "person.2.fill",
                        color: .orange,
                        subDetails: [
                            ("Dress Code Compliance", look.socialComfort.dressCodeCompliance),
                            ("Formality Rating", look.socialComfort.formalityRating),
                            ("Context Confidence", look.socialComfort.contextConfidence)
                        ]
                    )
                }
                .padding(16)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
            }
        }
    }
    
    // MARK: - Garment Piece Card Component
    private func garmentCard(piece: GarmentPiece) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header Row: Category Badge + Name + Color Swatch
            HStack(alignment: .center, spacing: 8) {
                // Category Pill
                HStack(spacing: 5) {
                    Image(systemName: piece.category.iconName)
                        .font(.caption2)
                    Text(piece.category.rawValue.uppercased())
                        .font(.system(size: 10, weight: .bold))
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(categoryColor(piece.category).opacity(0.15))
                .foregroundColor(categoryColor(piece.category))
                .clipShape(Capsule())
                
                // Fit Score Pill (1-10 Scale from Apple FoundationModels)
                HStack(spacing: 3) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 9))
                    Text("Fit \(piece.fitScore)/10")
                        .font(.system(size: 10, weight: .bold))
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(Color.green.opacity(0.12))
                .foregroundColor(.green)
                .clipShape(Capsule())
                
                // Piece Name
                Text(piece.name)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                // Color Dot & Name
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color(uiColor: UIColor(hex: piece.colorHex)))
                        .frame(width: 12, height: 12)
                    Text(piece.colorName)
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
            }
            
            // Cut and Fabric Details
            VStack(alignment: .leading, spacing: 3) {
                HStack(alignment: .top, spacing: 6) {
                    Text("Cut & Construction:")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.secondary)
                    Text(piece.cutDetail)
                        .font(.system(size: 11))
                        .foregroundColor(.primary)
                }
                
                HStack(alignment: .top, spacing: 6) {
                    Text("Fabric & Material:")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.secondary)
                    Text(piece.fabricMaterial)
                        .font(.system(size: 11))
                        .foregroundColor(.primary)
                }
            }
            .padding(.horizontal, 4)
            
            // Dedicated Rationale Box
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 5) {
                    Image(systemName: "sparkles")
                        .font(.caption2)
                        .foregroundColor(.accentColor)
                    Text("Fit & Weight Rationale:")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.accentColor)
                }
                
                Text(piece.rationale)
                    .font(.caption)
                    .foregroundColor(.primary)
                    .lineSpacing(3)
            }
            .padding(10)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.accentColor.opacity(0.18), lineWidth: 1)
            )
        }
        .padding(12)
        .background(Color(.systemGray6).opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private func categoryColor(_ category: GarmentCategory) -> Color {
        switch category {
        case .top: return .blue
        case .outer: return .indigo
        case .bottom: return .teal
        case .shoes: return .brown
        case .accessory: return .purple
        }
    }
    
    private func pillBadge(text: String, icon: String, color: Color) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 9))
            Text(text)
                .font(.system(size: 10, weight: .semibold))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.12))
        .foregroundColor(color)
        .clipShape(Capsule())
    }
    
    // MARK: - Empirical Functional Fit Section
    private func empiricalFunctionalFitSection(_ fit: FunctionalFitEvaluation) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("3. Functional Fit (Empirical Framework)", systemImage: "figure.walk")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                Spacer()
                
                Text(fit.suitability.rawValue)
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.green.opacity(0.15))
                    .foregroundColor(.green)
                    .clipShape(Capsule())
            }
            
            Text("FS = f(F, Icl, M, Mob, E)")
                .font(.system(.caption2, design: .monospaced))
                .foregroundColor(.secondary)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color(.systemGray5))
                .clipShape(RoundedRectangle(cornerRadius: 4))
            
            VStack(spacing: 8) {
                empiricalMetricRow(label: "Icl (Thermal Insulation)", value: fit.insulationLevel, icon: "thermometer.medium")
                empiricalMetricRow(label: "M (Moisture Reg.)", value: fit.moistureManagement, icon: "humidity")
                empiricalMetricRow(label: "Mob (Mobility Requirement)", value: fit.mobilityRequirement, icon: "figure.run")
                empiricalMetricRow(label: "F (Garment Ease Profile)", value: fit.garmentFitProfile, icon: "arrow.left.and.right")
                empiricalMetricRow(label: "Mat (Textile Engineering)", value: fit.textileEngineering, icon: "cube.box")
            }
            .padding(10)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Operational Ergonomics:")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                
                Text("• Movement: \(fit.freedomOfMovement)")
                    .font(.caption)
                Text("• Comfort (\(String(format: "%.1f", result.profileSnapshot.occasionDuration))h): \(fit.comfortDetail)")
                    .font(.caption)
                Text("• Activity (\(result.profileSnapshot.occasionActivity.rawValue)): \(fit.activitySuitability)")
                    .font(.caption)
            }
            .padding(.leading, 4)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Grounding & Literature Synthesis:")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.secondary)
                Text(fit.physiologicalComfortExplanation)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                Text("ASHRAE Standard 55 • Raccuglia et al. (2018) • Ashdown (2007)")
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(.accentColor)
                    .padding(.top, 2)
            }
            .padding(8)
            .background(Color.green.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
    
    private func empiricalMetricRow(label: String, value: String, icon: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(.green)
                .frame(width: 14)
                .padding(.top, 2)
            
            VStack(alignment: .leading, spacing: 1) {
                Text(label)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.caption2)
                    .foregroundColor(.primary)
            }
            Spacer()
        }
    }
    
    private func fitPillarRow(
        title: String,
        score: Int,
        icon: String,
        color: Color,
        subDetails: [(String, String)]
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label(title, systemImage: icon)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(color)
                Spacer()
                Text("\(score)/100")
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(color.opacity(0.12))
                    .foregroundColor(color)
                    .clipShape(Capsule())
            }
            
            ForEach(subDetails, id: \.0) { item in
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.0)
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    Text(item.1)
                        .font(.caption)
                        .foregroundColor(.primary)
                }
                .padding(.leading, 6)
            }
        }
    }
}
