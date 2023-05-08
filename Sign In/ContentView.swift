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
                    Label("Server", image: "person")
                }
                .toggleStyle(.switch)
                .onChange(of: serverStatus) { status in
                    if serverStatus {
                        server.start()
                    } else {
                        server.stop()
                    }
                }
                Divider()
                Text("The server should be available at the ip address of the computer on port 8181. Example: http://172.1.1.1:8181")
                Text("You can test the server status at http://ipaddess:8181/test")
//                Button("Debug") {
//                    print(DataService.shared.people)
//                }
                Spacer()
            }
            .frame(width: 200)
            Divider()
                .padding()
            VStack {
                Text("Signed In")
                Divider()
                List {
                    ForEach(ds.signIns, id:\.id ) { item in
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
                        Button("Delete", role: .destructive, action: {
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
                    
                }
                Spacer()
            }
            .frame(width: 200)
            Divider()
                .padding()
            VStack {
                Text("Export")
                Divider()
                Spacer()
//                Button("Export Activity Log as CSV") {
//                    var csv = DataService.shared.generateLogReportAsCSV()
//                    let panel = NSSavePanel()
//                    panel.allowedContentTypes = [.commaSeparatedText]
//                    panel.isExtensionHidden = false
//                    panel.nameFieldStringValue = "activityLog.csv"
//                    panel.begin { result in
//                        if result == .OK {
//                            guard let url = panel.url else { return }
//                            do {
//                                //write file
//                                let data = csv.data(using: .utf8)
//                                try data?.write(to: url)
//                            } catch {
//                                print(error.localizedDescription)
//                            }
//                        }
//                    }
//                }
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
                //.buttonStyle(.borderedProminent)
                
                
                Spacer()
                    
            }
            .frame(width: 200)
                
            
        }
        .padding()
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
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
