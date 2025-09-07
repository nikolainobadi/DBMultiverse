//
//  PageInfo.swift
//
//
//  Created by Nikolai Nobadi on 1/8/25.
//

import Foundation

public struct PageInfo: Sendable {
    public let chapter: Int
    public let pageNumber: Int
    public let secondPageNumber: Int?
    public let imageData: Data
    
    public init(chapter: Int, pageNumber: Int, secondPageNumber: Int?, imageData: Data) {
        self.chapter = chapter
        self.pageNumber = pageNumber
        self.secondPageNumber = secondPageNumber
        self.imageData = imageData
    }
}
