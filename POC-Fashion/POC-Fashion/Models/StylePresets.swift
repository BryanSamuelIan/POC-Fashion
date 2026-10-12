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
            bodyScanImageData: generateDummySilhouette(bodyType: .invertedTriangle),
            age: 28,
            weight: 56.0,
            height: 167.0,
            bodyType: .invertedTriangle,
            torsoType: .shortTorso,
            colorSeason: .deepAutumn,
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
            referenceImageData: generateDummyMoodboard(primaryColor: UIColor(red: 0.5, green: 0.0, blue: 0.12, alpha: 1.0)),
            personalityKeywords: "Sharp, Confident, Modern, Sophisticated",
            visionStatement: "Authoritative, elongated, and modern chic with soft upper poise",
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
            bodyScanImageData: generateDummySilhouette(bodyType: .pear),
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
            referenceImageData: generateDummyMoodboard(primaryColor: UIColor(red: 0.27, green: 0.51, blue: 0.71, alpha: 1.0)),
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
            bodyScanImageData: generateDummySilhouette(bodyType: .hourglass),
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
            referenceImageData: generateDummyMoodboard(primaryColor: UIColor(red: 1.0, green: 0.4, blue: 0.0, alpha: 1.0)),
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
    
    // MARK: - Helper: Procedural Dummy Silhouette Scan
    static func generateDummySilhouette(bodyType: BodyType) -> Data? {
        let size = CGSize(width: 400, height: 800)
        let renderer = UIGraphicsImageRenderer(size: size)
        let img = renderer.image { ctx in
            let cg = ctx.cgContext
            
            // Background studio gradient
            let colors = [UIColor(white: 0.95, alpha: 1.0).cgColor, UIColor(white: 0.88, alpha: 1.0).cgColor]
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: [0.0, 1.0])!
            cg.drawLinearGradient(gradient, start: CGPoint(x: 200, y: 0), end: CGPoint(x: 200, y: 800), options: [])
            
            // Grid scan lines for tech aesthetic
            cg.setStrokeColor(UIColor(white: 0.80, alpha: 0.5).cgColor)
            cg.setLineWidth(1)
            for y in stride(from: 40, to: 800, by: 40) {
                cg.move(to: CGPoint(x: 20, y: y))
                cg.addLine(to: CGPoint(x: 380, y: y))
            }
            cg.strokePath()
            
            // Draw anatomical mannequin silhouette
            cg.setFillColor(UIColor(red: 0.82, green: 0.77, blue: 0.72, alpha: 1.0).cgColor)
            
            // Head
            cg.addEllipse(in: CGRect(x: 175, y: 70, width: 50, height: 65))
            cg.fillPath()
            
            // Neck
            cg.fill(CGRect(x: 190, y: 130, width: 20, height: 30))
            
            // Torso & Hips based on body type
            let torsoPath = UIBezierPath()
            let shoulderWidth: CGFloat = bodyType == .invertedTriangle ? 170 : (bodyType == .pear ? 120 : 145)
            let waistWidth: CGFloat = bodyType == .hourglass ? 80 : (bodyType == .round ? 130 : 95)
            let hipWidth: CGFloat = bodyType == .pear ? 175 : (bodyType == .invertedTriangle ? 115 : 145)
            
            let centerX: CGFloat = 200
            let shoulderY: CGFloat = 160
            let waistY: CGFloat = 290
            let hipY: CGFloat = 370
            let crotchY: CGFloat = 430
            
            // Shoulder left
            torsoPath.move(to: CGPoint(x: centerX - shoulderWidth/2, y: shoulderY))
            torsoPath.addLine(to: CGPoint(x: centerX + shoulderWidth/2, y: shoulderY))
            
            // Right torso curve to waist
            torsoPath.addQuadCurve(to: CGPoint(x: centerX + waistWidth/2, y: waistY),
                                  controlPoint: CGPoint(x: centerX + shoulderWidth/2 - 10, y: 220))
            // Right hip curve
            torsoPath.addQuadCurve(to: CGPoint(x: centerX + hipWidth/2, y: hipY),
                                  controlPoint: CGPoint(x: centerX + hipWidth/2 + 10, y: 330))
            // Right crotch
            torsoPath.addLine(to: CGPoint(x: centerX, y: crotchY))
            // Left crotch to left hip
            torsoPath.addLine(to: CGPoint(x: centerX - hipWidth/2, y: hipY))
            // Left waist
            torsoPath.addQuadCurve(to: CGPoint(x: centerX - waistWidth/2, y: waistY),
                                  controlPoint: CGPoint(x: centerX - hipWidth/2 - 10, y: 330))
            // Left shoulder
            torsoPath.addQuadCurve(to: CGPoint(x: centerX - shoulderWidth/2, y: shoulderY),
                                  controlPoint: CGPoint(x: centerX - shoulderWidth/2 + 10, y: 220))
            torsoPath.close()
            torsoPath.fill()
            
            // Arms
            let leftArm = UIBezierPath()
            leftArm.move(to: CGPoint(x: centerX - shoulderWidth/2, y: shoulderY))
            leftArm.addLine(to: CGPoint(x: centerX - shoulderWidth/2 - 25, y: 380))
            leftArm.lineWidth = 22
            leftArm.lineCapStyle = .round
            UIColor(red: 0.80, green: 0.75, blue: 0.70, alpha: 1.0).setStroke()
            leftArm.stroke()
            
            let rightArm = UIBezierPath()
            rightArm.move(to: CGPoint(x: centerX + shoulderWidth/2, y: shoulderY))
            rightArm.addLine(to: CGPoint(x: centerX + shoulderWidth/2 + 25, y: 380))
            rightArm.lineWidth = 22
            rightArm.lineCapStyle = .round
            rightArm.stroke()
            
            // Legs
            let leftLeg = UIBezierPath()
            leftLeg.move(to: CGPoint(x: centerX - hipWidth/3, y: crotchY - 10))
            leftLeg.addLine(to: CGPoint(x: centerX - 35, y: 730))
            leftLeg.lineWidth = 36
            leftLeg.lineCapStyle = .round
            leftLeg.stroke()
            
            let rightLeg = UIBezierPath()
            rightLeg.move(to: CGPoint(x: centerX + hipWidth/3, y: crotchY - 10))
            rightLeg.addLine(to: CGPoint(x: centerX + 35, y: 730))
            rightLeg.lineWidth = 36
            rightLeg.lineCapStyle = .round
            rightLeg.stroke()
        }
        return img.pngData()
    }
    
    // MARK: - Helper: Procedural Dummy Moodboard
    static func generateDummyMoodboard(primaryColor: UIColor) -> Data? {
        let size = CGSize(width: 400, height: 400)
        let renderer = UIGraphicsImageRenderer(size: size)
        let img = renderer.image { ctx in
            let cg = ctx.cgContext
            cg.setFillColor(primaryColor.cgColor)
            cg.fill(CGRect(x: 0, y: 0, width: 400, height: 400))
            
            // Fabric swatch aesthetic overlay
            cg.setFillColor(UIColor(white: 0.1, alpha: 0.25).cgColor)
            cg.fill(CGRect(x: 20, y: 20, width: 360, height: 180))
            
            cg.setFillColor(UIColor(white: 0.9, alpha: 0.35).cgColor)
            cg.fill(CGRect(x: 20, y: 220, width: 170, height: 160))
            
            cg.setFillColor(UIColor(white: 0.2, alpha: 0.3).cgColor)
            cg.fill(CGRect(x: 210, y: 220, width: 170, height: 160))
            
            let attrs: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor.white,
                .font: UIFont.systemFont(ofSize: 18, weight: .bold)
            ]
            let str = NSString(string: "AESTHETIC REFERENCE")
            str.draw(at: CGPoint(x: 40, y: 90), withAttributes: attrs)
        }
        return img.pngData()
    }
}
