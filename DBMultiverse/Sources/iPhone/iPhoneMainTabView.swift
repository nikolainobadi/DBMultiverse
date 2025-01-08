//
//  iPhoneMainTabView.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 1/7/25.
//

import SwiftUI
import NnSwiftUIKit
import DBMultiverseComicKit

struct iPhoneMainTabView<SettingsTab: View>: View {
    let loader: ComicPageLoader
    let eventHandler: SwiftDataChapterListEventHandler
    let settingsTab: () -> SettingsTab
    
    init(loader: ComicPageLoader, delegate: SwiftDataChapterListEventHandler, @ViewBuilder settingsTab: @escaping () -> SettingsTab) {
        self.loader = loader
        self.eventHandler = delegate
        self.settingsTab = settingsTab
    }
    
    var body: some View {
        TabView {
            ComicNavStack {
                ChapterListView(imageSize: .iPhoneImageSize, eventHandler: eventHandler) { selection in
                    ComicTypePicker(selection: selection)
                }
                .navigationDestination(for: Chapter.self) { chapter in
                    ComicPageView(chapter: chapter, loader: loader) { viewModel in
                        if let currentPage = viewModel.currentPage {
                            iPhoneComicPageView(page: currentPage, nextPage: viewModel.nextPage, previousPage: viewModel.previousPage, finishChapter: { })
                        }
                    }
                }
            }
            .tabItem {
                Label("Comic", systemImage: "book")
            }
            
            settingsTab()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
    }
}


// MARK: - Page
struct iPhoneComicPageView: View {
    let page: ComicPage
    let nextPage: () -> Void
    let previousPage: () -> Void
    let finishChapter: () -> Void
    
    var body: some View {
        VStack {
            ComicPageImageView(page: page)
            
            HStack {
                HapticButton("Previous", action: previousPage)
                .tint(.red)
                .disabled(page.isFirstPage)
                
                HapticButton("Next", action: nextPage)
                    .tint(.blue)
                    .showingConditionalView(when: page.isLastPage) {
                        HapticButton("Finish Chapter", action: finishChapter)
                            .tint(.red)
                    }
            }
        }
    }
}

extension SwiftDataChapterListEventHandler {
    func makeImageURL(for chapter: Chapter) -> URL? {
        return .init(string: .makeFullURLString(suffix: chapter.coverImageURL))
    }
    
    func makeSections(type: ComicType) -> [ChapterSection] {
        switch type {
        case .story:
            return [.init(type: .chapterList(title: "Main Story Chapters"), chapters: chapters)]
        case .specials:
            return []
        }
    }
}


// MARK: - List
struct iPhoneChapterListView: View {
    @State private var selection: ComicType = .story
    
    let delegate: SwiftDataChapterListEventHandler
    
    var body: some View {
        VStack {
            ComicTypePicker(selection: $selection)
            
//            ChapterListView(sections: delegate.makeSections(type: selection), makeImageURL: delegate.makeImageURL(for:), unreadChapter: delegate.toggle(_:))
        }
        .animation(.smooth, value: selection)
    }
}


// MARK: - Picker
struct ComicTypePicker: View {
    @Binding var selection: ComicType
    
    var body: some View {
        HStack(spacing: 10) {
            ForEach(ComicType.allCases, id: \.self) { type in
                Text(type.title)
                    .withFont(textColor: selection == type ? Color.white : type.color)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(selection == type ? type.color : Color.clear)
                    .cornerRadius(8)
                    .onTapGesture {
                        selection = type
                    }
            }
        }
        .padding()
    }
}


// MARK: - Preview
//#Preview {
//    iPhoneMainTabView {
//        Text("Settings")
//    }
//}

extension CGSize {
    static var iPhoneImageSize: CGSize {
        return .init(width: 50, height: 70)
    }
}
