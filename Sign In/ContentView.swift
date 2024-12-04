//
//  ContentView.swift
//  Sign In
//
//  Created by Timothy Hart on 2/7/23.
//

import SwiftUI

struct ContentView: View {
    
    @State var serverStatus = false
    @StateObject var server = Server(port: 8181)
    
    @EnvironmentObject var ds: DataService
    
    @State var showDeleteAlert = false
    @State var showSignOutAllAlert = false
    @State var showDeleteAllSessionsAlert = false
    
    @State private var showingExporter = false
    
    @State private var address = ""
    
    @State private var showSignedInFilter = false
    @State private var allSignInFilter = true
    @State private var allendaleSignInFilter = false
    @State private var lancasterSignInFilter = false
    @State private var sumterSignInFilter = false
    @State private var walterboroSignInFilter = false
    @State private var unionSignInFilter = false
    
    @State private var showSessionsFilter = false
    @State private var allSessionsFilter = true
    @State private var allendaleSessionsFilter = false
    @State private var lancasterSessionsFilter = false
    @State private var sumterSessionsFilter = false
    @State private var walterboroSessionsFilter = false
    @State private var unionSessionsFilter = false
    
    let dateFormatter: DateFormatter = {
          let formatter = DateFormatter()
          formatter.dateStyle = .long
          formatter.timeStyle = .short
          return formatter
    }()
    
    var body: some View {
        HStack {
            VStack {
                Text("Server")
                Divider()
                Toggle(isOn: $serverStatus) {
                    Label("Status", image: "person")
                }
                .toggleStyle(.switch)
                .padding()
                .onChange(of: serverStatus) { status in
                    if serverStatus {
                        server.start()
                    } else {
                        server.stop()
                    }
                }
                Divider()
                Text("Available at: http://\(address)")
                    .padding(.bottom)
                Text("You can test the server status at http://\(address)/test")
                
//                Button("Debug") {
//                    DataService.shared.debug()
//                }
                Spacer()
            }
            .frame(width: 200)
            Divider()
                .padding()
            VStack {
                HStack {
                    Text("Signed In")
                    Spacer()
                    Button {
                        showSignedInFilter = true
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                    .popover(isPresented:$showSignedInFilter) {
                        VStack {
                            Toggle("Show All", isOn: $allSignInFilter)
                                .toggleStyle(.button)
                                .onChange(of: allSignInFilter) { value in
                                    if value {
                                        DataService.shared.removeAllSignInFilters()
                                        resetSignInsFilters()
                                    } else {
                                        DataService.shared.removeSignInFilter(location: "Allendale")
                                    }
                                }
                            Toggle("Allendale", isOn: $allendaleSignInFilter)
                                .toggleStyle(.button)
                                .onChange(of: allendaleSignInFilter) { value in
                                    if value {
                                        allSignInFilter = false
                                        DataService.shared.addSignInFilter(location: "Allendale")
                                    } else {
                                        DataService.shared.removeSignInFilter(location: "Allendale")
                                    }
                                }
                            Toggle("Lancaster", isOn: $lancasterSignInFilter)
                                .toggleStyle(.button)
                                .onChange(of: lancasterSignInFilter) { value in
                                    if value {
                                        allSignInFilter = false
                                        DataService.shared.addSignInFilter(location: "Lancaster")
                                    } else {
                                        DataService.shared.removeSignInFilter(location: "Lancaster")
                                    }
                                }
                            Toggle("Sumter", isOn: $sumterSignInFilter)
                                .toggleStyle(.button)
                                .onChange(of: sumterSignInFilter) { value in
                                    if value {
                                        allSignInFilter = false
                                        DataService.shared.addSignInFilter(location: "Sumter")
                                    } else {
                                        DataService.shared.removeSignInFilter(location: "Sumter")
                                    }
                                }
                            Toggle("Walterboro", isOn: $walterboroSignInFilter)
                                .toggleStyle(.button)
                                .onChange(of: walterboroSignInFilter) { value in
                                    if value {
                                        allSignInFilter = false
                                        DataService.shared.addSignInFilter(location: "Walterboro")
                                    } else {
                                        DataService.shared.removeSignInFilter(location: "Walterboro")
                                    }
                                }
                            Toggle("Union", isOn: $unionSignInFilter)
                                .toggleStyle(.button)
                                .onChange(of: unionSignInFilter) { value in
                                    if value {
                                        allSignInFilter = false
                                        DataService.shared.addSignInFilter(location: "Union")
                                    } else {
                                        DataService.shared.removeSignInFilter(location: "Union")
                                    }
                                }
                           
                        }
                        .padding()
                    }
                }
                Divider()
            
                List {
                    ForEach(ds.filteredSignIns, id:\.id ) { item in
                        VStack(alignment: .leading) {
                            HStack {
                                Text(item.firstName)
                                Text(item.lastName)
                            }
                            Text(item.email)
                                .font(.caption)
                                .tint(.secondary)
                            Text((item.role))
                                .font(.caption)
                                .tint(.secondary)
                            Text("Reason: \(item.reasonForVisit)")
                                .font(.caption)
                                .tint(.secondary)
                            Text("Location: \(item.campus)")
                                .font(.caption)
                                .tint(.secondary)
                            Text("Time: \(item.date, formatter: dateFormatter)")
                                .font(.caption)
                                .tint(.secondary)
                            Divider()
                            
                        }
                    }
                    .onDelete { offsets in
                        if let person = offsets.map { ds.signIns[$0] }.first {
                            let signOutDate = Date()
                            
                            let email = person.email
                            
                            let allPersonEntries = DataService.shared.signIns.filter({
                                $0.email == email
                            })
                            
                            let allLogIns = allPersonEntries.filter({
                                $0.type == "signIn"
                            })
                            
                            if let lastSignInPerson = allLogIns.max(by: {
                                $0.date < $1.date }) {
                                
                                
                                let elapsedTime = lastSignInPerson.date - signOutDate
                                
                                
                                ds.signOut(person: person, elapsedTime: elapsedTime)
                            }
                        }
                        
                    }
                }
                
                VStack {
                    Text("#: \(ds.filteredSignIns.count)")
                    Button("Delete All") {
                        showDeleteAlert = true
                    }
                    .alert("Are you sure you want to delete all the sign ins?", isPresented: $showDeleteAlert) {
                        Button("Nope", role: .cancel, action: {})
                        Button("Delete", role: .destructive, action: {
                            DataService.shared.deleteAllSignIns()
                        })
                    }
                    Button("Sign Out All") {
                        showSignOutAllAlert = true
                    }
                    .alert("Are you sure you want to sign out all the entries?", isPresented: $showSignOutAllAlert) {
                        Button("Nope", role: .cancel, action: {})
                        Button("Sign Out", role: .destructive, action: {
                            DataService.shared.signOutAll()
                        })
                    }
                }
                Spacer()
            }
            .frame(width: 200)
            VStack {
                HStack {
                    Text("Session Log")
                    Spacer()
                    Button {
                        showSessionsFilter = true
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                    .popover(isPresented:$showSessionsFilter) {
                        VStack {
                            Toggle("Show All", isOn: $allSessionsFilter)
                                .toggleStyle(.button)
                                .onChange(of: allSessionsFilter) { value in
                                    if value {
                                        DataService.shared.removeAllSessionsFilters()
                                        resetSessionsFilters()
                                    } else {
                                        DataService.shared.removeSessionsFilter(location: "Allendale")
                                    }
                                }
                            Toggle("Allendale", isOn: $allendaleSessionsFilter)
                                .toggleStyle(.button)
                                .onChange(of: allendaleSessionsFilter) { value in
                                    if value {
                                        allSessionsFilter = false
                                        DataService.shared.addSessionsFilter(location: "Allendale")
                                    } else {
                                        DataService.shared.removeSessionsFilter(location: "Allendale")
                                    }
                                }
                            Toggle("Lancaster", isOn: $lancasterSessionsFilter)
                                .toggleStyle(.button)
                                .onChange(of: lancasterSessionsFilter) { value in
                                    if value {
                                        allSessionsFilter = false
                                        DataService.shared.addSessionsFilter(location: "Lancaster")
                                    } else {
                                        DataService.shared.removeSessionsFilter(location: "Lancaster")
                                    }
                                }
                            Toggle("Sumter", isOn: $sumterSessionsFilter)
                                .toggleStyle(.button)
                                .onChange(of: sumterSessionsFilter) { value in
                                    if value {
                                        allSessionsFilter = false
                                        DataService.shared.addSessionsFilter(location: "Sumter")
                                    } else {
                                        DataService.shared.removeSessionsFilter(location: "Sumter")
                                    }
                                }
                            Toggle("Walterboro", isOn: $walterboroSessionsFilter)
                                .toggleStyle(.button)
                                .onChange(of: walterboroSessionsFilter) { value in
                                    if value {
                                        allSessionsFilter = false
                                        DataService.shared.addSessionsFilter(location: "Walterboro")
                                    } else {
                                        DataService.shared.removeSessionsFilter(location: "Walterboro")
                                    }
                                }
                            Toggle("Union", isOn: $unionSessionsFilter)
                                .toggleStyle(.button)
                                .onChange(of: unionSessionsFilter) { value in
                                    if value {
                                        allSessionsFilter = false
                                        DataService.shared.addSessionsFilter(location: "Union")
                                    } else {
                                        DataService.shared.removeSessionsFilter(location: "Union")
                                    }
                                }
                           
                        }
                        .padding()
                    }
                }

                Divider()
                List {
                    ForEach(ds.filteredSessions, id:\.id ) { session in
                        VStack(alignment: .leading) {
                            HStack {
                                Text(session.person.firstName)
                                Text(session.person.lastName)
                            }
                            Text(session.person.email)
                                .font(.caption)
                                .tint(.secondary)
                            Text((session.person.role))
                                .font(.caption)
                                .tint(.secondary)
                            Text("Reason: \(session.person.reasonForVisit)")
                                .font(.caption)
                                .tint(.secondary)
                            Text("Location: \(session.person.campus)")
                                .font(.caption)
                                .tint(.secondary)
                            Text(session.person.date)
                                .font(.caption)
                                .tint(.secondary)
                            Text("Time: \(formattedElapsedTime(time: session.time))")
                                .font(.caption)
                                .tint(.secondary)
                            Divider()
                            
                        }
                    }
                }
                VStack {
                    Button("Delete All") {
                        showDeleteAllSessionsAlert = true
                    }
                    .alert("Are you sure you want to delete all the sessions?", isPresented: $showDeleteAllSessionsAlert) {
                        Button("Nope", role: .cancel, action: {})
                        Button("Delete", role: .destructive, action: {
                            print("did it work?")
                            DataService.shared.deleteAllSessions()
                        })
                    }
                    Button("Export Session Log as CSV") {
                        var csv = DataService.shared.generateSessionsReportAsCSV()
                        let panel = NSSavePanel()
                        panel.allowedContentTypes = [.commaSeparatedText]
                        panel.isExtensionHidden = false
                        panel.nameFieldStringValue = "sessionsLog.csv"
                        panel.begin { result in
                            if result == .OK {
                                guard let url = panel.url else { return }
                                do {
                                    //write file
                                    let data = csv.data(using: .utf8)
                                    try data?.write(to: url)
                                } catch {
                                    print(error.localizedDescription)
                                }
                            }
                        }
                    }
                    
                }
                Spacer()
            }
            .frame(width: 200)
            
                
            
        }
        .padding()
        .task {
            setServerAddress()
        }
    }
    
    func resetSignInsFilters() {
        allSignInFilter = true
        allendaleSignInFilter = false
        lancasterSignInFilter = false
        sumterSignInFilter = false
        walterboroSignInFilter = false
        unionSignInFilter = false
    }
    
    func resetSessionsFilters() {
        allSessionsFilter = true
        allendaleSessionsFilter = false
        lancasterSessionsFilter = false
        sumterSessionsFilter = false
        walterboroSessionsFilter = false
        unionSessionsFilter = false
    }
    
    func formattedElapsedTime(time: TimeInterval) -> String {
        
        let timeInterval: TimeInterval = abs(time)
        
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.allowedUnits = [.hour, .minute]
        
        if let formattedString = formatter.string(from: timeInterval) {
            return formattedString
        } else {
            return "error"
        }
        
    }
    
    func setServerAddress() {
        var hostname = Host.current().localizedName
        hostname?.append(contentsOf: ":8181")
        address = hostname?.replacingOccurrences(of: " ", with: "-") ?? "unknown"
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
