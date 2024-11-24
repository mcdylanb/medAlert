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
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Medicine Details")) {
                    TextField("Name", text: $name)
                    TextField("Dosage", text: $dosage)
                    DatePicker("Time", selection: $time, displayedComponents: .hourAndMinute)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }
                
                
                Button(action: {
                    let newMedicine = Medicine(name: name, dosage: dosage, time: time, date: date)
                    medicines.append(newMedicine)
                    scheduleNotification(for: newMedicine)
                    presentationMode.wrappedValue.dismiss()                      }) {
                        Text("Add Medicine")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(height: 55)
                            .frame(maxWidth: .infinity)
                            .background(
                                LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]),
                                               startPoint: .leading,
                                               endPoint: .trailing)
                            )
                            .cornerRadius(10)
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
                    }
            }
            .navigationTitle("Add New Medicine")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    private func scheduleNotification(for medicine: Medicine) {
        let content = UNMutableNotificationContent()
        content.title = "Time to take your medicine!"
        content.body = "\(medicine.name) - \(medicine.dosage)"
        content.sound = .default
        
        // Create a date components object for the notification
        var dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: medicine.date)
        dateComponents.hour = Calendar.current.component(.hour, from: medicine.time)
        dateComponents.minute = Calendar.current.component(.minute, from: medicine.time)
        
        // Create a trigger for the notification
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        // Create a request for the notification
        let request = UNNotificationRequest(identifier: medicine.id.uuidString, content: content, trigger: trigger)
        
        // Schedule the notification
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
}

