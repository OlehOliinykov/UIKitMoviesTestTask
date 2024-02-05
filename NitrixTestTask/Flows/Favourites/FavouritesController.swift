//
//  FavouritesController.swift
//  NitrixTestTask
//
//  Created by Oleh Oliinykov on 31.01.2024.
//

import UIKit
import Combine

class FavouritesController: UIViewController {
    private let viewModel: FavouritesViewModel
    
    private var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: Constants.screenSize.width - 16, height: Constants.screenSize.height / 1.75)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(FilmCollectionViewCell.self, forCellWithReuseIdentifier: FilmCollectionViewCell.identifier)
        
        return collectionView
    }()
    
    init(with favouriteService: FavouriteService, and filmsService: FilmsService) {
        self.viewModel = FavouritesViewModel(with: favouriteService, and: filmsService)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupDelegate()
        setupLongPress()
        collectionViewObserver()
    }
    
    private func setupUI() {
        navigationController?.navigationBar.prefersLargeTitles = true
        self.title = "Favourites"
        
        self.view.addSubview(collectionView)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: self.view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }
    
    private func collectionViewObserver() {
        viewModel.$films
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.collectionView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    private func setupDelegate() {
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    private func setupLongPress() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPressGesture.minimumPressDuration = 0.5
        collectionView.addGestureRecognizer(longPressGesture)
    }
    
    @objc func handleLongPress(longPressGesture: UILongPressGestureRecognizer) {
        let location = longPressGesture.location(in: collectionView)
        let indexPath = collectionView.indexPathForItem(at: location)
        
        guard let indexPath = indexPath,
                longPressGesture.state == UIGestureRecognizer.State.began else { return }
        
        let film = viewModel.films[indexPath.row]
        
        viewModel.removeFromFavourite(film: film)
        print("Long press on row, at \(indexPath.row)")
    }
}

extension FavouritesController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.films.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let currentRow = viewModel.films[indexPath.row]
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FilmCollectionViewCell.identifier, for: indexPath) as? FilmCollectionViewCell,
              let imageURL = viewModel.prepareImageURL(name: currentRow.posterPath, size: .w154)
        else { fatalError("Failed to dequeue FilmCollectionViewCell in FilmController") }
        
        cell.configure(with: currentRow, and: imageURL)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let id = viewModel.films[indexPath.item].id else { return }
        
        let favouritesDetailViewController = FavouritesDetailViewController(viewModel, id: id)
        navigationController?.pushViewController(favouritesDetailViewController, animated: true)
    }
}
