import SwiftUI

public struct ZikirDetailView: View {
    @StateObject var viewModel: ZikirDetailViewModel
    @State private var showingTargetEdit = false
    @State private var newTarget = ""
    @State private var showingEditZikir = false
    @State private var editedName = ""
    @State private var editedDescription = ""
    @State private var editedTargetCount: Int = 0
    @AppStorage("hapticFeedbackEnabled") private var hapticFeedbackEnabled: Bool = true
    private let feedbackCounterGenerator = UIImpactFeedbackGenerator(style: .light)
    private let feedbackCompleteGenerator = UIImpactFeedbackGenerator(style: .heavy)
    
    public init(viewModel: ZikirDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        VStack(spacing: 20) {
            Text(viewModel.zikir.name)
                .font(.title)
            
            Text(viewModel.zikir.description)
                .foregroundColor(.gray)
            
            VStack(spacing: 8) {
                Text("\(viewModel.zikir.count)")
                    .font(.system(size: 72, weight: .bold))
                
                Text("Hedef: \(viewModel.zikir.targetCount)")
                    .foregroundColor(.gray)
                    .onTapGesture {
                        showingTargetEdit = true
                    }
                
                Text("Tamamlama: \(viewModel.zikir.completions)")
                    .foregroundColor(.green)
            }
            
            Button(action: {
                viewModel.incrementCount()
                if hapticFeedbackEnabled {
                    feedbackCounterGenerator.impactOccurred()
                }
            }) {
                Circle()
                    .fill(Color.orange)
                    .frame(width: 250, height: 250)
                    .overlay(
                        Text("Sayaç")
                            .foregroundColor(.white)
                            .font(.title2)
                    )
            }
            
            Button("Sıfırla") {
                viewModel.resetCount()
                if hapticFeedbackEnabled {
                    feedbackCompleteGenerator.impactOccurred()
                }
            }
            .padding()
            
            ProgressView(
                value: Double(viewModel.zikir.count),
                total: Double(viewModel.zikir.targetCount)
            )
            .padding(.horizontal)
            
            Button(action: {
                editedName = viewModel.zikir.name
                editedDescription = viewModel.zikir.description
                editedTargetCount = viewModel.zikir.targetCount
                showingEditZikir = true
            }) {
                Label("Düzenle", systemImage: "pencil")
            }
            .padding()
        }
        .padding()
        .onChange(of: viewModel.isCompleted) {
            if hapticFeedbackEnabled {
                feedbackCompleteGenerator.impactOccurred()
            }
            viewModel.isCompleted = false
        }
        .sheet(isPresented: $showingEditZikir) {
            NavigationView {
                Form {
                    TextField("Zikir Adı", text: $editedName)
                    TextField("Açıklama", text: $editedDescription)
                    TextField("Hedef Sayısı", value: $editedTargetCount, formatter: NumberFormatter())
                        .keyboardType(.numberPad)
                }
                .navigationTitle("Zikir Düzenle")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Vazgeç") {
                            showingEditZikir = false
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Kaydet") {
                            if editedTargetCount > 0 {  // Check if target count is greater than 0
                                viewModel.updateZikir(name: editedName, description: editedDescription, targetCount: editedTargetCount)
                                viewModel.resetCount()
                                feedbackCompleteGenerator.impactOccurred()
                                showingEditZikir = false
                            }
                        }
                        .disabled(editedName.isEmpty || editedTargetCount <= 0)  // Disable if target count is 0 or invalid
                    }
                }
            }
        }
    }
}
