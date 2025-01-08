//
//  iPhoneMainTabView.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 1/7/25.
//

import SwiftUI
import DBMultiverseComicKit

struct iPhoneMainTabView<SettingsTab: View>: View {
    let loader: ComicPageLoader
    let settingsTab: () -> SettingsTab
    
    init(loader: ComicPageLoader, @ViewBuilder settingsTab: @escaping () -> SettingsTab) {
        self.loader = loader
        self.settingsTab = settingsTab
    }
    
    var body: some View {
        TabView {
            ComicNavStack {
                iPhoneChapterListView()
                    .navigationDestination(for: Chapter.self) { chapter in
                        ComicPageView(loader: loader) { page in
                            iPhoneComicPageView(
                                page: page,
                                nextPage: { },
                                previousPage: { },
                                finishChapter: { }
                            )
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


// MARK: - List
struct iPhoneChapterListView: View {
    @State private var selection: ComicType = .story
    
    var body: some View {
        VStack {
            ComicTypePicker(selection: $selection)
            
            ChapterListView(sections: [], makeImageURL: { _ in nil }, unreadChapter: { _ in })
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
