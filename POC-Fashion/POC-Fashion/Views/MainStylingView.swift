//
//  MainStylingView.swift
//  POC-Fashion
//
//  Created by Bryan Samuel on 12/10/26.
//

import SwiftUI

struct MainStylingView: View {
    @State private var profile: UserStylingProfile = StylePresets.invertedTriangleExample
    @State private var currentTab: Int = 0 // 0: Input Form, 1: Weights, 2: Results
    
    @State private var isGenerating: Bool = false
    @State private var generationStepMessage: String = ""
    @State private var result: StylingResult? = nil
    @State private var errorMessage: String? = nil
    @State private var generationTask: Task<Void, Never>? = nil
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                
                // Top Tab Selector
                Picker("Section", selection: $currentTab) {
                    Text("Inputs (18)").tag(0)
                    Text("Weights").tag(1)
                    Text("3 Fits Output").tag(2)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color(.systemBackground))
                
                // Main Scrollable Area
                ScrollView {
                    VStack(spacing: 20) {
                        
                        if currentTab == 0 {
                            ProfileInputView(profile: $profile)
                        } else if currentTab == 1 {
                            WeightMatrixView(weights: $profile.weights)
                        } else {
                            if let res = result {
                                ResultsView(result: res)
                            } else {
                                emptyResultsPlaceholder
                            }
                        }
                    }
                    .padding(16)
                    .padding(.bottom, 90) // Room for bottom generate bar
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("AI Fit Recommender")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Button("Inverted Triangle (User Example)") {
                            loadPreset(StylePresets.invertedTriangleExample)
                        }
                        Button("Pear Shape (Pitch Presentation)") {
                            loadPreset(StylePresets.pearShapeExample)
                        }
                        Button("Hourglass (Symposium Dinner)") {
                            loadPreset(StylePresets.hourglassExample)
                        }
                    } label: {
                        Label("Presets", systemImage: "sparkle.magnifyingglass")
                            .font(.caption)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Reset") {
                        loadPreset(StylePresets.invertedTriangleExample)
                        currentTab = 0
                    }
                    .font(.caption)
                }
            }
            .safeAreaInset(edge: .bottom) {
                generateActionBar
            }
            .overlay {
                if isGenerating {
                    generationLoadingOverlay
                }
            }
            .alert("Foundation Model Status", isPresented: Binding(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage ?? "")
            }
        }
    }
    
    // MARK: - Generate Action Bar
    private var generateActionBar: some View {
        VStack(spacing: 8) {
            Button(action: startGeneration) {
                HStack(spacing: 10) {
                    Image(systemName: "wand.and.stars")
                        .font(.headline)
                    Text("Generate 3 Fits & Analysis")
                        .font(.headline)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [Color.accentColor, Color.purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .shadow(color: Color.accentColor.opacity(0.35), radius: 8, x: 0, y: 4)
            }
            .disabled(isGenerating)
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
        }
        .background(.ultraThinMaterial)
    }
    
    // MARK: - Generation Loading Overlay
    private var generationLoadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.65).ignoresSafeArea()
            
            VStack(spacing: 20) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.4)
                
                VStack(spacing: 8) {
                    Text("Synthesizing 3 Rules of Fit")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(generationStepMessage)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
            }
            .padding(28)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(radius: 12)
        }
    }
    
    // MARK: - Empty Results Placeholder
    private var emptyResultsPlaceholder: some View {
        VStack(spacing: 16) {
            Image(systemName: "figure.walk.motion")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text("No Fits Generated Yet")
                .font(.headline)
            
            Text("Configure your 18 profile parameters and weights, then tap 'Generate 3 Fits & Analysis'.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Button("Generate Now") {
                startGeneration()
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 8)
        }
        .padding(.vertical, 60)
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Generation Pipeline Trigger
    private func startGeneration() {
        guard !isGenerating else { return }
        generationTask?.cancel()
        
        isGenerating = true
        generationStepMessage = "Step 1/4: Ingesting certified physical profile & 6 body measurements..."
        
        generationTask = Task {
            defer {
                Task { @MainActor in
                    self.isGenerating = false
                    self.generationTask = nil
                }
            }
            
            // Simulated AI workflow progression for visual feedback
            try? await Task.sleep(nanoseconds: 500_000_000)
            guard !Task.isCancelled else { return }
            await MainActor.run {
                generationStepMessage = "Step 2/4: Applying dynamic decision weights to occasion & vision goals..."
            }
            
            try? await Task.sleep(nanoseconds: 500_000_000)
            guard !Task.isCancelled else { return }
            await MainActor.run {
                generationStepMessage = "Step 3/4: Synthesizing 3 garments (Top, Outer, Bottom) with fit rationales..."
            }
            
            try? await Task.sleep(nanoseconds: 500_000_000)
            guard !Task.isCancelled else { return }
            await MainActor.run {
                generationStepMessage = "Step 4/4: Formulating body shape, torso & color season correlation analysis..."
            }
            
            do {
                let res = try await StylingRecommenderService.shared.generateRecommendations(for: profile)
                guard !Task.isCancelled else { return }
                await MainActor.run {
                    self.result = res
                    withAnimation {
                        self.currentTab = 2 // Switch to results tab
                    }
                }
            } catch {
                guard !Task.isCancelled else { return }
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    private func loadPreset(_ preset: UserStylingProfile) {
        generationTask?.cancel()
        generationTask = nil
        isGenerating = false
        withAnimation {
            self.profile = preset
            self.result = nil
        }
    }
}
