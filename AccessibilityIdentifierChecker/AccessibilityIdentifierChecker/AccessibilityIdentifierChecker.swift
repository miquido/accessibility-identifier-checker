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
    private let interval: TimeInterval
    private let customViewClasses: [UIView.Type]
    private var loggedViews: Set<WeakViewRef> = []
    
    public init(rootViewProvider: @escaping RootViewProvider,
                viewLogger: @escaping ViewLogger,
                scheduler: @escaping Scheduler,
                interval: TimeInterval,
                customViewClasses: [UIView.Type]) {
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

        view.subviews.forEach { (subview) in
            check(view: subview)
        }
    }

    private func shouldCheck(view: UIView) -> Bool {
        for customViewClass in customViewClasses {
            if view.isKind(of: customViewClass) {
                return true
            }
        }
        
        return view is UIButton // TODO
    }
    
}
