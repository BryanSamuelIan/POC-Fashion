//
//  ImagePlaygroundBridge.swift
//  POC-Fashion
//
//  Created by Bryan Samuel on 12/10/26.
//

import SwiftUI
import UIKit

#if canImport(ImagePlayground)
import ImagePlayground
#endif

struct ImagePlaygroundBridgeView: UIViewControllerRepresentable {
    var promptConcept: String
    var sourceImage: UIImage?
    var onCompletion: ((UIImage?) -> Void)?
    
    func makeUIViewController(context: Context) -> UIViewController {
        #if canImport(ImagePlayground)
        if #available(iOS 18.2, *) {
            if ImagePlaygroundViewController.isAvailable {
                let playgroundVC = ImagePlaygroundViewController()
                playgroundVC.concepts = [.text(promptConcept)]
                if let source = sourceImage {
                    playgroundVC.sourceImage = source
                }
                playgroundVC.delegate = context.coordinator
                return playgroundVC
            }
        }
        #endif
        
        // Fallback UI for Simulator or devices where Apple Intelligence is unavailable
        let fallbackVC = UIViewController()
        fallbackVC.view.backgroundColor = .systemBackground
        
        let label = UILabel()
        label.text = "Apple Image Playground\n(Active on supported Apple Intelligence hardware)\n\nConcept: \(promptConcept)"
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        
        fallbackVC.view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: fallbackVC.view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: fallbackVC.view.centerYAnchor),
            label.leadingAnchor.constraint(greaterThanOrEqualTo: fallbackVC.view.leadingAnchor, constant: 24),
            label.trailingAnchor.constraint(lessThanOrEqualTo: fallbackVC.view.trailingAnchor, constant: -24)
        ])
        
        return fallbackVC
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject {
        var parent: ImagePlaygroundBridgeView
        init(_ parent: ImagePlaygroundBridgeView) {
            self.parent = parent
        }
    }
}

#if canImport(ImagePlayground)
@available(iOS 18.2, *)
extension ImagePlaygroundBridgeView.Coordinator: ImagePlaygroundViewController.Delegate {
    func imagePlaygroundViewController(_ viewController: ImagePlaygroundViewController, didCreateImageAt imageURL: URL) {
        if let data = try? Data(contentsOf: imageURL), let image = UIImage(data: data) {
            parent.onCompletion?(image)
        }
        viewController.dismiss(animated: true)
    }
    
    func imagePlaygroundViewControllerDidCancel(_ viewController: ImagePlaygroundViewController) {
        viewController.dismiss(animated: true)
    }
}
#endif
