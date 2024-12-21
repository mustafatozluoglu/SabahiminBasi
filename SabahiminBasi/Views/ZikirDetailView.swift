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
    @AppStorage("timerInterval") private var timerInterval: Double = 1.0
    @AppStorage("timerEnabled") private var timerEnabled: Bool = true
    private let feedbackCounterGenerator = UIImpactFeedbackGenerator(style: .light)
    private let feedbackCompleteGenerator = UIImpactFeedbackGenerator(style: .heavy)
    @State private var timer: Timer? = nil
    
    public init(viewModel: ZikirDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text(viewModel.zikir.name)
                    .font(.system(size: 20, weight: .heavy))
                    .lineLimit(nil)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text(viewModel.zikir.description)
                    .font(.system(size: 12, weight: .heavy))
                    .foregroundColor(.gray)
                    .lineLimit(nil)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                
                VStack(spacing: 6) {
                    Text("\(viewModel.zikir.count)")
                        .font(.system(size: 64, weight: .bold))
                    
                    Text("Hedef: \(viewModel.zikir.targetCount)")
                        .foregroundColor(.gray)
                        .font(.system(size: 18, weight: .heavy))
                        .onTapGesture {
                            showingTargetEdit = true
                        }
                    
                    Text("Tamamlama: \(viewModel.zikir.completions)")
                        .foregroundColor(.green)
                        .font(.system(size: 12, weight: .heavy))
                }
                
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
                            Text("Sayaç")
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
                .onDisappear {
                    timer?.invalidate()
                    timer = nil
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
                        .font(.system(size: 14, weight: .heavy))
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
                        Text("Zikir Adı")
                            .font(.system(size: 16, weight: .bold))
                        TextEditor(text: $editedName)
                            .frame(minHeight: 40)
                        Text("Açıklama")
                            .font(.system(size: 16, weight: .bold))
                        TextEditor(text: $editedDescription)
                            .frame(minHeight: 40)
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
}
