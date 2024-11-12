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


// MARK: - ViewModel
final class ComicViewModel: ObservableObject {
    @Published var currentPageNumber: Int
    @Published var pages: [PageInfo] = []
    
    private var currentPageBatch = 0
    
    init(currentPageNumber: Int) {
        self.currentPageNumber = currentPageNumber
        self.currentPageBatch = currentPageNumber
    }
}


// MARK: - DisplayData
extension ComicViewModel {
    var currentPage: PageInfo? {
        return pages[safe: currentPageNumber]
    }
    
    var previousButtonDisabled: Bool {
        return currentPageNumber <= 0
    }
    
    var nextButtonDisabled: Bool {
        return currentPageNumber >= pages.count - 1
    }
}


// MARK: - Actions
extension ComicViewModel {
    func previousPage() {
        if currentPageNumber > 0 {
            currentPageNumber -= 1
        }
    }
    
    func nextPage() {
        if currentPageNumber < pages.count - 1 {
            currentPageNumber += 1
            fetchNextBatchIfNeeded(currentPage: currentPageNumber)
        }
    }
    
    func fetchNextChapter(startPage: Int) {
        pages = []
    }
    
    func fetchPages(startingFrom pageNumber: Int) {
        for offset in 0..<4 {
            fetchImage(forPage: pageNumber + offset)
        }
    }
    
    func fetchNextBatchIfNeeded(currentPage: Int) {
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
        let baseURL = "https://www.dragonball-multiverse.com/en/page-"
        guard let url = URL(string: "\(baseURL)\(pageNumber).html") else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let data = data, error == nil else { return }
            
            if let pageInfo = self?.parseHTMLForImageURL(htmlData: data) {
                self?.downloadImage(from: pageInfo)
            }
        }
        .resume()
    }
    
    func parseHTMLForImageURL(htmlData: Data) -> URLInfo? {
        do {
            let html = String(data: htmlData, encoding: .utf8) ?? ""
            let document = try SwiftSoup.parse(html)
            
            var chapter: Int?
            var page: Int?
            
            if let metaTag = try document.select("meta[property=og:title]").first() {
                let content = try metaTag.attr("content")
                let chapterRegex = try NSRegularExpression(pattern: #"Chapter (\d+)"#)
                let pageRegex = try NSRegularExpression(pattern: #"Page (\d+)"#)
                let chapterMatch = chapterRegex.firstMatch(in: content, range: NSRange(content.startIndex..., in: content))
                let pageMatch = pageRegex.firstMatch(in: content, range: NSRange(content.startIndex..., in: content))
                chapter = {
                    if let match = chapterMatch, let range = Range(match.range(at: 1), in: content) {
                        return Int(content[range])
                    }
                    return nil
                }()
                
                page = {
                    if let match = pageMatch, let range = Range(match.range(at: 1), in: content) {
                        return Int(content[range])
                    }
                    return nil
                }()
            }
            
            
            if let imgElement = try document.select("img[id=balloonsimg]").first() {
                let imgSrc = try imgElement.attr("src")
                let url = URL(string: "https://www.dragonball-multiverse.com" + imgSrc)
                
                guard let chapter, let page else {
                    return nil
                }
                
                return .init(url: url, chapter: "\(chapter)", pageNumber: "\(page)")
            }
        } catch {
            print("Error parsing HTML: \(error)")
        }
        
        return nil
    }
    
    func downloadImage(from info: URLInfo) {
        guard let url = info.url else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let data = data, error == nil, let image = UIImage(data: data) else { return }
            
            DispatchQueue.main.async {
                self?.pages.append(.init(image: image, chapter: info.chapter, pageNumber: info.pageNumber))
            }
        }
        .resume()
    }
}


// MARK: - Exension Dependeencies
extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

struct URLInfo {
    let url: URL?
    let chapter: String
    let pageNumber: String
}

struct PageInfo {
    let image: UIImage
    let chapter: String
    let pageNumber: String
    
    var title: String {
        if pageNumber == "0" {
            return ""
        }
        
        return "Chapter \(chapter) page \(pageNumber)"
    }
}




class ChapterFetcher: ObservableObject {
    @Published var chapters: [Chapter] = []
    private let url = URL(string: "https://www.dragonball-multiverse.com/en/chapters.html?comic=page&chaptersmode=1")!

    func loadChapters() {
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                print("Error fetching data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            if let html = String(data: data, encoding: .utf8) {
                self.parseHTML(html)
            }
        }
        .resume()
    }

    private func parseHTML(_ html: String) {
        do {
            let document = try SwiftSoup.parse(html)
            let chapterElements = try document.select("div.cadrelect.chapter")
            
            var loadedChapters: [Chapter] = []

            for chapterElement in chapterElements {
                // Extract chapter name
                let chapterTitle = try chapterElement.select("h4").text()
                
                // Extract start and end pages
                let pageLinks = try chapterElement.select("p a")
                if let startPageText = try? pageLinks.first()?.text(),
                   let endPageText = try? pageLinks.last()?.text(),
                   let startPage = Int(startPageText),
                   let endPage = Int(endPageText) {
                    
                    let chapter = Chapter(name: chapterTitle, startPage: startPage, endPage: endPage)
                    loadedChapters.append(chapter)
                }
            }

            DispatchQueue.main.async {
                self.chapters = loadedChapters
            }
        } catch {
            print("Error parsing HTML: \(error)")
        }
    }
}

struct ContentView: View {
    @StateObject private var fetcher = ChapterFetcher()
    
    let onSelection: (Chapter) -> Void

    var body: some View {
        List(fetcher.chapters, id: \.startPage) { chapter in
            VStack(alignment: .leading) {
                Text(chapter.name).font(.headline)
                Text("Pages: \(chapter.startPage) - \(chapter.endPage)").font(.subheadline)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                onSelection(chapter)
            }
        }
        .onAppear {
            fetcher.loadChapters()
        }
    }
}

