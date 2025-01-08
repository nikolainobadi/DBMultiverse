//
//  iPadComicPageView.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 1/8/25.
//

import SwiftUI
import DBMultiverseComicKit

struct iPadComicPageView: View {
    let page: ComicPage
    let nextPage: () -> Void
    let previousPage: () -> Void
    let finishChapter: () -> Void
    
    var body: some View {
        VStack {
            HStack {
                iPadComicButton(.previous, action: previousPage)
                    .disabled(page.isFirstPage)
                
                Spacer()
                ComicPageImageView(page: page)
                Spacer()
                
                iPadComicButton(.next, action: nextPage)
                    .disabled(page.isLastPage)
            }
            
            Button("Finish Chapter", action: finishChapter)
                .tint(.red)
                .buttonStyle(.borderedProminent)
                .onlyShow(when: page.isLastPage)
        }
    }
}


// MARK: - Button
fileprivate struct iPadComicButton: View {
    let type: iPadComicButtonType
    let action: () -> Void
    
    init(_ type: iPadComicButtonType, action: @escaping () -> Void) {
        self.type = type
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Image(systemName: type.imageName)
                .bold()
                .padding()
                .withFont(textColor: type.tint)
                .frame(maxHeight: .infinity)
                .background(.gray.opacity(0.5))
                .clipShape(.rect(cornerRadius: 10))
        }
    }
}


// MARK: - Dependencies
enum iPadComicButtonType {
    case next, previous
    
    var imageName: String {
        switch self {
        case .next:
            return "chevron.right"
        case .previous:
            return "chevron.left"
        }
    }
    
    var tint: Color {
        switch self {
        case .next:
            return .blue
        case .previous:
            return .red
        }
    }
}
