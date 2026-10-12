//
//  WeightMatrixView.swift
//  POC-Fashion
//
//  Created by Bryan Samuel on 12/10/26.
//

import SwiftUI

struct WeightMatrixView: View {
    @Binding var weights: VariableWeights
    
    var normalized: VariableWeights {
        weights.normalized
    }
    
    var body: some View {
        VStack(spacing: 18) {
            
            // Header Card
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Label("Dynamic Variable Weighting Studio", systemImage: "slider.horizontal.3")
                        .font(.headline)
                    Spacer()
                    Text("Sum: 100%")
                        .font(.caption)
                        .fontWeight(.bold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.accentColor.opacity(0.15))
                        .foregroundColor(.accentColor)
                        .clipShape(Capsule())
                }
                Text("Configure how heavily the AI weighs competing goals. Trade-offs are mathematically governed by these percentages.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(16)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
            
            // Preset Buttons
            VStack(alignment: .leading, spacing: 8) {
                Text("WEIGHT PRESETS")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 8) {
                    presetButton(title: "Balanced", weightsPreset: .balanced)
                    presetButton(title: "Vision First", weightsPreset: .visionFocused)
                    presetButton(title: "Preference First", weightsPreset: .preferenceFocused)
                    presetButton(title: "Comfort First", weightsPreset: .comfortAndOccasionFirst)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Sliders
            VStack(spacing: 16) {
                weightSliderRow(
                    title: "Vision (\"Look more...\")",
                    icon: "sparkles",
                    color: .purple,
                    value: $weights.visionWeight,
                    normPct: normalized.visionWeight,
                    description: "Prioritizes silhouettes that fulfill aspirational self-image"
                )
                
                Divider()
                
                weightSliderRow(
                    title: "Occasion & Activity Dynamics",
                    icon: "calendar",
                    color: .blue,
                    value: $weights.occasionWeight,
                    normPct: normalized.occasionWeight,
                    description: "Prioritizes ease, durability, and comfort for duration & posture"
                )
                
                Divider()
                
                weightSliderRow(
                    title: "Preference & Reference Image",
                    icon: "photo.artframe",
                    color: .pink,
                    value: $weights.preferenceWeight,
                    normPct: normalized.preferenceWeight,
                    description: "Translates specific aesthetic, mood, and reference pieces"
                )
                
                Divider()
                
                weightSliderRow(
                    title: "Body Shape & Torso Proportion",
                    icon: "figure.stand",
                    color: .orange,
                    value: $weights.bodyBalanceWeight,
                    normPct: normalized.bodyBalanceWeight,
                    description: "Counterbalances upper/lower frame and adjusts rise for torso"
                )
                
                Divider()
                
                weightSliderRow(
                    title: "Personality Keywords",
                    icon: "person.text.rectangle",
                    color: .teal,
                    value: $weights.personalityWeight,
                    normPct: normalized.personalityWeight,
                    description: "Expresses personal character (e.g. sharp, effortless)"
                )
                
                Divider()
                
                weightSliderRow(
                    title: "Color Season Adherence",
                    icon: "paintpalette",
                    color: .green,
                    value: $weights.colorSeasonWeight,
                    normPct: normalized.colorSeasonWeight,
                    description: "Adheres strictly to the seasonal chromatic palette"
                )
            }
            .padding(16)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
        }
    }
    
    // MARK: - UI Helpers
    private func presetButton(title: String, weightsPreset: VariableWeights) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                weights = weightsPreset
            }
        }) {
            Text(title)
                .font(.caption2)
                .fontWeight(.medium)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(weights == weightsPreset ? Color.accentColor : Color(.systemGray6))
                .foregroundColor(weights == weightsPreset ? .white : .primary)
                .clipShape(Capsule())
        }
    }
    
    private func weightSliderRow(
        title: String,
        icon: String,
        color: Color,
        value: Binding<Double>,
        normPct: Double,
        description: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Label(title, systemImage: icon)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(color)
                Spacer()
                Text("\(Int(round(normPct)))%")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }
            
            Slider(value: value, in: 0...100, step: 1)
                .tint(color)
            
            Text(description)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}
