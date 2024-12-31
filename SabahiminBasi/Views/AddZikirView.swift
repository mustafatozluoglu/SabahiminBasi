import SwiftUI
import UIKit

public struct AddZikirView: View {
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State private var description = ""
    @State private var targetCount: String = ""
    let onAdd: (String, String, Int) -> Void
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    
    public var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField(LocalizedStringKey("enter_dhikr_name"), text: $name, axis: .vertical)
                    .lineLimit(1...6)
                    .textInputAutocapitalization(.sentences)
                    TextField(LocalizedStringKey("enter_description"), text: $description, axis: .vertical)
                        .lineLimit(1...6)
                        .textInputAutocapitalization(.sentences)
                    TextField(LocalizedStringKey("enter_target"), text: $targetCount)
                        .keyboardType(.numberPad)
                }
            }
            .navigationTitle(LocalizedStringKey("new_dhikr"))
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(LocalizedStringKey("cancel")) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(LocalizedStringKey("save")) {
                        onAdd(name, description, Int(targetCount) ?? 0)
                        feedbackGenerator.impactOccurred()
                        dismiss()
                    }
                    .disabled(name.isEmpty || targetCount.isEmpty)
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
