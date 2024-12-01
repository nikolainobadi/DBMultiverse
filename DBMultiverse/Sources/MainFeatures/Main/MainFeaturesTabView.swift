//
//  MainFeaturesTabView.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 11/30/24.
//

import SwiftUI
import NnSwiftUIKit

struct MainFeaturesTabView: View {
    @StateObject var viewModel: MainFeaturesViewModel
    
    var body: some View {
        TabView {
            ChapterListFeatureView()
                .tabItem {
                    Label("Main Story", systemImage: "book")
                }
            
            SpecialFeatureNavStack()
                .tabItem {
                    Label("Specials", systemImage: "star")
                }
        }
        .asyncTask {
            try await viewModel.loadData()
        }
    }
}


// MARK: - Preview
#Preview {
    MainFeaturesTabView(viewModel: .init(env: SharedDataENV()))
}
