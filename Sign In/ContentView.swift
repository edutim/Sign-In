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
                Text("Entries")
                Divider()
                List {
                    ForEach(ds.people, id:\.id ) { item in
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
                
                Button("Delete Users") {
                    showDeleteAlert = true
                }
                .alert("Are you sureyou want to delete all the entries?", isPresented: $showDeleteAlert) {
                    Button("Nope", role: .cancel, action: {})
                    Button("Delete", role: .destructive, action: {
                        DataService.shared.removeAll()
                    })
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
                Button("Export Activity Log as CSV") {
                    var csv = DataService.shared.generateLogReportAsCSV()
                    let panel = NSSavePanel()
                    panel.allowedContentTypes = [.commaSeparatedText]
                    panel.isExtensionHidden = false
                    panel.nameFieldStringValue = "activityLog.csv"
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
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
