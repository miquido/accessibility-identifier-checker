//
//  WeakViewRef.swift
//  AccessibilityIdentifierChecker
//
//  Created by Rafał Gaweł on 05/02/2018.
//  Copyright © 2018 Miquido. All rights reserved.
//

import Foundation

class WeakViewRef: Hashable {
    
    var hashValue: Int {
        return value?.hashValue ?? 0
    }
    
    private(set) weak var value: UIView?
    
    init(value: UIView) {
        self.value = value
    }
    
    static func ==(lhs: WeakViewRef, rhs: WeakViewRef) -> Bool {
        return lhs.value == rhs.value
    }
    
}
