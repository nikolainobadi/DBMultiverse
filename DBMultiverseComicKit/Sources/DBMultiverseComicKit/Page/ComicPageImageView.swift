//
//  ComicPageImageView.swift
//
//
//  Created by Nikolai Nobadi on 1/7/25.
//

import SwiftUI

public struct ComicPageImageView: View {
    let page: ComicPage
    
    public init(page: ComicPage) {
        self.page = page
    }
    
    public var body: some View {
        VStack {
            Text(page.chapterName)
            Text(page.pagePositionText)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            if let image = UIImage(data: page.imageData) {
                ZoomableImageView(image: image)
                    .padding()
            }
        }
    }
}
