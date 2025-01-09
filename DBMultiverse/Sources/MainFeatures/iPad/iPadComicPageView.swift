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
                iPadComicButton(.previous, disabled: page.isFirstPage, action: previousPage)
                Spacer()
                ComicPageImageView(page: page)
                Spacer()
                iPadComicButton(.next, disabled: page.isLastPage, action: nextPage)
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
    let disabled: Bool
    let action: () -> Void
    
    init(_ type: iPadComicButtonType, disabled: Bool, action: @escaping () -> Void) {
        self.type = type
        self.action = action
        self.disabled = disabled
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
        .disabled(disabled)
        .opacity(disabled ? 0.2 : 1)
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
