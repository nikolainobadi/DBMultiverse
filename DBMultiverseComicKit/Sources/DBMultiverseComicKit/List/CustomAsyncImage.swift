//
//  CustomAsyncImage.swift
//
//
//  Created by Nikolai Nobadi on 1/7/25.
//

import SwiftUI

struct CustomAsyncImage: View {
    let url: URL?
    let width: CGFloat
    let height: CGFloat
    
    init(url: URL?, size: CGSize?) {
        self.url = url
        self.width = size?.width ?? 50
        self.height = size?.height ?? 70
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
