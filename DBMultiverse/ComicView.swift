import SwiftUI
import SwiftSoup

struct ComicFeatureView: View {
    var body: some View {
        NavigationStack {
            ComicView(viewModel: .init())
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle("Dragonball Multiverse")
        }
    }
}

struct ComicView: View {
    @StateObject var viewModel: ComicViewModel
    
    var body: some View {
        VStack {
            if let image = viewModel.currentImage {
                Image(uiImage: image)
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
        .onAppear {
            viewModel.fetchPages(startingFrom: 0)
        }
    }
}

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

final class ComicViewModel: ObservableObject {
    @Published var currentPage: Int = 0
    @Published var images: [UIImage] = []
    
    private let baseURL = "https://www.dragonball-multiverse.com/en/page-"
    private var currentPageBatch = 0 // Tracks the current batch of pages being fetched
}


// MARK: - DisplayData
extension ComicViewModel {
    var currentImage: UIImage? {
        return images[safe: currentPage]
    }
    
    var previousButtonDisabled: Bool {
        return currentPage <= 0
    }
    
    var nextButtonDisabled: Bool {
        return currentPage >= images.count - 1
    }
}


// MARK: - Actions
extension ComicViewModel {
    func previousPage() {
        if currentPage > 0 {
            currentPage -= 1
        }
    }
    
    func nextPage() {
        if currentPage < images.count - 1 {
            currentPage += 1
            fetchNextBatchIfNeeded(currentPage: currentPage)
        }
    }
    
    func fetchPages(startingFrom pageNumber: Int) {
        for offset in 0..<4 {
            fetchImage(forPage: pageNumber + offset)
        }
    }
    
    func fetchNextBatchIfNeeded(currentPage: Int) {
        // Calculate the last page in the current batch
        let lastPageInBatch = (currentPageBatch + 1) * 4 - 1
        
        // If the user is on the last page in the current batch, fetch the next batch
        if currentPage == lastPageInBatch {
            currentPageBatch += 1
            let nextPageStart = currentPageBatch * 4
            fetchPages(startingFrom: nextPageStart)
        }
    }
}

// MARK: - Private Methods
private extension ComicViewModel {
    func fetchImage(forPage pageNumber: Int) {
        guard let url = URL(string: "\(baseURL)\(pageNumber).html") else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else { return }
            
            if let imageURL = self.parseHTMLForImageURL(htmlData: data) {
                self.downloadImage(from: imageURL)
            }
        }.resume()
    }
    
    func parseHTMLForImageURL(htmlData: Data) -> URL? {
        do {
            let html = String(data: htmlData, encoding: .utf8) ?? ""
            let document = try SwiftSoup.parse(html)
            
            if let imgElement = try document.select("img[id=balloonsimg]").first() {
                let imgSrc = try imgElement.attr("src")
                return URL(string: "https://www.dragonball-multiverse.com" + imgSrc)
            }
        } catch {
            print("Error parsing HTML: \(error)")
        }
        return nil
    }
    
    func downloadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil, let image = UIImage(data: data) else { return }
            
            DispatchQueue.main.async {
                self.images.append(image)
            }
        }.resume()
    }
}


// MARK: - Exension Dependeencies
extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
