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
                return ReturnedPerson(firstName: "", lastName: "", email: "", role: "", reasonForVisit: "")
            } else {
                return ReturnedPerson(firstName: person?.firstName ?? "", lastName: person?.lastName ?? "", email: person?.email ?? "", role: person?.role ?? "", reasonForVisit: person?.reasonForVisit ?? "")
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
        
        app.post("newUser", ":email", ":firstName", ":lastName", ":role", ":reasonForVisit") { request async throws -> String in
             print("New User")
            let person = Person(firstName: request.parameters.get("firstName") ?? "", lastName: request.parameters.get("lastName") ?? "", email: request.parameters.get("email") ?? "", role: request.parameters.get("role") ?? "", reasonForVisit: request.parameters.get("reasonForVisit") ?? "", date: Date())
            
            DataService.shared.addPerson(person: person)
            
            return "ok"
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
