import SwiftUI

public struct AddZikirView: View {
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State private var description = ""
    @State private var targetCount: Int = 0
    let onAdd: (String, String, Int) -> Void
    
    public var body: some View {
        NavigationView {
            Form {
                TextField("Zikir Name", text: $name)
                TextField("Description", text: $description)
                TextField("Target Count", text: Binding(
                        get: { String(targetCount) }, // Convert Int to String for TextField
                        set: { targetCount = Int($0) ?? 0 } // Convert String to Int, default to 0 if invalid
                    ))
                    .keyboardType(.numberPad)
            }
            .navigationTitle("Add New Zikir")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        onAdd(name, description, targetCount)
                        
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}
