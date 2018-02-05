//
//  AccessibilityIdentifierCheckerTests.swift
//  AccessibilityIdentifierCheckerTests
//
//  Created by Rafał Gaweł on 05/02/2018.
//  Copyright © 2018 Miquido. All rights reserved.
//

import XCTest
import AccessibilityIdentifierChecker

class AccessibilityIdentifierCheckerTests: XCTestCase {
    
    private var loggedViews: [UIView] = []
    private func viewLogger(view: UIView) {
        loggedViews.append(view)
    }
    
    private var scheduledWork: (()->Void)? = nil
    private func scheduler(timeInterval: TimeInterval, work: @escaping ()->Void) {
        scheduledWork = work
    }
    
    override func setUp() {
        scheduledWork = nil
        loggedViews = []
    }
    
    func testNotScheduled() {
        let view = UIButton()
        let checker = makeChecker(rootViewProvider: { view })
        
        checker.start()
        
        XCTAssertEqual(0, loggedViews.count)
    }
    
    func testMultipleCalls() {
        let view = UIButton()
        let checker = makeChecker(rootViewProvider: { view })
        
        checker.start()
        scheduledWork?()
        scheduledWork?()
        scheduledWork?()
        
        XCTAssertEqual(1, loggedViews.count)
        XCTAssert(loggedViews.index(where: { $0 === view }) != nil)
    }
    
//    func testNoReferencesToViews() {
//        var view = UIButton()
//        let checker = makeChecker(rootViewProvider: { view })
//        
//        checker.start()
//        scheduledWork?()
//        
//        weak var weakView = view
//        view = UIButton()
//        
//        XCTAssertNil(weakView)
//    }
    
    // Test no reference cycle
    // Test complex tree
    // Test custom classes
    
    private func makeChecker(rootViewProvider: @escaping RootViewProvider) -> AccessibilityIdentifierChecker {
        return AccessibilityIdentifierChecker(rootViewProvider: rootViewProvider,
                                              viewLogger: viewLogger,
                                              scheduler: scheduler)
    }
    
}
