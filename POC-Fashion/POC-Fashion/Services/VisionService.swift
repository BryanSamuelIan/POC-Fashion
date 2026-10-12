//
//  VisionService.swift
//  POC-Fashion
//
//  Created by Bryan Samuel on 12/10/26.
//

import UIKit
import Vision
import CoreImage

final class VisionService {
    static let shared = VisionService()
    private init() {}
    
    // MARK: - Person Segmentation Mask Extraction
    func segmentPerson(from image: UIImage) async throws -> UIImage {
        guard let cgImage = image.cgImage else { return image }
        
        let request = VNGeneratePersonSegmentationRequest()
        request.qualityLevel = .accurate
        request.outputPixelFormat = kCVPixelFormatType_OneComponent8
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        try handler.perform([request])
        
        guard let maskPixelBuffer = request.results?.first?.pixelBuffer else {
            return image
        }
        
        let maskCIImage = CIImage(cvPixelBuffer: maskPixelBuffer)
        let originalCIImage = CIImage(cgImage: cgImage)
        
        // Scale mask to match original image dimensions
        let scaleX = originalCIImage.extent.width / maskCIImage.extent.width
        let scaleY = originalCIImage.extent.height / maskCIImage.extent.height
        let scaledMask = maskCIImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
        
        // Composite using CIBlendWithMask
        guard let filter = CIFilter(name: "CIBlendWithMask") else { return image }
        filter.setValue(originalCIImage, forKey: kCIInputImageKey)
        filter.setValue(CIImage(color: CIColor.clear).cropped(to: originalCIImage.extent), forKey: kCIInputBackgroundImageKey)
        filter.setValue(scaledMask, forKey: kCIInputMaskImageKey)
        
        guard let outputCIImage = filter.outputImage else { return image }
        let context = CIContext()
        guard let outputCGImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) else {
            return image
        }
        
        return UIImage(cgImage: outputCGImage)
    }
    
    // MARK: - Detect Body Pose Keypoints
    func detectBodyPoseJoints(from image: UIImage) async throws -> [VNHumanBodyPoseObservation.JointName: CGPoint] {
        guard let cgImage = image.cgImage else { return [:] }
        let request = VNDetectHumanBodyPoseRequest()
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        try handler.perform([request])
        
        guard let observation = request.results?.first else { return [:] }
        let recognizedPoints = try observation.recognizedPoints(.all)
        
        var normalizedJoints: [VNHumanBodyPoseObservation.JointName: CGPoint] = [:]
        for (jointName, point) in recognizedPoints where point.confidence > 0.3 {
            // Vision coordinates are normalized with origin at bottom-left
            normalizedJoints[jointName] = CGPoint(x: point.location.x, y: 1.0 - point.location.y)
        }
        return normalizedJoints
    }
    
    // MARK: - Render Styled Look On Top of Body Silhouette
    func compositeGarmentsOnBody(
        bodyImage: UIImage,
        look: LookType,
        profile: UserStylingProfile,
        paletteColors: [PaletteColor]
    ) -> UIImage {
        let size = bodyImage.size
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { ctx in
            let cg = ctx.cgContext
            
            // 1. Draw base user body scan
            bodyImage.draw(in: CGRect(origin: .zero, size: size))
            
            // 2. Garment Overlay based on Look Type & Body Type & Torso Type
            let primaryHex = paletteColors.first?.hex ?? "#800020"
            let accentHex = paletteColors.dropFirst().first?.hex ?? "#2E3A23"
            let primaryColor = UIColor(hex: primaryHex)
            let accentColor = UIColor(hex: accentHex)
            
            let w = size.width
            let h = size.height
            let centerX = w / 2.0
            
            // Landmark points tailored to profile
            let neckY = h * 0.17
            let shoulderY = h * 0.20
            let waistY = profile.torsoType == .shortTorso ? h * 0.38 : (profile.torsoType == .longTorso ? h * 0.44 : h * 0.41)
            let hipY = h * 0.50
            let kneeY = h * 0.70
            let ankleY = h * 0.88
            
            let shoulderW = profile.bodyType == .invertedTriangle ? w * 0.44 : (profile.bodyType == .pear ? w * 0.32 : w * 0.37)
            let hipW = profile.bodyType == .pear ? w * 0.45 : (profile.bodyType == .invertedTriangle ? w * 0.30 : w * 0.36)
            
            cg.saveGState()
            cg.setBlendMode(.multiply)
            cg.setAlpha(0.85)
            
            switch look {
            case .look1Balanced:
                // Look 1: Balanced synergy (e.g. relaxed polo / quarter-zip top + straight trousers)
                // Top: Relaxed polo with open V-placket
                let topPath = UIBezierPath()
                topPath.move(to: CGPoint(x: centerX - shoulderW/2, y: shoulderY))
                topPath.addLine(to: CGPoint(x: centerX - 25, y: neckY))
                topPath.addLine(to: CGPoint(x: centerX, y: neckY + 40)) // V-neckline elongation
                topPath.addLine(to: CGPoint(x: centerX + 25, y: neckY))
                topPath.addLine(to: CGPoint(x: centerX + shoulderW/2, y: shoulderY))
                topPath.addLine(to: CGPoint(x: centerX + shoulderW/2 + 20, y: shoulderY + 80))
                topPath.addLine(to: CGPoint(x: centerX + shoulderW/3, y: waistY + 15)) // Semi-untucked hem
                topPath.addLine(to: CGPoint(x: centerX - shoulderW/3, y: waistY + 15))
                topPath.addLine(to: CGPoint(x: centerX - shoulderW/2 - 20, y: shoulderY + 80))
                topPath.close()
                primaryColor.setFill()
                topPath.fill()
                
                // Bottom: Straight-cut trousers anchoring lower volume
                let pantsPath = UIBezierPath()
                let pantLegW: CGFloat = hipW * 0.48
                pantsPath.move(to: CGPoint(x: centerX - hipW/2, y: waistY + 10))
                pantsPath.addLine(to: CGPoint(x: centerX + hipW/2, y: waistY + 10))
                pantsPath.addLine(to: CGPoint(x: centerX + hipW/2, y: hipY))
                pantsPath.addLine(to: CGPoint(x: centerX + pantLegW + 15, y: ankleY))
                pantsPath.addLine(to: CGPoint(x: centerX + 5, y: ankleY))
                pantsPath.addLine(to: CGPoint(x: centerX, y: hipY + 40)) // Crotch
                pantsPath.addLine(to: CGPoint(x: centerX - 5, y: ankleY))
                pantsPath.addLine(to: CGPoint(x: centerX - pantLegW - 15, y: ankleY))
                pantsPath.addLine(to: CGPoint(x: centerX - hipW/2, y: hipY))
                pantsPath.close()
                accentColor.setFill()
                pantsPath.fill()
                
            case .look2Vision:
                // Look 2: Vision-focused (Aspirational sharp tailoring, structured architectural blazer + tailored wide trousers)
                // Structured Outerwear / Blazer
                let blazerPath = UIBezierPath()
                blazerPath.move(to: CGPoint(x: centerX - shoulderW/2 - 5, y: shoulderY - 5))
                blazerPath.addLine(to: CGPoint(x: centerX - 30, y: neckY))
                blazerPath.addLine(to: CGPoint(x: centerX, y: waistY - 10)) // Deep peak lapel
                blazerPath.addLine(to: CGPoint(x: centerX + 30, y: neckY))
                blazerPath.addLine(to: CGPoint(x: centerX + shoulderW/2 + 5, y: shoulderY - 5))
                blazerPath.addLine(to: CGPoint(x: centerX + shoulderW/2 + 25, y: hipY))
                blazerPath.addLine(to: CGPoint(x: centerX + hipW/2, y: hipY + 10))
                blazerPath.addLine(to: CGPoint(x: centerX - hipW/2, y: hipY + 10))
                blazerPath.addLine(to: CGPoint(x: centerX - shoulderW/2 - 25, y: hipY))
                blazerPath.close()
                primaryColor.setFill()
                blazerPath.fill()
                
                // Fluid high-rise palazzo pants for vertical elongation
                let palazzoPath = UIBezierPath()
                let flareW: CGFloat = hipW * 0.58
                palazzoPath.move(to: CGPoint(x: centerX - hipW/2, y: hipY))
                palazzoPath.addLine(to: CGPoint(x: centerX + hipW/2, y: hipY))
                palazzoPath.addLine(to: CGPoint(x: centerX + flareW + 20, y: ankleY + 10))
                palazzoPath.addLine(to: CGPoint(x: centerX + 10, y: ankleY + 10))
                palazzoPath.addLine(to: CGPoint(x: centerX, y: hipY + 45))
                palazzoPath.addLine(to: CGPoint(x: centerX - 10, y: ankleY + 10))
                palazzoPath.addLine(to: CGPoint(x: centerX - flareW - 20, y: ankleY + 10))
                palazzoPath.close()
                accentColor.setFill()
                palazzoPath.fill()
                
            case .look3Preference:
                // Look 3: Preference-focused (Translates moodboard reference: sleek asymmetrical knit + architectural pleated skirt)
                let topPath = UIBezierPath()
                topPath.move(to: CGPoint(x: centerX - shoulderW/2 + 10, y: shoulderY + 5))
                topPath.addLine(to: CGPoint(x: centerX + 10, y: neckY + 15)) // Asymmetrical neckline
                topPath.addLine(to: CGPoint(x: centerX + shoulderW/2, y: shoulderY))
                topPath.addLine(to: CGPoint(x: centerX + shoulderW/2 + 15, y: shoulderY + 90))
                topPath.addLine(to: CGPoint(x: centerX + hipW/3, y: waistY + 20))
                topPath.addLine(to: CGPoint(x: centerX - hipW/3, y: waistY + 20))
                topPath.addLine(to: CGPoint(x: centerX - shoulderW/2 - 15, y: shoulderY + 90))
                topPath.close()
                primaryColor.setFill()
                topPath.fill()
                
                // Architectural midi A-line skirt with fluid pleats
                let skirtPath = UIBezierPath()
                let skirtHemW = hipW * 0.75
                skirtPath.move(to: CGPoint(x: centerX - hipW/2.5, y: waistY + 15))
                skirtPath.addLine(to: CGPoint(x: centerX + hipW/2.5, y: waistY + 15))
                skirtPath.addLine(to: CGPoint(x: centerX + skirtHemW, y: kneeY + 50))
                skirtPath.addLine(to: CGPoint(x: centerX - skirtHemW, y: kneeY + 50))
                skirtPath.close()
                accentColor.setFill()
                skirtPath.fill()
            }
            
            cg.restoreGState()
            
            // 3. Precision contour stroke & design seam lines (Physical fit visual proof)
            cg.setStrokeColor(UIColor.white.withAlphaComponent(0.6).cgColor)
            cg.setLineWidth(1.5)
            // Seam line down center
            cg.move(to: CGPoint(x: centerX, y: neckY + 45))
            cg.addLine(to: CGPoint(x: centerX, y: waistY + 15))
            cg.strokePath()
            
            // Tech indicator badge
            let badgeRect = CGRect(x: 16, y: 16, width: 140, height: 28)
            let badgePath = UIBezierPath(roundedRect: badgeRect, cornerRadius: 8)
            UIColor.black.withAlphaComponent(0.65).setFill()
            badgePath.fill()
            
            let label = look.shortTitle
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12, weight: .semibold),
                .foregroundColor: UIColor.white
            ]
            let str = NSString(string: label)
            str.draw(at: CGPoint(x: 26, y: 22), withAttributes: attrs)
        }
    }
}

// MARK: - UIColor Hex Extension
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
