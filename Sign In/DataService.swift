//
//  DataService.swift
//  Sign In
//
//  Created by Timothy Hart on 2/7/23.
//

import Foundation

class DataService : ObservableObject {
    static var shared = DataService()
    
    // Tracks who is currently signedIn
    @Published var signIns = [Person]()
    @Published var filteredSignIns = [Person]()
    var signInFilters = [String]()

    
    // A session is one sign-in/sign-out cycle. A session is created and added to the sessions array when a user logs out.
    @Published var sessions = [Session]()
    @Published var filteredSessions = [Session]()
    var sessionFilters = [String]()
    
    // The people array holds people to search for
    var people = [Person]()
    
    
    
    func debug() {
        
    }
    
    init() {
        loadData()
    }

    func loadData() {
        var decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let ud = UserDefaults.standard
        
        // Sign Ins
        
        if let data = ud.data(forKey: "signIns")  {
            if let decoded = try? decoder.decode([Person].self, from: data) {
                signIns = decoded
               
            }
        }
        
        // Sessions
        if let data = ud.data(forKey: "sessions")  {
            if let decoded = try? decoder.decode([Session].self, from: data) {
                sessions = decoded
                
            }
        }
        
        
        // Past peeople
        if let data = ud.data(forKey: "people")  {
            do {
                let decoded = try decoder.decode([Person].self, from: data)
                people = decoded
            } catch {
                print(error.localizedDescription)
            }
            
        }
        
        applySignInFilters()
        applySessionsFilters()
    }
    
    func saveData() {
        
        var encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        if let encoded = try? encoder.encode(signIns) {
            UserDefaults.standard.set(encoded, forKey: "signIns")
            print("Saved Sign Ins")
        } else {
            print("Soemthing went wrong")
        }
        
      
        if let encoded = try? encoder.encode(sessions) {
            UserDefaults.standard.set(encoded, forKey: "sessions")
            print("Saved Sessions")
        } else {
            print("Soemthing went wrong")
        }
        
    
        if let encoded = try? encoder.encode(people) {
            UserDefaults.standard.set(encoded, forKey: "people")
            print("Saved People")
        } else {
            print("Soemthing went wrong")
        }
        
        applySignInFilters()
        applySessionsFilters()
    }
    
    func signIn(person: Person) {
        DispatchQueue.main.async {
            self.signIns.append(person)
            
            if let foundPerson = self.findPersonWith(email: person.email) {
                if let index = self.people.firstIndex(where: { $0.email == foundPerson.email }) {
                    self.people[index] = person
                    print("Updating Person")
                }

            } else {
                self.people.append(person)
                print("added person to people")
            }
            
            self.saveData()
        }
        
    }
    
    func signOut(person: Person, elapsedTime: TimeInterval) {
        // Create and add a session to the session array
        DispatchQueue.main.async {
            let session = Session(person: person, time: elapsedTime)
            self.sessions.append(session)
        }
        
        
        // Search for and remove the user from sign in
        if let foundPerson = findPersonWith(email: person.email) {
            DispatchQueue.main.async {
                self.signIns.removeAll(where: { $0.email == person.email })
            }
        }
        saveData()
    }
    
    func signOutAll() {
        let localSignIns = signIns
        for signIn in localSignIns {
            let elapsedTime = signIn.date - Date()
            signOut(person: signIn, elapsedTime: elapsedTime)
        }
        saveData()
    }
    
    func deleteAllSignIns() {
        signIns.removeAll()
        saveData()
    }
    
    func deleteAllSessions() {
        sessions.removeAll()
        saveData()
    }
    
    func isUserLoggedIn(email: String) -> Bool {
        var person = signIns.first(where: { $0.email == email })
        if person == nil {
            return false
        } else {
            return true
        }
    }
    
    
    func findPersonWith(email: String) -> Person? {
        var person = people.first(where: { $0.email == email })
        
        if person == nil {  // search by username
            let split = email.split(separator: "@")
            let username = String(split.first ?? "error")
            person = people.first(where: { $0.username == username })
        }
        
        if person == nil {
            return nil
        }
        
        return person
    }
    
    
    // Sign In Filtering
    func addSignInFilter(location: String) {
        signInFilters.append(location)
        applySignInFilters()
    }
    
    func removeSignInFilter(location: String) {
        signInFilters.removeAll(where: {$0 == location})
        applySignInFilters()
    }
    
    func removeAllSignInFilters() {
        signInFilters.removeAll()
        applySignInFilters()
    }
    
    func applySignInFilters() {
        // Leave the filter funtion if there are no filters.
        if signInFilters.isEmpty {
            DispatchQueue.main.async {
                self.filteredSignIns = self.signIns
            }
            
            return
        }
        // Create a copy of the people array
        let peopleArray = signIns
        
        let filtered = peopleArray.filter({signInFilters.contains($0.campus)})
        
        DispatchQueue.main.async {
            self.filteredSignIns = filtered
        }
        
        
    }
    
    // Session Filtering
    func addSessionsFilter(location: String) {
        sessionFilters.append(location)
        applySessionsFilters()
    }
    
    func removeSessionsFilter(location: String) {
        sessionFilters.removeAll(where: {$0 == location})
        applySessionsFilters()
    }
    
    func removeAllSessionsFilters() {
        sessionFilters.removeAll()
        applySessionsFilters()
    }
    
    func applySessionsFilters() {
        // Leave the filter funtion if there are no filters.
        if sessionFilters.isEmpty {
            DispatchQueue.main.async {
                self.filteredSessions = self.sessions
            }
            
            return
        }
        // Create a copy of the people array
        let sessionArray = sessions
        
        let filtered = sessionArray.filter({sessionFilters.contains($0.person.campus)})
        
        DispatchQueue.main.async {
            self.filteredSessions = filtered
        }
        
        
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
