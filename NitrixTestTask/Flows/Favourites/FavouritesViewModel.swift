//
//  FavouritesViewModel.swift
//  NitrixTestTask
//
//  Created by Oleh Oliinykov on 02.02.2024.
//

import Foundation
import Combine

final class FavouritesViewModel {
    private let favouriteService: FavouriteService
    private let filmsService: FilmsService
    
    @Published var films: [Film] = [Film]()
    @Published var filmDetails: FilmDetails?
    
    private var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()
    
    init(with favouriteService: FavouriteService, and filmService: FilmsService) {
        self.favouriteService = favouriteService
        self.filmsService = filmService
        
        loadFilms()
        
        filmDetailsObserver()
    }
    
    func getFilmDetails(by id: Int) async {
        await filmsService.fetchFilmDetails(with: id)
    }
    
    private func loadFilms() {
        favouriteService.favouriteFilmsSubject
            .receive(on: DispatchQueue.global(qos: .background))
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("Error: \(error)")
                }
            } receiveValue: { [weak self] films in
                guard let convertedFilms = self?.prepareFilms(with: films) else { return }
                
                self?.films = convertedFilms
            }
            .store(in: &cancellables)
    }
    
    private func filmDetailsObserver() {
        filmsService.filmDetailsSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("Error: \(error)")
                }
            } receiveValue: { [weak self] filmDetails in
                self?.filmDetails = filmDetails
            }
            .store(in: &cancellables)

    }
    
    private func prepareFilms(with favouriteFilms: [FavouriteFilm]) -> [Film] {
        let convertedFilms = favouriteFilms.compactMap { [weak self] favouriteFilm in
            let convertedFilm = Film(adult: nil,
                                     backdropPath: nil,
                                     genresIDs: [.zero],
                                     id: Int(favouriteFilm.id),
                                     originalLanguage: nil,
                                     originalTitle: nil,
                                     overview: favouriteFilm.overview,
                                     popularity: nil,
                                     posterPath: favouriteFilm.posterPath,
                                     releaseDate: favouriteFilm.releaseDate,
                                     title: favouriteFilm.title,
                                     voteAverage: nil,
                                     voteCount: nil)
            
            return convertedFilm
        }
        
        
        return convertedFilms
    }
    
    func prepareImageURL(name: String?, size: FilmPosterSize) -> URL? {
        guard let imageURL = filmsService.createImageURL(with: name, size: size) else { return nil }
        
        return imageURL
    }
    
    func removeFromFavourite(film: Film) {
        favouriteService.filmSubject.send(film)
    }
}
