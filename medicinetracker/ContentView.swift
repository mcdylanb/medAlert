import SwiftUI


// First, let's create a Medicine model to manage the state
struct Medicine: Identifiable {
    let id = UUID()
    let name: String
    let dosage: String
    let time: String
    let date: Date
    var isCompleted: Bool = false
    
    // Computed property to convert time string to Date
    var intakeTime: Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mma" // Format for "12:00pm"
        return dateFormatter.date(from: time) ?? Date()
    }
}

// Modify MedicineView to accept a Medicine object and handle completion
struct MedicineView: View {
    let medicine: Medicine
    let onComplete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack{
                Text(medicine.name)
                    .font(.title)
                    .foregroundColor(medicine.isCompleted ? .gray : .primary)
                Text(medicine.dosage)
                    .font(.subheadline)
                Spacer()
                Text(medicine.time)
                    .font(.title)
                
            }
            
        }
        .padding()
        .overlay( // Adding bottom border
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color.gray.opacity(0.3))
            , alignment: .bottom
        ).swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button {
                onComplete()
            } label: {
                Label("Complete", systemImage: "checkmark.circle.fill")
            }
            .tint(.green)
        }
        .background(Color(.systemBackground))
    }
}

// Update ContentView to manage a list of medicines
struct ContentView: View {
    @State private var medicines: [Medicine] = [
        Medicine(name: "Bioflu", dosage: "15mg", time: "12:00pm", date: Date()),
        Medicine(name: "Vitamin C", dosage: "500mg", time: "9:00am", date: Date()),
        Medicine(name: "Aspirin", dosage: "81mg", time: "8:00pm", date: Date()),
        Medicine(name: "Bioflu", dosage: "15mg", time: "12:00pm", date: Date().addingTimeInterval(-86400)), // Previous day
        Medicine(name: "Bioflu", dosage: "15mg", time: "12:00pm", date: Date().addingTimeInterval(86400)), // Next day
        Medicine(name: "Bioflu", dosage: "15mg", time: "12:00pm", date: Date().addingTimeInterval(860)), 
    ]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(medicines
                    .filter { Calendar.current.isDate($0.date, inSameDayAs: Date()) }
                    .sorted(by: { $0.intakeTime < $1.intakeTime }) // Sort by intake time
                ) { medicine in
                    MedicineView(medicine: medicine) {
                        if let index = medicines.firstIndex(where: { $0.id == medicine.id }) {
                            medicines[index].isCompleted.toggle()
                        }
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                }
            }
            .listStyle(.plain)
            .navigationTitle("Today's Medicines")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
