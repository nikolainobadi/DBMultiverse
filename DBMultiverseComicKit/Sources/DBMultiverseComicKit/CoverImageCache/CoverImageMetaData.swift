//
//  CoverImageMetaData.swift
//
//
//  Created by Nikolai Nobadi on 1/10/25.
//

import Foundation

public struct CoverImageMetaData {
    public let chapterName: String
    public let chapterNumber: Int
    public let readProgress: Int
    
    public init(chapterName: String, chapterNumber: Int, readProgress: Int) {
        self.chapterName = chapterName
        self.chapterNumber = chapterNumber
        self.readProgress = readProgress
    }
}
