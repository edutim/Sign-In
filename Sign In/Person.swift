//
//  Person.swift
//  Sign In
//
//  Created by Timothy Hart on 2/7/23.
//

import Foundation
import Vapor

struct Person: Content {
    var id = UUID().uuidString
    var firstName: String
    var lastName: String
    var email: String
    var role: String
    var reasonForVisit: String
    var date: Date
}

struct ReturnedPerson: Content {
    var firstName: String
    var lastName: String
    var email: String
    var role: String
    var reasonForVisit: String
}
