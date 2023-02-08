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
        people.append(person)
        saveData()
    }
    
    func removeAll() {
        people.removeAll()
        saveData()
    }
    
    func findPersonWith(email: String) -> Person? {
        let person = people.first(where: { $0.email == email })
        
        if person == nil {
            return nil
        } else {
            return person
        }
    }
    
    // CSV Stuff
    
    let dateFormatter: DateFormatter = {
          let formatter = DateFormatter()
          formatter.dateStyle = .long
          return formatter
    }()
    
    func generateLogReportAsCSV() -> String {
        var data = "firstName,lastName,email,role,reason,date,time\n"
        for person in people {
            let row = "\(person.firstName),\(person.lastName),\(person.email),\(person.role),\(person.reasonForVisit),\(person.date.formatted(date: .numeric, time: .omitted)),\(person.date.formatted(date: .omitted, time: .shortened))\n"
            data.append(row)
        }
        print(data)
        return data
    }

    
}
