//
//  AccessibilityIdentifierChecker.swift
//  AccessibilityIdentifierChecker
//
//  Created by Rafał Gaweł on 05/02/2018.
//  Copyright © 2018 Miquido. All rights reserved.
//

import Foundation

public typealias RootViewProvider = () -> UIView?
public typealias ViewLogger = (UIView) -> Void
public typealias Scheduler = (TimeInterval, @escaping () -> Swift.Void) -> Void

public class AccessibilityIdentifierChecker {
    
    private let rootViewProvider: RootViewProvider
    private let viewLogger: ViewLogger
    private let scheduler: Scheduler
    private var loggedViews: Set<UIView> = []
    
    public init(rootViewProvider: @escaping RootViewProvider,
                viewLogger: @escaping ViewLogger,
                scheduler: @escaping Scheduler) {
        self.rootViewProvider = rootViewProvider
        self.viewLogger = viewLogger
        self.scheduler = scheduler
    }
    
    public func start() {
        checkAccessibilityIdentifiers(delay: 0.0)
    }

    private func checkAccessibilityIdentifiers(delay: TimeInterval) {
        scheduler(delay) {
            guard let rootView = self.rootViewProvider() else {
                return
            }

            self.checkAccessibilityIdentifiers(view: rootView)

            self.checkAccessibilityIdentifiers(delay: 5.0)
        }
    }

    private func checkAccessibilityIdentifiers(view: UIView) {
        if isInteractive(view: view) && (view.accessibilityIdentifier == nil || view.accessibilityIdentifier == "") {
            if !loggedViews.contains(view) {
                viewLogger(view)
                loggedViews.insert(view)
            }
        }

        view.subviews.forEach { (subview) in
            checkAccessibilityIdentifiers(view: subview)
        }
    }

    private func isInteractive(view: UIView) -> Bool {
        return view is UIButton // TODO
    }
    
}
