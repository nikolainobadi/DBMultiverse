//
//  DefaultImageCompressor.swift
//  DBMultiverseComicKit
//
//  Created by Nikolai Nobadi on 9/7/25.
//

import UIKit

public struct DefaultImageCompressor: ImageCompressing {
    public init() {}
    
    public func compressImageData(_ data: Data) -> Data? {
        guard let image = UIImage(data: data) else { return nil }
        return image.jpegData(compressionQuality: 0.7)
    }
}
