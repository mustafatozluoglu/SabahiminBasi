import SwiftUI

public struct ZikirDetailView: View {
    @StateObject var viewModel: ZikirDetailViewModel
    @State private var showingTargetEdit = false
    @State private var newTarget = ""
    
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
                
                Text("Target: \(viewModel.zikir.targetCount)")
                    .foregroundColor(.gray)
                    .onTapGesture {
                        showingTargetEdit = true
                    }
                
                Text("Completions: \(viewModel.zikir.completions)")
                    .foregroundColor(.green)
            }
            
            Button(action: { viewModel.incrementCount() }) {
                Circle()
                    .fill(Color.orange)
                    .frame(width: 120, height: 120)
                    .overlay(
                        Text("Count")
                            .foregroundColor(.white)
                            .font(.title2)
                    )
            }
            
            Button("Reset") {
                viewModel.resetCount()
            }
            .padding()
            
            ProgressView(
                value: Double(viewModel.zikir.count),
                total: Double(viewModel.zikir.targetCount)
            )
            .padding(.horizontal)
        }
        .padding()
        .alert("Target Reached!", isPresented: $viewModel.showCompletionAlert) {
            Button("Continue", role: .cancel) { }
        } message: {
            Text("You have completed this zikir \(viewModel.zikir.completions) times.")
        }
        .alert("Edit Target Count", isPresented: $showingTargetEdit) {
            TextField("New Target", text: $newTarget)
                .keyboardType(.numberPad)
            Button("Cancel", role: .cancel) { }
            Button("Update") {
                if let target = Int(newTarget) {
                    viewModel.updateTargetCount(target)
                }
            }
        }
    }
}
