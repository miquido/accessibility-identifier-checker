//
//  AccessibilityIdentifierChecker.swift
//  AccessibilityIdentifierChecker
//
//  Created by Rafał Gaweł on 05/02/2018.
//  Copyright © 2018 Miquido. All rights reserved.
//

import UIKit

public typealias RootViewProvider = () -> UIView?
public typealias ViewLogger = (UIView) -> Void
public typealias Scheduler = (TimeInterval, @escaping () -> Void) -> Void

public class AccessibilityIdentifierChecker {
    
    private let rootViewProvider: RootViewProvider
    private let viewLogger: ViewLogger
    private let scheduler: Scheduler
    private let interval: TimeInterval
    private let customViewClasses: [UIView.Type]
    private var loggedViews: Set<WeakViewRef> = []
    
    private let standardViewClasses: [UIView.Type] = [
        UIControl.self,
        UITextView.self,
        UINavigationBar.self,
        UISearchBar.self,
        UIToolbar.self,
        UITabBar.self
    ]
    
    private let nonTraversableViews: [UIView.Type] = [
        UIStepper.self,
        UISearchBar.self
    ]
    
    public static func defaultRootViewProvider() -> UIView? {
        return UIApplication.shared.delegate?.window??.rootViewController?.view
    }
    
    public static func defaultViewLogger(view: UIView) {
        print("Missing accessibilityIdentifier: \(view)")
    }
    
    public static func defaultScheduler(delay: TimeInterval, work: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            work()
        }
    }
    
    public init(rootViewProvider: @escaping RootViewProvider = AccessibilityIdentifierChecker.defaultRootViewProvider,
                viewLogger: @escaping ViewLogger = AccessibilityIdentifierChecker.defaultViewLogger,
                scheduler: @escaping Scheduler = AccessibilityIdentifierChecker.defaultScheduler,
                interval: TimeInterval = 5.0,
                customViewClasses: [UIView.Type] = []) {
        self.rootViewProvider = rootViewProvider
        self.viewLogger = viewLogger
        self.scheduler = scheduler
        self.interval = interval
        self.customViewClasses = customViewClasses
    }
    
    public func start() {
        runCheck(afterDelay: 0.0)
    }

    private func runCheck(afterDelay delay: TimeInterval) {
        scheduler(delay) {
            guard let rootView = self.rootViewProvider() else {
                return
            }

            self.check(view: rootView)

            self.runCheck(afterDelay: self.interval)
        }
    }

    private func check(view: UIView) {
        if shouldCheck(view: view) && (view.accessibilityIdentifier == nil || view.accessibilityIdentifier == "") {
            if !loggedViews.contains(WeakViewRef(value: view)) {
                viewLogger(view)
                loggedViews.insert(WeakViewRef(value: view))
            }
        }

        if shouldCheckSubviews(of: view) {
            view.subviews.forEach { (subview) in
                check(view: subview)
            }
        }
    }

    private func shouldCheck(view: UIView) -> Bool {
        for viewClass in customViewClasses {
            if view.isKind(of: viewClass) {
                return true
            }
        }
        
        for viewClass in standardViewClasses {
            if view.isKind(of: viewClass) {
                return true
            }
        }
        
        return false
    }
    
    private func shouldCheckSubviews(of view: UIView) -> Bool {
        return !nonTraversableViews.contains(where: { view.isKind(of: $0) })
    }
    
}
