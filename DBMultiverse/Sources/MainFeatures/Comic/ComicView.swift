import SwiftUI
import SwiftSoup

struct ComicFeatureView: View {
    @Binding var lastReadPage: Int
    @StateObject var viewModel: ComicViewModel
    
    var body: some View {
        ComicView(lastReadPage: $lastReadPage, viewModel: viewModel)
        // TODO: - nav title should be chapter number
            .onAppear {
                viewModel.fetchPages(startingFrom: lastReadPage)
            }
            .onChange(of: viewModel.currentPageNumber) { _, newValue in
                lastReadPage = newValue
            }
    }
}


// MARK: - Comic View
struct ComicView: View {
    @Binding var lastReadPage: Int
    @ObservedObject var viewModel: ComicViewModel
    
    var body: some View {
        VStack {
            if let info = viewModel.currentPage {
                Text(info.title)
                    
                Image(uiImage: info.image)
                    .resizable()
                    .scaledToFit()
                    .padding()
            } else {
                Text("Loading...")
                    .padding()
            }
            
            HStack {
                HapticButton("Previous", action: viewModel.previousPage)
                    .tint(.red)
                    .disabled(viewModel.previousButtonDisabled)
                
                Spacer()
                
                HapticButton("Next", action: viewModel.nextPage)
                    .disabled(viewModel.nextButtonDisabled)
            }
            .padding()
        }
    }
}


// MARK: - HapticButton
struct HapticButton: View {
    let title: String
    let action: () -> Void
    
    init(_ title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }
    
    var body: some View {
        Button(title) {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            action()
        }
        .buttonStyle(.bordered)
    }
}
