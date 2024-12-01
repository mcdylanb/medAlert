import SwiftUI
import UserNotifications


// First, let's create a Medicine model to manage the state
struct Medicine: Identifiable {
    let id = UUID()
    let name: String
    let dosage: String
    let time: Date
    let date: Date
    var isCompleted: Bool = false
    
    // Computed property to format time for display
    var formattedTime: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mma" // Format for "12:00pm"
        return dateFormatter.string(from: time)
    }
}

// Modify MedicineView to accept a Medicine object and handle completion
struct MedicineView: View {
    let medicine: Medicine
    let onComplete: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(medicine.name)
                    .font(.title)
                    .foregroundColor(medicine.isCompleted ? .gray : .primary)
                Text(medicine.dosage)
                    .font(.subheadline)
                    .foregroundColor(medicine.isCompleted ? .gray : .primary)
                Spacer()
                Text(medicine.formattedTime)
                    .font(.title)
                    .foregroundColor(medicine.isCompleted ? .gray : .primary)
            }
        }
        .padding()
        .overlay( // Adding bottom border
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color.gray.opacity(0.3)),
            alignment: .bottom
        )
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button {
                onComplete() // Mark as done
            } label: {
                Label("Done", systemImage: "checkmark.circle.fill")
            }
            .tint(.green) // Color for the done action
        }
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
            Button {
                onDelete() // Delete action
            } label: {
                Label("Delete", systemImage: "trash")
            }
            .tint(.red) // Color for the delete action
        }
        .background(Color(.systemBackground))
        .animation(.easeInOut, value: medicine.isCompleted)
    }
}

// Update ContentView to manage a list of medicines
struct ContentView: View {
    @State private var medicines: [Medicine] = [
        Medicine(name: "Bioflu", dosage: "15mg", time: Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: Date())!, date: Date()),
        Medicine(name: "Vitamin C", dosage: "500mg", time: Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date())!, date: Date()),
        Medicine(name: "Aspirin", dosage: "81mg", time: Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: Date())!, date: Date()),
        Medicine(name: "Pain Reliever", dosage: "500mg", time: Calendar.current.date(bySettingHour: 6, minute: 0, second: 0, of: Date())!, date: Date()),
        Medicine(name: "Allergy Medication", dosage: "10mg", time: Calendar.current.date(bySettingHour: 15, minute: 0, second: 0, of: Date())!, date: Date()),
        Medicine(name: "Vitamins", dosage: "1000mg", time: Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date())!, date: Date()),
    ]
    
    @State private var showingAddMedicine = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(medicines
                    .filter { Calendar.current.isDate($0.date, inSameDayAs: Date()) }
                    .sorted {
                        if $0.isCompleted == $1.isCompleted {
                            return $0.time < $1.time
                        }
                        return !$0.isCompleted
                    }
                ) { medicine in
                    MedicineView(medicine: medicine, onComplete: {
                        if let index = medicines.firstIndex(where: { $0.id == medicine.id }) {
                            medicines[index].isCompleted.toggle()
                        }
                    }, onDelete: {
                        if let index = medicines.firstIndex(where: { $0.id == medicine.id }) {
                            medicines.remove(at: index)
                        }
                    })
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                }
            }
            .listStyle(.plain)
            .navigationTitle("Today's Medicines")
            .navigationBarItems(trailing: Button(action: {
                showingAddMedicine.toggle()
            }) {
                Image(systemName: "plus")
            })
            .sheet(isPresented: $showingAddMedicine) {
                AddMedicineView(medicines: $medicines)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

