//
//  CustomAsyncImage.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 12/12/24.
//

import SwiftUI

struct CustomAsyncImage: View {
    let url: URL?
    let width: CGFloat
    let height: CGFloat
    
    init(url: URL?, width: CGFloat = 50, height: CGFloat = 70) {
        self.url = url
        self.width = width
        self.height = height
    }
    
    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: width, height: height)
                    .cornerRadius(8)
            case .success(let image):
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: width, height: height)
                    .cornerRadius(8)
                    .clipped()
            case .failure:
                Rectangle()
                    .fill(Color.red.opacity(0.3))
                    .frame(width: width, height: height)
                    .cornerRadius(8)
            @unknown default:
                EmptyView()
            }
        }
    }
}
