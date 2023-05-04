//
//  Helpers.swift
//  Sign In
//
//  Created by Timothy Hart on 5/4/23.
//

import Foundation

extension Date {

    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }

}
