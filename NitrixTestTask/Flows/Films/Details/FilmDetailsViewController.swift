//
//  FilmDetailsViewController.swift
//  NitrixTestTask
//
//  Created by Oleh Oliinykov on 02.02.2024.
//

import UIKit
import Combine
import SnapKit

class FilmDetailsViewController: UIViewController {
    private let viewModel: FilmsViewModel
    
    private var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
                
        scrollView.showsVerticalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        return scrollView
    }()
    
    private let scrollStackViewContainer: UIStackView = {
        let stackView = UIStackView()
        
        stackView.axis = .vertical
        stackView.spacing = .zero
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    
    private var posterImage: UIImageView = {
        let image = UIImageView()
        
        image.contentMode = .scaleToFill
        image.layer.cornerRadius = Constants.DetailUI.cornerRadius
        image.clipsToBounds = true
        image.translatesAutoresizingMaskIntoConstraints = false
                
        return image
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        
        label.font = .boldSystemFont(ofSize: 16.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private lazy var overviewLabel: UILabel = {
        let label = UILabel()
        
        label.frame.size.width = Constants.screenSize.width
        
        label.numberOfLines = .zero
        label.translatesAutoresizingMaskIntoConstraints = false

        
        return label
    }()
    
    private var releaseDateLabel: UILabel = {
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    
    
    init(_ viewModel: FilmsViewModel, id: Int) {
        self.viewModel = viewModel
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
                guard let url = self?.viewModel.prepareImageURL(name: filmDetails?.posterPath, size: .w300) else { return }
                self?.posterImage.load(url: url)
                self?.titleLabel.text = filmDetails?.title
                self?.overviewLabel.text = filmDetails?.overview
                self?.releaseDateLabel.text = filmDetails?.releaseDate
            }
            .store(in: &cancellables)
    }
    
    private func setupUI() {
        self.title = "Details"
        view.backgroundColor = .white
        navigationController?.navigationBar.prefersLargeTitles = true
        
        view.addSubview(scrollView)
        scrollView.addSubview(scrollStackViewContainer)
        
        scrollStackViewContainer.addSubview(posterImage)
        scrollStackViewContainer.addSubview(titleLabel)
        scrollStackViewContainer.addSubview(overviewLabel)
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
        
        posterImage.snp.makeConstraints { make in
            make.top.equalTo(scrollStackViewContainer).inset(Constants.DetailUI.defaultPadding)
            make.centerX.equalTo(scrollStackViewContainer.snp.centerX)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(posterImage.snp.bottom).offset(Constants.DetailUI.defaultPadding)
            make.leading.trailing.equalTo(scrollStackViewContainer).inset(Constants.DetailUI.defaultPadding)
        }
        
        overviewLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(Constants.DetailUI.defaultPadding)
            make.leading.trailing.equalTo(scrollStackViewContainer).inset(Constants.DetailUI.defaultPadding)
        }
        
        releaseDateLabel.snp.makeConstraints { make in
            make.top.equalTo(overviewLabel.snp.bottom).offset(Constants.DetailUI.defaultPadding)
            make.trailing.equalTo(scrollStackViewContainer).inset(Constants.DetailUI.defaultPadding)
        }
    }
}

fileprivate extension Constants {
    enum DetailUI {
        static let defaultPadding: CGFloat = 16
        static let cornerRadius: CGFloat = 32
    }
}
