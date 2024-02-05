//
//  FavouritesDetailViewController.swift
//  NitrixTestTask
//
//  Created by Oleh Oliinykov on 02.02.2024.
//

import UIKit
import SnapKit
import Combine

class FavouritesDetailViewController: UIViewController {
    let viewModel: FavouritesViewModel
    
    private var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.backgroundColor = .white
        
        return scrollView
    }()
    
    private let scrollStackViewContainer: UIStackView = {
        let stackView = UIStackView()
        
        stackView.axis = .vertical
        stackView.spacing = .zero
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        
        label.font = .boldSystemFont(ofSize: 16.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private lazy var genresLabel: UILabel = {
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private var releaseDateLabel: UILabel = {
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    init(_ favouriteViewModel: FavouritesViewModel, id: Int) {
        self.viewModel = favouriteViewModel
        
        super.init(nibName: nil, bundle: nil)
        
        Task {
            await viewModel.getFilmDetails(by: id)
        }
        bindDetailsData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func bindDetailsData() {
        viewModel.$filmDetails
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    break
                }
            } receiveValue: { [weak self] filmDetails in
                guard let filmDetails = filmDetails, let genres = filmDetails.genres else { return }
                let stringsGenres = genres.map({ $0.name ?? ""})
                self?.titleLabel.text = filmDetails.title
                self?.genresLabel.text = stringsGenres.joined(separator: ", ")
                self?.releaseDateLabel.text = filmDetails.releaseDate
            }
            .store(in: &cancellables)
    }
    
    private func setupUI() {
        navigationController?.navigationBar.prefersLargeTitles = true
        self.title = "Details"
        
        view.addSubview(scrollView)
        scrollView.addSubview(scrollStackViewContainer)
        scrollStackViewContainer.addSubview(titleLabel)
        scrollStackViewContainer.addSubview(genresLabel)
        scrollStackViewContainer.addSubview(releaseDateLabel)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.trailing.leading.equalToSuperview()
            make.top.bottom.equalToSuperview()
        }
        
        scrollStackViewContainer.snp.makeConstraints { make in
            make.top.bottom.height.width.equalTo(scrollView)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(scrollStackViewContainer).offset(Constants.FavouriteDetailUI.defaultPadding)
            make.leading.trailing.equalTo(scrollStackViewContainer).inset(Constants.FavouriteDetailUI.defaultPadding)
        }
        
        genresLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(Constants.FavouriteDetailUI.defaultPadding)
            make.leading.trailing.equalTo(scrollStackViewContainer).inset(Constants.FavouriteDetailUI.defaultPadding)
        }
        
        releaseDateLabel.snp.makeConstraints { make in
            make.top.equalTo(genresLabel.snp.bottom).offset(Constants.FavouriteDetailUI.defaultPadding)
            make.trailing.equalTo(scrollStackViewContainer).inset(Constants.FavouriteDetailUI.defaultPadding)
        }
    }
}


fileprivate extension Constants {
    enum FavouriteDetailUI {
        static let defaultPadding: CGFloat = 16
        static let cornerRadius: CGFloat = 32
    }
}
