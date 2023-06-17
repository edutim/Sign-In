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
    @State private var allFilter = true
    @State private var allendaleFilter = false
    @State private var lancasterFilter = false
    @State private var sumterFilter = false
    @State private var walterboroFilter = false
    @State private var unionFilter = false
    
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
                            Toggle("Show All", isOn: $allFilter)
                                .toggleStyle(.button)
                                .onChange(of: allFilter) { value in
                                    if value {
                                        DataService.shared.removeAllSignInFilters()
                                        resetFilters()
                                    } else {
                                        DataService.shared.removeSignInFilter(location: "Allendale")
                                    }
                                }
                            Toggle("Allendale", isOn: $allendaleFilter)
                                .toggleStyle(.button)
                                .onChange(of: allendaleFilter) { value in
                                    if value {
                                        allFilter = false
                                        DataService.shared.addSignInFilter(location: "Allendale")
                                    } else {
                                        DataService.shared.removeSignInFilter(location: "Allendale")
                                    }
                                }
                            Toggle("Lancaster", isOn: $lancasterFilter)
                                .toggleStyle(.button)
                                .onChange(of: lancasterFilter) { value in
                                    if value {
                                        allFilter = false
                                        DataService.shared.addSignInFilter(location: "Lancaster")
                                    } else {
                                        DataService.shared.removeSignInFilter(location: "Lancaster")
                                    }
                                }
                            Toggle("Sumter", isOn: $sumterFilter)
                                .toggleStyle(.button)
                                .onChange(of: sumterFilter) { value in
                                    if value {
                                        allFilter = false
                                        DataService.shared.addSignInFilter(location: "Sumter")
                                    } else {
                                        DataService.shared.removeSignInFilter(location: "Sumter")
                                    }
                                }
                            Toggle("Walterboro", isOn: $walterboroFilter)
                                .toggleStyle(.button)
                                .onChange(of: walterboroFilter) { value in
                                    if value {
                                        allFilter = false
                                        DataService.shared.addSignInFilter(location: "Walterboro")
                                    } else {
                                        DataService.shared.removeSignInFilter(location: "Walterboro")
                                    }
                                }
                            Toggle("Union", isOn: $unionFilter)
                                .toggleStyle(.button)
                                .onChange(of: unionFilter) { value in
                                    if value {
                                        allFilter = false
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
                }
                VStack {
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
                Text("Log")
                Divider()
                List {
                    ForEach(ds.sessions, id:\.id ) { session in
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
    
    func resetFilters() {
        allFilter = true
        allendaleFilter = false
        lancasterFilter = false
        sumterFilter = false
        walterboroFilter = false
        unionFilter = false
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
