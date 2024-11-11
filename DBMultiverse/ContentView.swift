import SwiftUI
import SwiftSoup

struct ContentView: View {
    var body: some View {
        ComicView()
    }
}

class ComicImageFetcher: ObservableObject {
    @Published var images: [UIImage] = []
    private let baseURL = "https://www.dragonball-multiverse.com/en/page-"
    private var currentPageBatch = 0 // Tracks the current batch of pages being fetched
    
    // Fetches a batch of 4 pages starting from a given page number
    func fetchPages(startingFrom pageNumber: Int) {
        for offset in 0..<4 {
            fetchImage(forPage: pageNumber + offset)
        }
    }
    
    private func fetchImage(forPage pageNumber: Int) {
        guard let url = URL(string: "\(baseURL)\(pageNumber).html") else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else { return }
            
            if let imageURL = self.parseHTMLForImageURL(htmlData: data) {
                self.downloadImage(from: imageURL)
            }
        }.resume()
    }
    
    private func parseHTMLForImageURL(htmlData: Data) -> URL? {
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
    
    private func downloadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil, let image = UIImage(data: data) else { return }
            
            DispatchQueue.main.async {
                self.images.append(image)
            }
        }.resume()
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

struct ComicView: View {
    @StateObject private var fetcher = ComicImageFetcher()
    @State private var currentPage: Int = 0
    
    var body: some View {
        VStack {
            if let image = fetcher.images[safe: currentPage] {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .padding()
            } else {
                Text("Loading...")
                    .padding()
            }
            
            HStack {
                Button(action: previousPage) {
                    Text("Previous")
                }
                .disabled(currentPage <= 0)
                
                Spacer()
                
                Button(action: nextPage) {
                    Text("Next")
                }
                .disabled(currentPage >= fetcher.images.count - 1)
            }
            .padding()
        }
        .onAppear {
            fetcher.fetchPages(startingFrom: 0)
        }
    }
    
    private func previousPage() {
        if currentPage > 0 {
            currentPage -= 1
        }
    }
    
    private func nextPage() {
        if currentPage < fetcher.images.count - 1 {
            currentPage += 1
            fetcher.fetchNextBatchIfNeeded(currentPage: currentPage)
        }
    }
}

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
