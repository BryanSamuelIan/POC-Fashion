//
//  ProfileInputView.swift
//  POC-Fashion
//
//  Created by Bryan Samuel on 12/10/26.
//

import SwiftUI
import PhotosUI

struct ProfileInputView: View {
    @Binding var profile: UserStylingProfile
    @State private var selectedBodyScanItem: PhotosPickerItem?
    @State private var selectedReferenceItem: PhotosPickerItem?
    
    var body: some View {
        VStack(spacing: 20) {
            
            // MARK: - 1. Physical Profile & Body Scan
            sectionCard(title: "1. Identity & Physical Profile", icon: "figure.stand") {
                VStack(spacing: 14) {
                    
                    // Body Scan Photo Picker
                    HStack(spacing: 16) {
                        if let data = profile.bodyScanImageData, let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 120)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.accentColor.opacity(0.5), lineWidth: 1.5))
                        } else {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(.systemGray6))
                                .frame(width: 80, height: 120)
                                .overlay(
                                    VStack(spacing: 6) {
                                        Image(systemName: "camera.viewfinder")
                                            .font(.title2)
                                            .foregroundColor(.secondary)
                                        Text("Body Scan")
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                )
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Body Scan (Front Side)")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text("Used to extract body silhouette & joint anchors. Guardrail: AI strictly respects your selected body type & color season.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            PhotosPicker(selection: $selectedBodyScanItem, matching: .images) {
                                Label("Upload Photo", systemImage: "photo.badge.plus")
                                    .font(.caption)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(Color.accentColor.opacity(0.12))
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    
                    Divider()
                    
                    // Age, Weight, Height
                    HStack(spacing: 12) {
                        numericField(label: "Age", value: $profile.age, unit: "yrs")
                        numericDoubleField(label: "Weight", value: $profile.weight, unit: "kg")
                        numericDoubleField(label: "Height", value: $profile.height, unit: "cm")
                    }
                    
                    // Body Type Picker (Strictly respected)
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("Body Type")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("Ground Truth (No Re-analysis)")
                                .font(.caption2)
                                .foregroundColor(.orange)
                        }
                        Picker("Body Type", selection: $profile.bodyType) {
                            ForEach(BodyType.allCases) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                        .pickerStyle(.menu)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    
                    // Torso Type Picker (Strictly respected)
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("Torso Type")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(profile.torsoType.stylingDirective)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                        Picker("Torso Type", selection: $profile.torsoType) {
                            ForEach(TorsoType.allCases) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    
                    // Color Season Picker (Strictly respected)
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("Color Season")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("Certified Palette")
                                .font(.caption2)
                                .foregroundColor(.accentColor)
                        }
                        Picker("Color Season", selection: $profile.colorSeason) {
                            ForEach(ColorSeason.allCases) { season in
                                Text(season.rawValue).tag(season)
                            }
                        }
                        .pickerStyle(.menu)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        
                        // Swatches Preview
                        HStack(spacing: 6) {
                            ForEach(profile.colorSeason.signatureHexColors, id: \.self) { hex in
                                Circle()
                                    .fill(Color(uiColor: UIColor(hex: hex)))
                                    .frame(width: 18, height: 18)
                                    .overlay(Circle().stroke(Color.white.opacity(0.4), lineWidth: 1))
                            }
                            Spacer()
                            Text(profile.colorSeason.paletteDescription)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                        .padding(.top, 4)
                    }
                }
            }
            
            // MARK: - 2. Body Measurements (6 Dedicated Fields in cm)
            sectionCard(title: "2. Body Measurements (cm)", icon: "ruler") {
                VStack(spacing: 12) {
                    Text("Exact physical measurements ensure zero pulling and accurate ease.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        measurementField(label: "Shoulder", value: $profile.measurements.shoulder)
                        measurementField(label: "Torso Length", value: $profile.measurements.torsoLength)
                        measurementField(label: "Bust", value: $profile.measurements.bust)
                        measurementField(label: "Waist", value: $profile.measurements.waist)
                        measurementField(label: "Hip", value: $profile.measurements.hip)
                        measurementField(label: "Arm Length", value: $profile.measurements.armLength)
                    }
                }
            }
            
            // MARK: - 3. Occasion & Social Context (4 Dedicated Fields)
            sectionCard(title: "3. Occasion & Social Context", icon: "calendar") {
                VStack(spacing: 12) {
                    
                    // Occasion Name
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Occasion Name")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextField("e.g. Annual Gala, Strategic Pitch", text: $profile.occasionName)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    HStack(spacing: 14) {
                        // Duration (hours)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Duration")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            HStack {
                                TextField("Hours", value: $profile.occasionDuration, format: .number)
                                    .keyboardType(.decimalPad)
                                    .textFieldStyle(.roundedBorder)
                                Text("hrs")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .frame(maxWidth: 120)
                        
                        // Dress Code
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Dress Code")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            TextField("e.g. Creative Smart Formal", text: $profile.dressCode)
                                .textFieldStyle(.roundedBorder)
                        }
                    }
                    
                    // Activity Picker (Ergonomics)
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("Primary Activity")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(profile.occasionActivity.ergonomicImpact)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                        Picker("Activity", selection: $profile.occasionActivity) {
                            ForEach(OccasionActivity.allCases) { act in
                                Text(act.rawValue).tag(act)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                }
            }
            
            // MARK: - 4. Personal Style, Vision & Reference (3 Dedicated Fields)
            sectionCard(title: "4. Style Vision & Preference", icon: "sparkles") {
                VStack(spacing: 14) {
                    
                    // Reference Image Picker (Preference)
                    HStack(spacing: 14) {
                        if let data = profile.referenceImageData, let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 70, height: 70)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        } else {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(.systemGray6))
                                .frame(width: 70, height: 70)
                                .overlay(
                                    Image(systemName: "photo.artframe")
                                        .foregroundColor(.secondary)
                                )
                        }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Reference Image (User Preference)")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text("Direct style inspiration and aesthetic cues.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            PhotosPicker(selection: $selectedReferenceItem, matching: .images) {
                                Label("Upload Reference", systemImage: "arrow.up.doc")
                                    .font(.caption)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(Color.accentColor.opacity(0.12))
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    
                    // Personality Keywords
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Personality Keywords")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextField("e.g. Sharp, Minimalist, Confident, Effortless", text: $profile.personalityKeywords)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    // Vision Statement
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Vision (\"I want to look more...\")")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextField("e.g. Authoritative, elongated, and modern chic", text: $profile.visionStatement)
                            .textFieldStyle(.roundedBorder)
                    }
                }
            }
        }
        .onChange(of: selectedBodyScanItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    profile.bodyScanImageData = data
                }
            }
        }
        .onChange(of: selectedReferenceItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    profile.referenceImageData = data
                }
            }
        }
    }
    
    // MARK: - UI Helpers
    private func sectionCard<Content: View>(title: String, icon: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: icon)
                .font(.headline)
                .foregroundColor(.primary)
            content()
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
    }
    
    private func numericField(label: String, value: Binding<Int>, unit: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            HStack(spacing: 4) {
                TextField(label, value: value, format: .number)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
                Text(unit)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private func numericDoubleField(label: String, value: Binding<Double>, unit: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            HStack(spacing: 4) {
                TextField(label, value: value, format: .number)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(.roundedBorder)
                Text(unit)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private func measurementField(label: String, value: Binding<Double>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            HStack(spacing: 2) {
                TextField(label, value: value, format: .number)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(.roundedBorder)
                Text("cm")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
}
