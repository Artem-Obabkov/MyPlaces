//
//  PlacecModel.swift
//  MyPlaces
//
//  Created by pro2017 on 19/01/2021.
//

import RealmSwift

class Place: Object {
    
    @objc dynamic var name = ""
    @objc dynamic var location: String?
    @objc dynamic var type: String?
    @objc dynamic var imageData: Data?
    // Отвечает за текущую дату
    @objc dynamic var date = Date()
    @objc dynamic var rating = 0.0
    
    // Создаем кастомный инициализатор. Такой тип инициализатора используется, когда в классе есть свойства со значением по умолчанию и свойства без значения
    
    convenience init(name: String, location: String?, type: String?, imageData: Data?, rating: Double) {
        self.init()
        self.name = name
        self.location = location
        self.type = type
        self.imageData = imageData
        self.rating = rating
    }
    
    
}
