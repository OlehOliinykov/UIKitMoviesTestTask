//
//  TabBarController.swift
//  NitrixTestTask
//
//  Created by Oleh Oliinykov on 31.01.2024.
//

import UIKit

class TabBarController: UITabBarController {
    private let favouriteService: FavouriteService = FavouriteService()
    private let filmsService: FilmsService = FilmsService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
    }
    
    private func setupTabs() {
        let films = createNavigationController(with: "Films", and: UIImage(systemName: "list.and.film") , viewController: FilmsController(with: favouriteService, and: filmsService))
        let favourites = createNavigationController(with: "Favourites", and: UIImage(systemName: "heart") , viewController: FavouritesController(with: favouriteService, and: filmsService))
        
        self.setViewControllers([films, favourites], animated: true)
    }
    
    private func createNavigationController(with title: String, and image: UIImage?, viewController: UIViewController) -> UINavigationController {
        let navigationController = UINavigationController(rootViewController: viewController)
        
        navigationController.tabBarItem.title = title
        navigationController.tabBarItem.image = image
        
        return navigationController
    }
}
