//
//  MainFeaturesTabView.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 11/30/24.
//

import SwiftUI
import SwiftData
import NnSwiftUIKit

struct MainFeaturesTabView: View {
    @Query var chapters: [SwiftDataChapter]
    
    var body: some View {
        TabView {
           ComicFeatureNavStack(chapters: chapters)
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


// MARK: - Preview
#Preview {
    MainFeaturesTabView()
        .withPreviewModifiers()
}
