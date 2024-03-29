//
//  Session.swift
//  Sign In
//
//  Created by Timothy Hart on 5/4/23.
//

import Foundation

struct Session: Codable, Identifiable {
    var id = UUID()
    var person: Person
    var time: TimeInterval
}
