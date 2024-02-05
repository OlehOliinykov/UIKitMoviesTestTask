//
//  FavouriteService.swift
//  NitrixTestTask
//
//  Created by Oleh Oliinykov on 02.02.2024.
//

import Foundation
import Combine
import CoreData

final class FavouriteService {
    enum CoreDataErrors: Error {
        case addError(String)
        case deleteError(String)
        case loadStoreError(String)
    }
    
    private lazy var persistentContainer: NSPersistentContainer = {
        NSPersistentContainer(name: Constants.persistentContainerName)
    }()
    
    private var managedObjectContext: NSManagedObjectContext?
    
    private var favouriteFilms: [FavouriteFilm] = [FavouriteFilm]()
    
    let filmSubject: PassthroughSubject = PassthroughSubject<Film, CoreDataErrors>()
    
    let favouriteFilmsSubject: PassthroughSubject = PassthroughSubject<[FavouriteFilm], CoreDataErrors>()
    let isFavouriteSubject = PassthroughSubject<Film, Error>()
    
    private var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()
    
    init() {
        setup()
        
        fetchFilms()
        
        filmSubject
            .receive(on: DispatchQueue.global(qos: .background))
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(_):
                    break
                }
            } receiveValue: { [weak self] film in
                guard let id = film.id else { return }
                
                if let _ = self?.favouriteFilms.first(where: { $0.id == id }) {
                    self?.deleteFromFavourite(with: film)
                    print("DELETED")
                } else {
                    self?.addToFavourite(with: film)
                    print("ADDED")
                }
                
                DispatchQueue.global().async { [weak self] in
                    self?.fetchFilms()
                    
                    DispatchQueue.main.async { [weak self] in
                        self?.isFavouriteSubject.send(film)
                    }
                }
            
            }
            .store(in: &cancellables)
    }
    
    func isFavourite(_ film: Film) -> Bool? {
        guard let title = film.title else { return nil }
        
        var isFavourite: Bool?
        
        if let index = favouriteFilms.firstIndex(where: { favouriteFilm in
            let _ = print("\(favouriteFilm.title) ? \(title)")
            return favouriteFilm.title == title
        }) {
            isFavourite = true
        } else {
            isFavourite = false
        }
        
        return isFavourite
    }
    
    private func setup() {
        persistentContainer.loadPersistentStores { [weak self] persistentStoreDescription, error in
            if let error = error {
                self?.filmSubject.send(completion: .failure(.loadStoreError(error.localizedDescription)))
            } else {
                self?.managedObjectContext = self?.persistentContainer.viewContext
            }
        }
    }
    
    private func addToFavourite(with film: Film) {
        guard let managedObjectContext = managedObjectContext, let id = film.id else { return }
        
        let favouriteFilm = FavouriteFilm(context: managedObjectContext)
        
        favouriteFilm.id = Int32(id)
        favouriteFilm.title = film.title
        favouriteFilm.overview = film.overview
        favouriteFilm.posterPath = film.posterPath
        favouriteFilm.releaseDate = film.releaseDate
        favouriteFilm.isFavourite = film.isFavourite
        
        do {
            try managedObjectContext.save()
        } catch(let error) {
            filmSubject.send(completion: .failure(.addError(error.localizedDescription)))
        }
    }
    
    private func deleteFromFavourite(with film: Film) {
        guard let managedObjectContext = managedObjectContext, let id = film.id else { return }
                
        if let filmForDelete = favouriteFilms.first(where: { $0.id == id }){
            managedObjectContext.delete(filmForDelete)
        }
        
        do {
            try managedObjectContext.save()
        } catch(let error) {
            filmSubject.send(completion: .failure(.deleteError(error.localizedDescription)))
        }
    }
    
    private func fetchFilms() {
        let fetchRequest: NSFetchRequest<FavouriteFilm> = FavouriteFilm.fetchRequest()
        
        // ???
        persistentContainer.viewContext.perform { [weak self] in
            do {
                let films = try fetchRequest.execute()
                self?.favouriteFilms = films
                self?.favouriteFilmsSubject.send(films)
                print("UPDATED ")
            } catch {
                print("Unable to Execute Fetch Request, \(error)")
            }
        }
    }
}

fileprivate extension Constants {
    static let persistentContainerName: String = "FavouriteFilm"
}
