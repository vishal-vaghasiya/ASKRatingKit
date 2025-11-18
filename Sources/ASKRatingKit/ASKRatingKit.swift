//
// ASKRatingKit.swift
// Provides Apple native rating popup with single-day one-ask logic.
//
import UIKit
import StoreKit

/// A lightweight helper for showing Apple's native rating prompt.
/// Ensures the prompt is shown at most once per day.
@MainActor
public final class ASKRatingKit {

    // MARK: - Keys

    /// UserDefaults key for storing the last date the prompt was shown.
    private let lastAskedKey = "ASKRatingKit.lastAsked"

    // MARK: - Singleton

    /// Shared singleton instance.
    public static let shared = ASKRatingKit()

    // MARK: - Initialization

    /// Private initializer to enforce singleton usage.
    private init() {}

    /// UserDefaults instance used for storing prompt date.
    private var userDefaults: UserDefaults {
        return .standard
    }

    // MARK: - Public API
    /// Attempts to automatically request a rating popup from the top-most visible view controller.
    /// Useful for SwiftUI or situations where you do not have a direct UIViewController reference.
    public func requestRatingIfNeeded() {
        guard shouldShowPrompt(),
              let topVC = UIApplication.topViewController() else { return }
        
        // Store the current date as the last asked date.
        userDefaults.set(Date(), forKey: lastAskedKey)
        
        if let scene = topVC.view.window?.windowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }

    // MARK: - Prompt Logic

    /// Determines whether the rating prompt should be displayed.
    /// Ensures the prompt is shown only once per calendar day (single-day one-ask rule).
    private func shouldShowPrompt() -> Bool {
        // Already asked today → stop

        if let asked = userDefaults.object(forKey: lastAskedKey) as? Date,
           Calendar.current.isDateInToday(asked) {
            return false
        }

        return true
    }
}

// MARK: - UIApplication Helper

extension UIApplication {
    /// Returns the top-most presented UIViewController in the key window.
    public static func topViewController(base: UIViewController? = UIApplication.shared.connectedScenes
        .compactMap { ($0 as? UIWindowScene)?.keyWindow }
        .first?.rootViewController) -> UIViewController? {

        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            return topViewController(base: tab.selectedViewController)
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}
