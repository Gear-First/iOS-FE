//
//  PartsService.swift
//  iOS-FE
//
//  Created by wj on 9/29/25.
//

import Foundation

class PartsService {
    func fetchParts(completion: @escaping (Result<[Parts], Error>) -> Void) {
        guard let url = URL(string: "http://localhost:8080/api/v1/parts") else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else { return }
            
            do {
                let parts = try JSONDecoder().decode([Parts].self, from: data)
                completion(.success(parts))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
