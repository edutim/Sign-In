//
//  DataService.swift
//  Sign In
//
//  Created by Timothy Hart on 2/7/23.
//

import Foundation

class DataService : ObservableObject {
    static var shared = DataService()
    
    @Published var people = [Person]() {
        didSet {
            saveData()
        }
    }
    
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
                people = decoded
                return
            }
        }
        
    }
    
    func saveData() {
        
        var encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        if let encoded = try? encoder.encode(people) {
            UserDefaults.standard.set(encoded, forKey: "people")
            print("Saved People")
        } else {
            print("Soemthing went wrong")
        }
    }
    
    func addPerson(person: Person) {
        DispatchQueue.main.sync {
            people.append(person)
            saveData()
        }
        
    }
    
    func removeAll() {
        people.removeAll()
        saveData()
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
    
    // CSV Stuff
    
    let dateFormatter: DateFormatter = {
          let formatter = DateFormatter()
          formatter.dateStyle = .long
          return formatter
    }()
    
    func generateLogReportAsCSV() -> String {
        var data = "firstName,lastName,email,role,reason,campus,type,date,time\n"
        for person in people {
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
