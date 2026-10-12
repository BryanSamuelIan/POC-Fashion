//
//  FitTheoryModels.swift
//  POC-Fashion
//
//  Created by Bryan Samuel on 12/10/26.
//

import SwiftUI

// MARK: - Physical Fit (Theory Grounding)
struct PhysicalFitEvaluation: Codable, Equatable {
    var score: Int              // 1 - 100
    var easeDetail: String      // Fit ease vs Design ease
    var lineDetail: String      // Seam / contour adherence
    var grainDetail: String     // Drape / fabric grain orientation
    var setDetail: String       // Smoothness, absence of stress wrinkles/pulling
    var balanceDetail: String   // Symmetrical equilibrium front-back-sides
    
    static var sample: PhysicalFitEvaluation {
        PhysicalFitEvaluation(
            score: 95,
            easeDetail: "3.5 cm fit ease around chest allows natural expansion; 6 cm design ease in straight trouser leg establishes structured drape.",
            lineDetail: "Dropped shoulder seam aligns precisely 1.5 cm past acromion point, de-emphasizing upper broadness.",
            grainDetail: "Vertical warp grain hangs plumb on lower leg, preventing inward twisting while walking.",
            setDetail: "Zero pulling across chest; clean break at pant hem over instep without slack pooling.",
            balanceDetail: "Weight distribution between upper quarter-zip placket and lower hemline maintains perfect gravitational center."
        )
    }
}

// MARK: - Visual Fit (Theory Grounding)
struct VisualFitEvaluation: Codable, Equatable {
    var score: Int              // 1 - 100
    var proportionDetail: String // Body-to-garment ratio (e.g. golden ratio)
    var silhouetteDetail: String // Counterbalancing natural body frame
    var lineDetail: String       // Neckline, waistline, hem directing the gaze
    var balanceDetail: String    // Optical weight distribution
    var harmonyDetail: String    // Unified coherence across shape, texture, color
    
    static var sample: VisualFitEvaluation {
        VisualFitEvaluation(
            score: 98,
            proportionDetail: "Semi-tucked hem creates an intentional 1:1.6 visual golden ratio, optically elongating the short torso.",
            silhouetteDetail: "Straight-cut trousers add essential lower-half volume to counterbalance the wide upper frame.",
            lineDetail: "Open quarter-zip creates a sharp vertical V-line, drawing gaze inward and downward.",
            balanceDetail: "Rich burgundy tone anchors visual gravity on lower limbs, relieving broad upper heaviness.",
            harmonyDetail: "Matte polo texture pairs cohesively with structured twill, embodying effortless authority."
        )
    }
}

// MARK: - Functional Fit (Theory Grounding)
struct FunctionalFitEvaluation: Codable, Equatable {
    var score: Int                  // 1 - 100
    var freedomOfMovement: String  // Articulation & stretch
    var comfortDetail: String      // Breathability & skin feel
    var activitySuitability: String// Tailored to standing/sitting duration
    var materialFlexibility: String// Fabric elastic recovery & resilience
    
    static var sample: FunctionalFitEvaluation {
        FunctionalFitEvaluation(
            score: 94,
            freedomOfMovement: "Gusseted armhole allows complete 180° arm elevation without pulling hem upwards.",
            comfortDetail: "Organic pima cotton knit provides breathable thermoregulation during 4.5 hours of wear.",
            activitySuitability: "Engineered for prolonged standing: low-stress waistband and ergonomic heel height (4 cm).",
            materialFlexibility: "2% elastane woven into straight trousers gives dynamic bounce without sagging at knees."
        )
    }
}

// MARK: - Social Context & Comfort
struct SocialComfortEvaluation: Codable, Equatable {
    var score: Int               // 1 - 100
    var dressCodeCompliance: String
    var formalityRating: String  // e.g. "Elevated Smart Formal"
    var contextConfidence: String
    
    static var sample: SocialComfortEvaluation {
        SocialComfortEvaluation(
            score: 96,
            dressCodeCompliance: "Fully satisfies 'Creative Smart Formal' with tailored lines and sophisticated tonal pairing.",
            formalityRating: "Tier 1 Executive Creative",
            contextConfidence: "Delivers effortless presence without appearing over-stiff or under-dressed."
        )
    }
}
