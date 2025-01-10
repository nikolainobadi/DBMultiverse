//
//  AppUpdateCheckViewModel.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 1/9/25.
//

import Foundation
import NnAppVersionValidator

final class AppUpdateCheckViewModel: ObservableObject {
    @Published var updateInfo: AppUpdateInfo?
}


// MARK: - Actions
extension AppUpdateCheckViewModel {
    func fetchUpdateInfo() async {
        let url = URL(string: "") // TODO: -
        let service = makeAppUpdateValidationService(url: url, bundle: .main, selectedVersionNumber: .minor)
        let info = try? await service.fetchAvailableUpdate()
        
        await MainActor.run {
            updateInfo = info
        }
    }
}
