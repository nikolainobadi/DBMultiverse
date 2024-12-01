//
//  CustomError.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 11/30/24.
//

import Foundation
import NnSwiftUIKit

enum CustomError: Error, NnDisplayableError {
    case loadHTMLError
    case parseHTMLError
    
    var message: String {
        switch self {
        case .loadHTMLError:
            return "unable to load ChapterList HTML"
        case .parseHTMLError:
            return "unable to parse ChapterList HTML"
        }
    }
}
