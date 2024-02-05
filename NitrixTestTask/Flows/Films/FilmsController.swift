//
//  FilmsController.swift
//  NitrixTestTask
//
//  Created by Oleh Oliinykov on 31.01.2024.
//

import UIKit
import Combine

class FilmsController: UIViewController {
    private let viewModel: FilmsViewModel
    
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
        self.viewModel = FilmsViewModel(with: favouriteService, and: filmsService)
        
        super.init(nibName: nil, bundle: nil)
        
        Task {
            await viewModel.getFilms()
        }
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
        self.title = "Films"
        
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
    
    private func setupDelegate() {
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    private func collectionViewObserver() {
        viewModel.$films
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.collectionView.reloadData()
            }
            .store(in: &cancellables)
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
        
        viewModel.addToFavourite(film: film)
        print("Long press on row, at \(indexPath.row)")
    }
}

extension FilmsController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.films.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let currentRow = viewModel.films[indexPath.row]
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FilmCollectionViewCell.identifier, for: indexPath) as? FilmCollectionViewCell,
              let imageURL = viewModel.prepareImageURL(name: currentRow.posterPath, size: .w154)
        else { fatalError("Failed to dequeue FilmCollectionViewCell in FilmController") }
        
        cell.configure(with: currentRow, and: imageURL)
        
        cell.favouriteButton.tag = indexPath.item
        cell.favouriteButton.addTarget(self, action: #selector(favouriteAction(_:)), for: .touchUpInside)
        
        let favouriteButtonImage = UIImage(systemName: "heart.fill")
        let defaultButtonImage = UIImage(systemName: "heart")
        
        if currentRow.isFavourite {
            cell.favouriteButton.setImage(favouriteButtonImage, for: .normal)
        } else {
            cell.favouriteButton.setImage(defaultButtonImage, for: .normal)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let id = viewModel.films[indexPath.item].id else { return }
        
        let filmDetailViewController = FilmDetailsViewController(viewModel, id: id)
        filmDetailViewController.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(filmDetailViewController, animated: true)
    }
    
    @objc private func favouriteAction(_ sender: UIButton) {        
        let tappedFilm = viewModel.films[sender.tag]
        
        viewModel.addToFavourite(film: tappedFilm)
            
        print("TAPPED: \(tappedFilm.title)")
    }
}
