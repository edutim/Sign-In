//
//  Server.swift
//  Sign In
//
//  Created by Timothy Hart on 2/7/23.
//

//
//  Server.swift
//  Zbrary Server
//
//  Created by Timothy Hart on 12/13/22.
//

import Foundation
import Vapor

class Server: ObservableObject {
    var app: Application
    let port: Int
    
    @Published var adminPassword = "qwerty"
    
    init(port: Int) {
        self.port = port
        
        app = Application(.development)
        
        configure(app)
        
    }
    
    func configure(_ app: Application) {
        app.http.server.configuration.hostname = "0.0.0.0"
        app.http.server.configuration.port = port
        
        
        app.get("test") { request -> String in
            return "ok"
        }
        
        app.get("findUser", ":email") { request -> ReturnedPerson in
            let email = request.parameters.get("email") ?? ""
            
            let person = DataService.shared.findPersonWith(email: email)
            if person == nil {
                return ReturnedPerson(firstName: "", lastName: "", email: "", username: "", role: "", reasonForVisit: "")
            } else {
                return ReturnedPerson(firstName: person?.firstName ?? "", lastName: person?.lastName ?? "", email: person?.email ?? "", username: person?.username ?? "", role: person?.role ?? "", reasonForVisit: person?.reasonForVisit ?? "")
            }
            
            
        }
        
        app.get("allUsers") { request -> [Person] in
            return DataService.shared.people
        }
        
        app.post("deleteAll", ":password") { request async throws -> String in
            
            let pass = request.parameters.get("password") ?? ""
            if pass == self.adminPassword {
                DataService.shared.removeAll()
                return "ok"
            } else {
                return "Something went wrong"
            }
            
        }
        
//        app.post("newUser", ":email", ":firstName", ":lastName", ":role", ":reasonForVisit") { request async throws -> String in
//             print("New User")
//            let person = Person(firstName: request.parameters.get("firstName") ?? "", lastName: request.parameters.get("lastName") ?? "", email: request.parameters.get("email") ?? "", role: request.parameters.get("role") ?? "", reasonForVisit: request.parameters.get("reasonForVisit") ?? "", date: Date(), type: "signIn")
//
//            DataService.shared.addPerson(person: person)
//
//            return "ok"
//        }
        
        app.post("signIn", ":email", ":firstName", ":lastName", ":role", ":reasonForVisit", ":campus") { request async throws -> String in
             print("New User")
            let email = request.parameters.get("email") ?? ""
            let split = email.split(separator: "@")
            let username = String(split.first ?? "error")
            
            let person = Person(firstName: request.parameters.get("firstName") ?? "", lastName: request.parameters.get("lastName") ?? "", email: request.parameters.get("email") ?? "", username: username, role: request.parameters.get("role") ?? "", reasonForVisit: request.parameters.get("reasonForVisit") ?? "", campus: request.parameters.get("campus") ?? "", type: "signIn", date: Date())
            
            DataService.shared.addPerson(person: person)
            
            return "ok"
        }
        
        app.get("signOut", ":email", ":firstName", ":lastName", ":role", ":reasonForVisit", ":campus") { request async throws -> String in
             print("New User")
            let person = Person(firstName: request.parameters.get("firstName") ?? "", lastName: request.parameters.get("lastName") ?? "", email: request.parameters.get("email") ?? "", username: request.parameters.get("username") ?? "", role: request.parameters.get("role") ?? "", reasonForVisit: request.parameters.get("reasonForVisit") ?? "", campus: request.parameters.get("campus") ?? "", type: "signOut", date: Date())
            
            DataService.shared.addPerson(person: person)
            
            let signOutDate = Date()
            
            let email = request.parameters.get("email") ?? ""
            
            let allPersonEntries = DataService.shared.people.filter({
                $0.email == email
            })
            
            let allLogIns = allPersonEntries.filter({
                $0.type == "signIn"
            })
            
            guard let lastSignInPerson = allLogIns.max(by: {
                $0.date < $1.date }) else { return "sorry" }
            
            let elapsedTime = lastSignInPerson.date - signOutDate
            
            DataService.shared.sessions.append(Session(person: person, time: elapsedTime))
            
            return "\(elapsedTime)"
        }
        
    }
    
    func start() {
        if app.didShutdown {
            app = Application(.development)
            configure(app)
        }
        Task(priority: .background) {
            do {
                try app.start()
            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }
    
    func stop() {
        app.shutdown()
    }
    
}
