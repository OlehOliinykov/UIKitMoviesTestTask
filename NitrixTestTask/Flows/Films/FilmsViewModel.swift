//
//  FilmsViewModel.swift
//  NitrixTestTask
//
//  Created by Oleh Oliinykov on 01.02.2024.
//

import Foundation
import Combine

final class FilmsViewModel {
    private let filmsService: FilmsService
    private let favouriteService: FavouriteService
    
    @Published var films: [Film] = [Film]()
    @Published var filmDetails: FilmDetails?
    
    private var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()
    
    init(with favouriteService: FavouriteService, and filmsService: FilmsService) {
        self.favouriteService = favouriteService
        self.filmsService = filmsService
        
        filmsObserver()
        filmDetailsObserver()
        favouriteSubjectEmitter()
    }
        
    func getFilms() async {
        await filmsService.fetchFilms()
    }
    
    func getFilmDetails(by id: Int) async {
        await filmsService.fetchFilmDetails(with: id)
    }
    
    private func filmsObserver() {
        filmsService.filmsSubject
            .receive(on: DispatchQueue.global(qos: .background))
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("Error: \(error)")
                }
            } receiveValue: { [weak self] films in
                guard let films = films else { return }
                
                self?.films = films
                
                for index in films.indices {
                    if let isFavourite = self?.favouriteService.isFavourite(films[index]) {
                        self?.films[index].updateFavourite(isFavourite)
                    }
                }
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
    
    func addToFavourite(film: Film) {
        favouriteService.filmSubject.send(film)
    }
    
    private func favouriteSubjectEmitter() {
        favouriteService.isFavouriteSubject
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let failure):
                    print("ERROR: \(failure)")
                }
            }, receiveValue: { [weak self] film in
                guard let isFavourite = self?.favouriteService.isFavourite(film) else { return }
                
                if let index = self?.films.firstIndex(where: { $0.id == film.id }) {
                    self?.films[index].updateFavourite(isFavourite)
                    print("is favourite: \(self?.films[index].isFavourite)")
                }
            })
            .store(in: &cancellables)
    }
    
    func prepareImageURL(name: String?, size: FilmPosterSize) -> URL? {
        guard let imageURL = filmsService.createImageURL(with: name, size: size) else { return nil }
        
        return imageURL
    }
}
