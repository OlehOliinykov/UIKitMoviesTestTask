//
//  FavouriteFilm+CoreDataProperties.swift
//  
//
//  Created by Oleh Oliinykov on 05.02.2024.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension FavouriteFilm {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FavouriteFilm> {
        return NSFetchRequest<FavouriteFilm>(entityName: "FavouriteFilm")
    }

    @NSManaged public var id: Int32
    @NSManaged public var isFavourite: Bool
    @NSManaged public var overview: String?
    @NSManaged public var posterPath: String?
    @NSManaged public var releaseDate: String?
    @NSManaged public var title: String?

}

extension FavouriteFilm : Identifiable {

}
