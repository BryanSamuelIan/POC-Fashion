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
    @State private var showingImagePlayground: Bool = false
    
    var currentLook: FitLook? {
        result.looks.first { $0.lookType == selectedLookType } ?? result.looks.first
    }
    
    var body: some View {
        VStack(spacing: 20) {
            
            // Look Selector
            Picker("Select Look", selection: $selectedLookType) {
                ForEach(LookType.allCases) { type in
                    Text(type.shortTitle).tag(type)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 4)
            
            if let look = currentLook {
                
                // MARK: - Visual Generation Card (Body Scan with Clothes on Top)
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
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
                        
                        // Average Fit Score Badge
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
                    
                    // Rendered Silhouette Image Preview
                    if let image = look.renderedSilhouetteImage {
                        ZStack(alignment: .bottomTrailing) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 380)
                                .frame(maxWidth: .infinity)
                                .background(Color(.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            
                            // Image Playground Button
                            Button(action: {
                                showingImagePlayground = true
                            }) {
                                Label("Image Playground", systemImage: "sparkles")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(.ultraThinMaterial)
                                    .clipShape(Capsule())
                                    .shadow(radius: 4)
                            }
                            .padding(12)
                        }
                    }
                    
                    // Seasonal Palette Swatches
                    HStack(spacing: 10) {
                        Text("Palette:")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        ForEach(look.palette) { item in
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(Color(uiColor: UIColor(hex: item.hex)))
                                    .frame(width: 14, height: 14)
                                Text(item.name)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                        Spacer()
                    }
                }
                .padding(16)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
                
                // MARK: - Dedicated Diagnostic Analysis Paragraph Card (UNIQUE PER LOOK)
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: "text.quote")
                            .foregroundColor(.accentColor)
                        Text("Diagnostic Analysis: Body Shape, Torso & Color")
                            .font(.headline)
                        Spacer()
                        Text("Look-Specific")
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.orange.opacity(0.15))
                            .foregroundColor(.orange)
                            .clipShape(Capsule())
                    }
                    
                    Text(look.diagnosticParagraph)
                        .font(.callout)
                        .lineSpacing(5)
                        .foregroundColor(.primary)
                }
                .padding(16)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.accentColor.opacity(0.25), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
                
                // MARK: - Garment Breakdown Card
                VStack(alignment: .leading, spacing: 12) {
                    Label("Engineered Garment Composition", systemImage: "tshirt")
                        .font(.headline)
                    
                    ForEach(look.pieces) { piece in
                        HStack(alignment: .top, spacing: 12) {
                            Circle()
                                .fill(Color(uiColor: UIColor(hex: piece.colorHex)))
                                .frame(width: 14, height: 14)
                                .padding(.top, 4)
                            
                            VStack(alignment: .leading, spacing: 3) {
                                HStack {
                                    Text(piece.category)
                                        .font(.caption2)
                                        .fontWeight(.bold)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Color(.systemGray5))
                                        .clipShape(Capsule())
                                    
                                    Text(piece.name)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                }
                                
                                Text(piece.cutDetail)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Text("Fit Rationale: \(piece.fitPillarNote)")
                                    .font(.caption2)
                                    .foregroundColor(.accentColor)
                            }
                            Spacer()
                        }
                        if piece.id != look.pieces.last?.id {
                            Divider()
                        }
                    }
                }
                .padding(16)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
                
                // MARK: - 3 Rules of Fit Scorecard & Grounding
                VStack(alignment: .leading, spacing: 14) {
                    Label("The 3 Rules of Fit Validation", systemImage: "checkmark.seal.fill")
                        .font(.headline)
                        .foregroundColor(.accentColor)
                    
                    // 1. Physical Fit
                    fitPillarRow(
                        title: "Physical Fit",
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
                        title: "Visual Fit",
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
                    
                    // 3. Functional Fit
                    fitPillarRow(
                        title: "Functional Fit",
                        score: look.functionalFit.score,
                        icon: "figure.walk",
                        color: .green,
                        subDetails: [
                            ("Freedom of Movement", look.functionalFit.freedomOfMovement),
                            ("Wear Comfort (\(result.profileSnapshot.occasionDuration)h)", look.functionalFit.comfortDetail),
                            ("Activity Suitability (\(result.profileSnapshot.occasionActivity.rawValue))", look.functionalFit.activitySuitability),
                            ("Material Flexibility", look.functionalFit.materialFlexibility)
                        ]
                    )
                    
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
        .sheet(isPresented: $showingImagePlayground) {
            if let look = currentLook {
                ImagePlaygroundBridgeView(
                    promptConcept: look.imagePlaygroundPrompt,
                    sourceImage: look.renderedSilhouetteImage
                )
            }
        }
    }
    
    // MARK: - UI Helpers
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
