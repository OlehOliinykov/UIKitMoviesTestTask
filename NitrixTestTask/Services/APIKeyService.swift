//
//  APIKeyService.swift
//  NitrixTestTask
//
//  Created by Oleh Oliinykov on 01.02.2024.
//

import Foundation
import FirebaseDatabase
import FirebaseDatabaseSwift

final class APIKeyService {
    private let ref = Database.database().reference()
    
    func getAPIKey() async -> String? {
        do {
            let data = try await ref.child(Constants.Path.apiKeyPath).getData()
            guard let key = data.value as? String else { return nil }
            
            return key
        } catch(let error) {
            print("Error: \(error.localizedDescription)")
        }
        
        return nil
    }
}

fileprivate extension Constants {
    enum Path {
        static let apiKeyPath: String = "APIKey"
    }
}
