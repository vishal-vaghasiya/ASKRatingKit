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
    private let firstLaunchKey = "ASKRatingKit.firstLaunch"

    // MARK: - Singleton

    /// Shared singleton instance.
    public static let shared = ASKRatingKit()

    // MARK: - Initialization

    /// Private initializer to enforce singleton usage.
    private init() {}

    /// UserDefaults instance used for storing prompt date.
    private let userDefaults = UserDefaults.standard

    // MARK: - Public API
    /// Attempts to automatically request a rating popup from the top-most visible view controller.
    /// Useful for SwiftUI or situations where you do not have a direct UIViewController reference.
    public func requestRatingIfNeeded() {
        guard shouldShowPrompt(),
              let topVC = UIApplication.topViewController() else { return }
        
        if let scene = topVC.view.window?.windowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
    
    public func askRating() {
        guard let topVC = UIApplication.topViewController() else { return }
        
        if let scene = topVC.view.window?.windowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }

    // MARK: - Prompt Logic

    /// Determines whether the rating prompt should be displayed.
    /// Shows prompt only if 2 days have passed since first launch and not already asked today.
    private func shouldShowPrompt() -> Bool {
        let now = Date()

        // Save the first launch date.
        if userDefaults.object(forKey: firstLaunchKey) == nil {
            userDefaults.set(now, forKey: firstLaunchKey)
            return false
        }

        // Don't show the rating prompt until 2 days after first launch.
        guard let firstLaunchDate = userDefaults.object(forKey: firstLaunchKey) as? Date,
              let eligibleDate = Calendar.current.date(byAdding: .day, value: 2, to: firstLaunchDate),
              now >= eligibleDate else {
            return false
        }

        // Don't ask again for 30 days after the last request.
        if let asked = userDefaults.object(forKey: lastAskedKey) as? Date,
           let nextEligibleDate = Calendar.current.date(byAdding: .day, value: 30, to: asked),
           now < nextEligibleDate {
            return false
        }

        // Mark today as the last prompt date.
        userDefaults.set(now, forKey: lastAskedKey)

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
