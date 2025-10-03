//
//  PartsViewModel.swift
//  iOS-FE
//
//  Created by wj on 9/29/25.
//

import Foundation

class PartsViewModel: ObservableObject {
    @Published var parts: [Parts] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    private let service = PartsService()
    
    func loadParts() {
        isLoading = true
        errorMessage = nil
        
        service.fetchParts { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let parts):
                    self?.parts = parts
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
