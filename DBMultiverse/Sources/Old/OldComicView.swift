import SwiftUI
import SwiftSoup

struct OldComicFeatureView: View {
    @Binding var lastReadPage: Int
    @StateObject var viewModel: OldComicViewModel
    
    var body: some View {
        OldComicView(lastReadPage: $lastReadPage, viewModel: viewModel)
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
struct OldComicView: View {
    @Binding var lastReadPage: Int
    @ObservedObject var viewModel: OldComicViewModel
    
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
