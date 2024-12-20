import SwiftUI
import UIKit // Add this import

public struct AddZikirView: View {
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State private var description = ""
    @State private var targetCount: Int = 0
    let onAdd: (String, String, Int) -> Void
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium) // Add this line
    
    public var body: some View {
        NavigationView {
            Form {
                TextField("Zikir Adı", text: $name)
                TextField("Açıklama", text: $description)
                TextField("Hedef Sayaç", text: Binding(
                        get: { String(targetCount) }, // Convert Int to String for TextField
                        set: { targetCount = Int($0) ?? 0 } // Convert String to Int, default to 0 if invalid
                    ))
                    .keyboardType(.numberPad)
            }
            .navigationTitle("Yeni Zikir Ekle")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Vazgeç") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kaydet") {
                        onAdd(name, description, targetCount)
                        feedbackGenerator.impactOccurred() // Add this line
                        dismiss()
                    }
                    .disabled(name.isEmpty || targetCount <= 0)
                }
            }
        }
    }
}

#Preview {
    AddZikirView { name, description, count in
        // Preview callback - no implementation needed
        print("Name: \(name), Description: \(description), Count: \(count)")
    }
}
