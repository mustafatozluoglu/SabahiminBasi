import SwiftUI

struct ZikirDetailView: View {
    @StateObject var viewModel: ZikirDetailViewModel
    @State private var showingTargetEdit = false
    @State private var newTarget = ""
    @State private var showingEditZikir = false
    @State private var editedName = ""
    @State private var editedDescription = ""
    @State private var editedTargetCount: Int32 = 0
    @AppStorage("hapticFeedbackEnabled") private var hapticFeedbackEnabled: Bool = true
    @AppStorage("timerInterval") private var timerInterval: Double = 1.0
    @AppStorage("timerEnabled") private var timerEnabled: Bool = false
    private let feedbackCounterGenerator = UIImpactFeedbackGenerator(style: .light)
    private let feedbackCompleteGenerator = UIImpactFeedbackGenerator(style: .heavy)
    @State private var timer: Timer? = nil
    
    init(viewModel: ZikirDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Title
                titleSection
                
                // Counter Section
                counterSection
                
                // Counter Button
                counterButton
                
                // Reset Button
                resetButton
                
                // Progress Bar
                progressSection
                
                // Edit Button
                editButton
            }
            .padding(.vertical)
        }
      //  .navigationTitle(LocalizedStringKey("zikir_detail"))
        .navigationBarItems(trailing: 
            Button(action: {
                viewModel.toggleFavorite()
                if hapticFeedbackEnabled {
                    feedbackCounterGenerator.impactOccurred()
                }
            }) {
                Image(systemName: viewModel.zikir.favorite ? "star.fill" : "star")
                    .foregroundColor(.yellow)
                    .font(.system(size: 18))
            }
        )
        .sheet(isPresented: $showingTargetEdit) {
            editTargetSheet
        }
        .sheet(isPresented: $showingEditZikir) {
            editZikirSheet
        }
        .onDisappear {
            timer?.invalidate()
            timer = nil
        }
    }
    
    private var titleSection: some View {
        VStack {
            Text(viewModel.zikir.name)
                .font(.system(size: 20, weight: .heavy))
                .lineLimit(nil)
                .multilineTextAlignment(.leading)
            
            Text(viewModel.zikir.zikirDescription)
                .font(.system(size: 12, weight: .heavy))
                .foregroundColor(.gray)
                .lineLimit(nil)
                .multilineTextAlignment(.leading)
        }
    }
    
    private var counterSection: some View {
        VStack(spacing: 6) {
            Text("\(viewModel.zikir.count)")
                .font(.system(size: 64, weight: .bold))
            
            Text(String(format: String(localized: "target_count_format"), viewModel.zikir.targetCount))
                .foregroundColor(.gray)
                .font(.system(size: 18, weight: .heavy))
                .onTapGesture {
                    showingTargetEdit = true
                }
            
            Text(String(format: String(localized: "completions_format"), viewModel.zikir.completions))
                .foregroundColor(.green)
                .font(.system(size: 12, weight: .heavy))
        }
    }
    
    private var counterButton: some View {
        Button(action: {
            viewModel.incrementCount()
            if hapticFeedbackEnabled {
                feedbackCounterGenerator.impactOccurred()
            }
        }) {
            Circle()
                .fill(Color.orange)
                .frame(width: 200, height: 200)
                .overlay(
                    Text(LocalizedStringKey("counter"))
                        .foregroundColor(.white)
                        .font(.title2)
                )
        }
        .onAppear {
            if timerEnabled {
                timer = Timer.scheduledTimer(withTimeInterval: timerInterval, repeats: true) { _ in
                    viewModel.incrementCount()
                    if hapticFeedbackEnabled {
                        feedbackCounterGenerator.impactOccurred()
                    }
                }
            }
        }
    }
    
    private var resetButton: some View {
        Button(LocalizedStringKey("reset")) {
            viewModel.resetCount()
            if hapticFeedbackEnabled {
                feedbackCompleteGenerator.impactOccurred()
            }
        }
        .padding()
    }
    
    private var progressSection: some View {
        ProgressView(
            value: Double(viewModel.zikir.count),
            total: Double(viewModel.zikir.targetCount)
        )
        .padding(.horizontal)
    }
    
    private var editButton: some View {
        Button(action: {
            editedName = viewModel.zikir.name
            editedDescription = viewModel.zikir.zikirDescription
            editedTargetCount = viewModel.zikir.targetCount
            showingEditZikir = true
        }) {
            Label(LocalizedStringKey("edit"), systemImage: "pencil")
                .font(.system(size: 14, weight: .heavy))
        }
        .padding()
    }
    
    private var editTargetSheet: some View {
        NavigationView {
            Form {
                TextField(LocalizedStringKey("new_target"), text: $newTarget)
                    .keyboardType(.numberPad)
            }
            .navigationTitle(LocalizedStringKey("edit_target"))
            .navigationBarItems(
                leading: Button(LocalizedStringKey("cancel")) {
                    showingTargetEdit = false
                },
                trailing: Button(LocalizedStringKey("save")) {
                    if let target = Int32(newTarget) {
                        viewModel.updateTargetCount(target)
                    }
                    showingTargetEdit = false
                }
            )
        }
    }
    
    private var editZikirSheet: some View {
        NavigationView {
            Form {
                Section(header: Text(LocalizedStringKey("zikir_name"))) {
                    TextField(LocalizedStringKey("enter_zikir_name"), text: $editedName, axis: .vertical)
                        .lineLimit(1...6)
                        .textInputAutocapitalization(.sentences)
                }
                Section(header: Text(LocalizedStringKey("description"))) {
                    TextField(LocalizedStringKey("enter_description"), text: $editedDescription, axis: .vertical)
                        .lineLimit(1...6)
                        .textInputAutocapitalization(.sentences)
                }
                Section(header: Text(LocalizedStringKey("target"))) {
                    TextField(LocalizedStringKey("enter_target"), value: $editedTargetCount, format: .number)
                        .keyboardType(.numberPad)
                }
            }
            .navigationTitle(LocalizedStringKey("edit_zikir"))
            .navigationBarItems(
                leading: Button(LocalizedStringKey("cancel")) {
                    showingEditZikir = false
                },
                trailing: Button(LocalizedStringKey("save_changes")) {
                    viewModel.updateZikir(
                        name: editedName,
                        description: editedDescription,
                        targetCount: editedTargetCount
                    )
                    showingEditZikir = false
                }
            )
        }
    }
}
