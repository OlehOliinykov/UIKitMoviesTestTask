//
//  Film.swift
//  NitrixTestTask
//
//  Created by Oleh Oliinykov on 01.02.2024.
//

import Foundation

struct FilmResponse: Codable {
    let page: Int?
    let results: [Film]?
    let totalPages: Int?
    let totalResults: Int?
    
    enum CodingKeys: String, CodingKey {
        case page
        case results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}

struct Film: Codable {
    let adult: Bool?
    let backdropPath: String?
    let genresIDs: [Int]?
    let id: Int?
    let originalLanguage: String?
    let originalTitle: String?
    let overview: String?
    let popularity: Double?
    let posterPath: String?
    let releaseDate: String?
    let title: String?
    let voteAverage: Double?
    let voteCount: Int?
    var isFavourite: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case adult
        case backdropPath = "backdrop_path"
        case genresIDs = "genres_ids"
        case id
        case originalLanguage = "original_language"
        case originalTitle = "original_title"
        case overview
        case popularity
        case posterPath = "poster_path"
        case releaseDate = "release_date"
        case title
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
    }
    
    mutating func updateFavourite(_ isFavourite: Bool) {
        self.isFavourite = isFavourite
    }
}
