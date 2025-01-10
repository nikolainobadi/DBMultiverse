//
//  CustomError.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 11/30/24.
//

import Foundation
import NnSwiftUIKit

enum CustomError: Error, NnDisplayableError {
    case urlError
    case loadHTMLError
    case parseHTMLError
    
    var message: String {
        switch self {
        case .urlError:
            return "failed to fetch data from url"
        case .loadHTMLError:
            return "unable to load ChapterList HTML"
        case .parseHTMLError:
            return "unable to parse ChapterList HTML"
        }
    }
}
