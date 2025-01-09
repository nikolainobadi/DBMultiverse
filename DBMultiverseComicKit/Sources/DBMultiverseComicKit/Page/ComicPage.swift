//
//  ComicPage.swift
//
//
//  Created by Nikolai Nobadi on 1/7/25.
//

import Foundation

public struct ComicPage: Equatable {
    public let number: Int
    public let chapterName: String
    public let pagePosition: PagePosition
    public let imageData: Data
    
    public init(number: Int, chapterName: String, pagePosition: PagePosition, imageData: Data) {
        self.number = number
        self.chapterName = chapterName
        self.pagePosition = pagePosition
        self.imageData = imageData
    }
}

// MARK: - Display Helpers
public extension ComicPage {
    var isFirstPage: Bool {
        return pagePosition.page == 0
    }
    
    var isLastPage: Bool {
        return pagePosition.page == pagePosition.endPage
    }
    
    var pagePositionText: String {
        guard let secondPage = pagePosition.secondPage else {
            return "\(pagePosition.page)/\(pagePosition.endPage)"
        }
        
        return "\(pagePosition.page)-\(secondPage)/\(pagePosition.endPage)"
    }
}


// MARK: - Dependencies
public struct PagePosition: Equatable {
    public let page: Int
    public let secondPage: Int?
    public let endPage: Int
    
    public init(page: Int, secondPage: Int?, endPage: Int) {
        self.page = page
        self.secondPage = secondPage
        self.endPage = endPage
    }
}
