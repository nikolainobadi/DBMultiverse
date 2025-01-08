//
//  ComicPage.swift
//
//
//  Created by Nikolai Nobadi on 1/7/25.
//

import SwiftUI

public struct ComicPage {
    public let number: Int
    public let chapterName: String
    public let pagePosition: PagePosition
    public let image: UIImage
    
    public init(number: Int, chapterName: String, pagePosition: PagePosition, image: UIImage) {
        self.number = number
        self.chapterName = chapterName
        self.pagePosition = pagePosition
        self.image = image
    }
}

// MARK: - Display Helpers
public extension ComicPage {
    var isFirstPage: Bool {
        return pagePosition.page == 0
    }
    
    var isLastPage: Bool {
        return pagePosition.page == pagePosition.totalPages
    }
}


// MARK: - Dependencies
public struct PagePosition {
    public let page: Int
    public let totalPages: Int
    
    public init(page: Int, totalPages: Int) {
        self.page = page
        self.totalPages = totalPages
    }
}
