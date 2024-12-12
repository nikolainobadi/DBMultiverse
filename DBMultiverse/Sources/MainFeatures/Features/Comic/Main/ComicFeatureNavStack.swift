//
//  ComicFeatureNavStack.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 12/11/24.
//

import SwiftUI
import NnSwiftUIKit

struct ComicFeatureNavStack: View {
    let chapters: [SwiftDataChapter]
    
    var body: some View {
        NavStack(title: "DB Multiverse") {
            Text("Comic Feature Nav Stack")
        }
    }
}


// MARK: - Preview
#Preview {
    MainFeaturesTabView()
        .withPreviewModifiers()
}
