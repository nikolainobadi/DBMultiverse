//
//  AppLauncher.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 12/24/24.
//

import Foundation
import NnTestVariables

@main
struct AppLauncher {
    static func main() throws {
        if ProcessInfo.isTesting {
            TestApp.main()
        } else {
            DBMultiverseApp.main()
        }
    }
}
