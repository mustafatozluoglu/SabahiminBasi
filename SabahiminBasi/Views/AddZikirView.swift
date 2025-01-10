import SwiftUI
import UIKit

public struct AddZikirView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @State private var name = ""
    @State private var description = ""
    @State private var targetCount: String = ""
    @State private var selectedCategory: ZikirCategory?
    let onAdd: (String, String, Int) -> Void
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    
    @FetchRequest(
        entity: ZikirCategory.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \ZikirCategory.createdAt, ascending: true)]
    ) private var categories: FetchedResults<ZikirCategory>
    
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
                
                Section(header: Text(LocalizedStringKey("category"))) {
                    Picker(LocalizedStringKey("select_category"), selection: $selectedCategory) {
                        Text(LocalizedStringKey("no_category"))
                            .tag(nil as ZikirCategory?)
                        ForEach(categories) { category in
                            HStack {
                                Image(systemName: category.icon)
                                Text(category.name)
                            }
                            .tag(category as ZikirCategory?)
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(LocalizedStringKey("cancel")) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(LocalizedStringKey("save")) {
                        let newZikir = Zikir(context: viewContext)
                        newZikir.id = UUID()
                        newZikir.name = name
                        newZikir.zikirDescription = description
                        newZikir.targetCount = Int32(targetCount) ?? 0
                        newZikir.count = 0
                        newZikir.completions = 0
                        newZikir.createdAt = Date()
                        newZikir.category = selectedCategory
                        
                        do {
                            try viewContext.save()
                            feedbackGenerator.impactOccurred()
                            dismiss()
                        } catch {
                            print("Error saving zikir: \(error)")
                        }
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
