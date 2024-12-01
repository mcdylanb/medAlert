//
//  AddMedicineView.swift
//  medicinetracker
//
//  Created by Dylan Balagtas on 11/21/24.
//

import SwiftUI
import UserNotifications

struct AddMedicineView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var medicines: [Medicine]
    
    @State private var name: String = ""
    @State private var dosage: String = ""
    @State private var time: Date = Date()
    @State private var date: Date = Date()
    @State private var showAlert: Bool = false
    @State private var errorMessage: String = ""
    
    // State variables to track highlighting
    @State private var highlightName: Bool = false
    @State private var highlightDosage: Bool = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Medicine Details")) {
                    TextField("Name", text: $name)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(highlightName ? Color.red : Color.gray, lineWidth: 1)
                        )
                        .foregroundColor(highlightName ? Color.red : Color.primary)
                    
                    TextField("Dosage", text: $dosage)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(highlightDosage ? Color.red : Color.gray, lineWidth: 1)
                        )
                        .foregroundColor(highlightDosage ? Color.red : Color.primary)
                    
                    DatePicker("Time", selection: $time, displayedComponents: .hourAndMinute)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }
                
                Button("Add Medicine") {
                    // Reset highlighting
                    highlightName = false
                    highlightDosage = false
                    
                    if name.isEmpty || dosage.isEmpty {
                        errorMessage = "Please fill in all fields."
                        showAlert = true
                        
                        // Set highlighting for empty fields
                        if name.isEmpty {
                            highlightName = true
                        }
                        if dosage.isEmpty {
                            highlightDosage = true
                        }
                    } else {
                        let newMedicine = Medicine(name: name, dosage: dosage, time: time, date: date)
                        medicines.append(newMedicine)
                        scheduleNotification(for: newMedicine)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Input Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
                }
            }
            .navigationTitle("Add New Medicine")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    private func scheduleNotification(for medicine: Medicine) {
        let content = UNMutableNotificationContent()
        content.title = "Time to take your medicine!"
        content.body = "\(medicine.name) - \(medicine.dosage)"
        content.sound = .default
        
        var dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: medicine.date)
        dateComponents.hour = Calendar.current.component(.hour, from: medicine.time)
        dateComponents.minute = Calendar.current.component(.minute, from: medicine.time)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let request = UNNotificationRequest(identifier: medicine.id.uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
}

