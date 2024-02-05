//
//  FilmsService.swift
//  NitrixTestTask
//
//  Created by Oleh Oliinykov on 01.02.2024.
//

import Foundation
import Combine

enum FilmPosterSize: String {
    case w92 = "w92"
    case w154 = "w154"
    case w185 = "w185"
    case w300 = "w300"
    case w342 = "w342"
    case w500 = "w500"
    case w780 = "w780"
    case original = "original"
}

final class FilmsService {
    enum NetworkError: Error {
        case apiKey
        case invalidURL
        case invalidResponse
        case serverError
        case urlSessionError(String)
        case decodingError
    }
    
    private let apiKeyService: APIKeyService = APIKeyService()
    
    let filmsSubject: PassthroughSubject = PassthroughSubject<[Film]?, NetworkError>()
    let filmDetailsSubject: PassthroughSubject = PassthroughSubject<FilmDetails?, NetworkError>()
    
    func fetchFilms() async {
        let url = await createURL()
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self else { return }
            if let error = error {
                self.filmsSubject.send(completion: .failure(.urlSessionError(error.localizedDescription)))
            }
            
            if let response = response as? HTTPURLResponse, response.statusCode > 299 {
                self.filmsSubject.send(completion: .failure(.serverError))
                print("RESPONSE: \(response)")
            }
            
            guard let data = data else { return
                self.filmsSubject.send(completion: .failure(.invalidResponse))
            }
            do {
                let result = try JSONDecoder().decode(FilmResponse.self, from: data)
                self.filmsSubject.send(result.results)
            } catch {
                self.filmsSubject.send(completion: .failure(.decodingError))
            }
        }
        .resume()
    }
    
    private func createURL() async -> URL {
        guard let apiKey: String = await apiKeyService.getAPIKey() else { return URL(fileURLWithPath: "") }
        
        let queryItems: [URLQueryItem] = [
            URLQueryItem(name: Constants.QueryItems.apiKey, value: apiKey)
        ]
        
        var component = URLComponents()
        component.scheme = Constants.FilmComponents.scheme
        component.host = Constants.FilmComponents.host
        component.path = Constants.FilmComponents.path
        component.queryItems = queryItems
        
        guard let url = component.url else { return URL(fileURLWithPath: "") }
        
        return url
    }
    
    func fetchFilmDetails(with id: Int) async {
        let url = await createDetailsURL(with: id)
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self else { return }
            if let error = error {
                
                self.filmDetailsSubject.send(completion: .failure(.urlSessionError(error.localizedDescription)))
            }
            
            if let response = response as? HTTPURLResponse, response.statusCode > 299 {
                self.filmDetailsSubject.send(completion: .failure(.serverError))
                print("RESPONSE: \(response)")
            }
            
            guard let data = data else { return }
            do {
                let result = try JSONDecoder().decode(FilmDetails.self, from: data)
                self.filmDetailsSubject.send(result)
            } catch(let error) {
                print("ERRROOOORR: \(error)")
                self.filmDetailsSubject.send(completion: .failure(.decodingError))
            }
        }
        .resume()
    }
    
    private func createDetailsURL(with id: Int) async -> URL {
        guard let apiKey: String = await apiKeyService.getAPIKey() else { return URL(fileURLWithPath: "") }
        
        let queryItems: [URLQueryItem] = [
            URLQueryItem(name: Constants.QueryItems.apiKey, value: apiKey)
        ]
        
        var component = URLComponents()
        component.scheme = Constants.DetailsFilmComponents.scheme
        component.host = Constants.DetailsFilmComponents.host
        component.path = "\(Constants.DetailsFilmComponents.path)\(id)"
        component.queryItems = queryItems
        
        guard let url = component.url else { return URL(fileURLWithPath: "") }
        
        return url
    }
    
    func createImageURL(with name: String?, size: FilmPosterSize) -> URL? {
        guard let name = name else { return nil }
        var component = URLComponents()
        component.scheme = "https"
        component.host = "image.tmdb.org"
        component.path = "/t/p/\(size.rawValue)/\(name)"
        
        return component.url
    }
}

fileprivate extension Constants {
    enum QueryItems {
        static let apiKey: String = "api_key"
    }
    
    enum FilmComponents {
        static let scheme: String = "https"
        static let host: String = "api.themoviedb.org"
        static let path: String = "/3/movie/popular"
    }
    
    enum DetailsFilmComponents {
        static let scheme: String = "https"
        static let host: String = "api.themoviedb.org"
        static let path: String = "/3/movie/"
    }
}
