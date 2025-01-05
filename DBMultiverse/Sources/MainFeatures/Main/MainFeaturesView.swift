//
//  MainFeaturesView.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 11/30/24.
//

import SwiftUI
import SwiftData
import NnSwiftUIKit

struct MainFeaturesView: View {
    @Query(sort: \SwiftDataChapter.number, order: .forward) var chapters: [SwiftDataChapter]
    
    var body: some View {
        iPhoneTabView(chapters: chapters)
            .showingConditionalView(when: isPad) {
                iPadStack(chapters: chapters)
            }
            .fetchingChapters(existingChapterNumbers: chapters.map({ $0.number }))
    }
}


// MARK: - NavStack
fileprivate struct ComicNavStack<Content: View>: View {
    @ViewBuilder var content: () -> Content
    
    var body: some View {
        NavStack(title: "DBMultiverse", content: content)
    }
}


// MARK: - TabView
fileprivate struct iPhoneTabView: View {
    let chapters: [SwiftDataChapter]
    
    var body: some View {
        TabView {
            ComicNavStack {
                ComicFeatureChildStack(chapters: chapters)
            }
            .tabItem {
                Label("Comic", systemImage: "book")
            }
               
            SettingsFeatureNavStack()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
    }
}


// MARK: - PadView
fileprivate struct iPadStack: View {
    @State private var showingPadSettings = false
    
    let chapters: [SwiftDataChapter]
    
    var body: some View {
        ComicNavStack {
            ComicFeatureChildStack(chapters: chapters)
                .withNavBarButton(buttonContent: .image(.system("gearshape"))) {
                    showingPadSettings = true
                }
                .sheetWithErrorHandling(isPresented: $showingPadSettings) {
                    SettingsFeatureNavStack()
                }
        }
    }
}


// MARK: - Preview
#Preview {
    MainFeaturesView()
        .withPreviewModifiers()
}
