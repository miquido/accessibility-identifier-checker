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
    
    func testCorrectId() {
        let view = UIButton()
        view.accessibilityIdentifier = "correct id"
        let checker = makeChecker(rootViewProvider: { view })
        
        checker.start()
        scheduledWork?()
        
        XCTAssertEqual(0, loggedViews.count)
    }
    
    func testNullAndEmptyId() {
        let view = UIView()
        let buttonEmpty = UIButton()
        buttonEmpty.accessibilityIdentifier = ""
        let buttonNil = UIButton()
        buttonNil.accessibilityIdentifier = nil
        view.addSubview(buttonEmpty)
        view.addSubview(buttonNil)
        
        let checker = makeChecker(rootViewProvider: { view })
        
        checker.start()
        scheduledWork?()
        
        XCTAssertEqual(2, loggedViews.count)
        XCTAssert(wasLogged(view: buttonEmpty))
        XCTAssert(wasLogged(view: buttonNil))
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
    
    func testCustomViews() {
        class FirstCustomView: UIView {}
        class SecondCustomView: UIView {}
        
        let view = UIView()
        let firstCustomView = FirstCustomView()
        let secondCustomView = SecondCustomView()
        
        view.addSubview(firstCustomView)
        view.addSubview(secondCustomView)
        
        let checker = makeChecker(rootViewProvider: { view },
                                  customViewClasses: [FirstCustomView.self, SecondCustomView.self])
        checker.start()
        scheduledWork?()
        
        XCTAssertEqual(2, loggedViews.count)
        XCTAssert(wasLogged(view: firstCustomView))
        XCTAssert(wasLogged(view: secondCustomView))
    }
    
    func testOtherViews() {
        let view = UIView()
        
        let button = UIButton()
        let datePicker = UIDatePicker()
        let pageControl = UIPageControl()
        let segmentedControl = UISegmentedControl()
        let slider = UISlider()
        let stepper = UIStepper()
        let switchView = UISwitch()
        let textField = UITextField()
        let textView = UITextView()
        let navigationBar = UINavigationBar()
        let searchBar = UISearchBar()
        let toolbar = UIToolbar()
        let tabBar = UITabBar()
        
        view.addSubview(button)
        view.addSubview(datePicker)
        view.addSubview(pageControl)
        view.addSubview(segmentedControl)
        view.addSubview(slider)
        view.addSubview(stepper)
        view.addSubview(switchView)
        view.addSubview(textField)
        view.addSubview(textView)
        view.addSubview(navigationBar)
        view.addSubview(searchBar)
        view.addSubview(toolbar)
        view.addSubview(tabBar)
        
        let checker = makeChecker(rootViewProvider: { view })
        checker.start()
        scheduledWork?()
        
        XCTAssertEqual(13, loggedViews.count)
        XCTAssert(wasLogged(view: button))
        XCTAssert(wasLogged(view: datePicker))
        XCTAssert(wasLogged(view: pageControl))
        XCTAssert(wasLogged(view: segmentedControl))
        XCTAssert(wasLogged(view: slider))
        XCTAssert(wasLogged(view: stepper))
        XCTAssert(wasLogged(view: switchView))
        XCTAssert(wasLogged(view: textField))
        XCTAssert(wasLogged(view: textView))
        XCTAssert(wasLogged(view: navigationBar))
        XCTAssert(wasLogged(view: searchBar))
        XCTAssert(wasLogged(view: toolbar))
        XCTAssert(wasLogged(view: tabBar))
    }
    
    private func makeChecker(rootViewProvider: @escaping RootViewProvider,
                             customViewClasses: [UIView.Type] = []) -> AccessibilityIdentifierChecker {
        return AccessibilityIdentifierChecker(rootViewProvider: rootViewProvider,
                                              viewLogger: viewLogger,
                                              scheduler: scheduler,
                                              interval: interval,
                                              customViewClasses: customViewClasses)
    }
    
    private func wasLogged(view: UIView) -> Bool {
        return loggedViews.index(where: { $0 === view }) != nil
    }
    
}
