//
//  FilmCollectionViewCell.swift
//  NitrixTestTask
//
//  Created by Oleh Oliinykov on 01.02.2024.
//

import UIKit
import SnapKit

class FilmCollectionViewCell: UICollectionViewCell {
    static let identifier: String = Constants.cellIdentifier
    
    private var posterImage: UIImageView = {
        let image = UIImageView()
        
        image.contentMode = .scaleToFill
        image.layer.cornerRadius = Constants.CellUI.cornerRadius
        image.clipsToBounds = true
        image.translatesAutoresizingMaskIntoConstraints = false
        
        return image
    }()
    
    var favouriteButton: UIButton = {
        let button = UIButton()
        
        button.frame.size = CGSize(width: 24, height: 24)
                
        return button
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        
        label.font = .boldSystemFont(ofSize: 16.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private lazy var overviewLabel: UILabel = {
        let label = UILabel()
        
        label.numberOfLines = 3
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private var releaseDateLabel: UILabel = {
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    func configure(with film: Film, and imageURL: URL) {
        posterImage.load(url: imageURL)
        titleLabel.text = film.title
        overviewLabel.text = film.overview
        releaseDateLabel.text = film.releaseDate
        
        favouriteButtonIconObserver(film)
        
        setupUI()
    }
    
    private func setupUI() {
        contentView.layer.cornerRadius = Constants.CellUI.cornerRadius
        
        contentView.addSubview(posterImage)
        contentView.addSubview(favouriteButton)
        contentView.addSubview(titleLabel)
        contentView.addSubview(overviewLabel)
        contentView.addSubview(releaseDateLabel)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        posterImage.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(Constants.CellUI.defaultCellPadding)
        }
        
        favouriteButton.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(Constants.CellUI.defaultCellPadding)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(posterImage.snp.bottom).offset(Constants.CellUI.defaultCellPadding)
            make.leading.trailing.equalTo(contentView).inset(Constants.CellUI.defaultCellPadding)
        }
        
        overviewLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(Constants.CellUI.defaultCellPadding)
            make.leading.trailing.equalTo(contentView).inset(Constants.CellUI.defaultCellPadding)
        }
        
        releaseDateLabel.snp.makeConstraints { make in
            make.trailing.bottom.equalToSuperview().inset(Constants.CellUI.defaultCellPadding)
        }
    }
    
    private func favouriteButtonIconObserver(_ film: Film) {
        let favouriteButtonImage = UIImage(systemName: "heart.fill")
        let defaultButtonImage = UIImage(systemName: "heart")
        
        if film.isFavourite {
            favouriteButton.setImage(favouriteButtonImage, for: .normal)
        } else {
            favouriteButton.setImage(defaultButtonImage, for: .normal)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        posterImage.image = nil
        titleLabel.text = nil
        overviewLabel.text = nil
        releaseDateLabel.text = nil
    }
}

fileprivate extension Constants {
    static let cellIdentifier: String = "FilmCollectionViewCell"
    
    enum CellUI {
        static let defaultCellPadding: Int = 16
        static let cornerRadius: CGFloat = 32
    }
    
}
