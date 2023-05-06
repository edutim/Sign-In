//
//  DataService.swift
//  Sign In
//
//  Created by Timothy Hart on 2/7/23.
//

import Foundation

class DataService : ObservableObject {
    static var shared = DataService()
    
    
    @Published var signIns = [Person]() {
        didSet {
            saveData()
        }
    }
    
    // A session is one sign-in/sign-out cycle. A session is created and added to the sessions array when a user logs out.
    @Published var sessions = [Session]()
    
    
    init() {
        loadData()
    }

    func loadData() {
        var decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let ud = UserDefaults.standard
        if let data = ud.data(forKey: "people")  {
            if let decoded = try? JSONDecoder().decode([Person].self, from: data) {
                signIns = decoded
                return
            }
        }
        
    }
    
    func saveData() {
        
        var encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        if let encoded = try? encoder.encode(signIns) {
            UserDefaults.standard.set(encoded, forKey: "people")
            print("Saved People")
        } else {
            print("Soemthing went wrong")
        }
    }
    
    func signIn(person: Person) {
        DispatchQueue.main.sync {
            signIns.append(person)
            saveData()
        }
        
    }
    
    func signOut(person: Person, elapsedTime: TimeInterval) {
        // Create and add a session to the session array
        let session = Session(person: person, time: elapsedTime)
        sessions.append(session)
        
        // Search for and remove the user from sign in
        DispatchQueue.main.async {
            self.signIns.removeAll(where: { $0.email == person.email })
        }
    }
    
    func signOutAll() {
        let localSignIns = signIns
        for signIn in localSignIns {
            let elapsedTime = signIn.date - Date()
            signOut(person: signIn, elapsedTime: elapsedTime)
        }
    }
    
    func deleteAllSignIns() {
        signIns.removeAll()
        saveData()
    }
    
    func findPersonWith(email: String) -> Person? {
        var person = signIns.first(where: { $0.email == email })
        
        
        if person == nil {  // search by username
            let split = email.split(separator: "@")
            let username = String(split.first ?? "error")
            person = signIns.first(where: { $0.username == username })
        }
        
        if person == nil {
            return nil
        }
        
        return person
    }
    
    // CSV Stuff
    
    let dateFormatter: DateFormatter = {
          let formatter = DateFormatter()
          formatter.dateStyle = .long
          return formatter
    }()
    
    func generateLogReportAsCSV() -> String {
        var data = "firstName,lastName,email,role,reason,campus,type,date,time\n"
        for person in signIns {
            let row = "\(person.firstName),\(person.lastName),\(person.email),\(person.role),\(person.reasonForVisit),\(person.campus.replacingOccurrences(of: ",", with: "")),\(person.type),\(person.date.formatted(date: .numeric, time: .omitted)),\(person.date.formatted(date: .omitted, time: .shortened))\n"
            data.append(row)
        }
        print(data)
        return data
    }
    
    func generateSessionsReportAsCSV() -> String {
        var data = "firstName,lastName,email,role,reason,campus,date,sessionTimeInMinutes\n"
        for session in sessions {
            let person = session.person
            let row = "\(person.firstName),\(person.lastName),\(person.email),\(person.role),\(person.reasonForVisit),\(person.campus.replacingOccurrences(of: ",", with: "")),\(person.date.formatted(date: .numeric, time: .omitted)),\(round(abs(session.time)) / 60)\n"
            data.append(row)
        }
        print(data)
        return data
    }

    
}
