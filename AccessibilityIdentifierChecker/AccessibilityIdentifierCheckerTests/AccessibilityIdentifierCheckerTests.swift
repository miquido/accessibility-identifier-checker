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
    private var passedIntervalsToScheduler: [TimeInterval] = []
    private func scheduler(timeInterval: TimeInterval, work: @escaping ()->Void) {
        passedIntervalsToScheduler.append(timeInterval)
        scheduledWork = work
    }
    
    private let interval: TimeInterval = 5.0
    
    override func setUp() {
        loggedViews = []
        scheduledWork = nil
        passedIntervalsToScheduler = []
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
        XCTAssert(wasLogged(view: view))
    }
    
    func testViewLeaks() {
        var view = UIButton()
        weak var weakView = view
        let checker = makeChecker(rootViewProvider: { weakView })
        
        checker.start()
        scheduledWork?()
        
        loggedViews = []
        view = UIButton()
        
        XCTAssertNil(weakView)
    }
    
    func testComplexTree() {
        let rootView = UIView()
        let button1 = UIButton()
        let view1 = UIView()
        let button2 = UIButton()
        
        rootView.addSubview(button1)
        rootView.addSubview(view1)
        
        view1.addSubview(button2)
        
        let checker = makeChecker(rootViewProvider: { rootView })
        
        checker.start()
        scheduledWork?()
        
        XCTAssertEqual(2, loggedViews.count)
        XCTAssert(wasLogged(view: button1))
        XCTAssert(wasLogged(view: button2))
    }
    
    func testReschedule() {
        let view = UIView()
        
        let checker = makeChecker(rootViewProvider: { view })
        checker.start()
        
        XCTAssertEqual([0.0], passedIntervalsToScheduler)
        
        scheduledWork?()
        
        XCTAssertEqual([0.0, interval], passedIntervalsToScheduler)
    }
    
    // Test custom classes
    // Test other views
    
    private func makeChecker(rootViewProvider: @escaping RootViewProvider) -> AccessibilityIdentifierChecker {
        return AccessibilityIdentifierChecker(rootViewProvider: rootViewProvider,
                                              viewLogger: viewLogger,
                                              scheduler: scheduler,
                                              interval: interval)
    }
    
    private func wasLogged(view: UIView) -> Bool {
        return loggedViews.index(where: { $0 === view }) != nil
    }
    
}
