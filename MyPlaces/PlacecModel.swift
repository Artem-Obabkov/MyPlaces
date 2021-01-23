//
//  PlacecModel.swift
//  MyPlaces
//
//  Created by pro2017 on 19/01/2021.
//

import UIKit

struct Place {
    
    var name: String
    var location: String?
    var type: String?
    var image: UIImage?
    var placeImage: String?
    
    // Вспомогательная сортировка
    
    static let restaraunts = [
        "Балкан Гриль", "Бочка", "Вкусные истории", "Speak Easy",
        "Дастархан", "Индокитай", "Bonsai", "Burger Heroes", "Sherlock Holmes",
        "Классик", "Шок", "Kitchen", "Love&Life", "Morris Pub", "X.O",
    ]

    static func getPlaces() -> [Place] {

        var places = [Place]()

        for place in restaraunts {
            places.append(Place(name: place, location: "Минск", type: "Ресторан", placeImage: place))
        }
        
        return places

    }
    
}
