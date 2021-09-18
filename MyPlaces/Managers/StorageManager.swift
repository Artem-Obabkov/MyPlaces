//
//  StorageManager.swift
//  MyPlaces
//
//  Created by pro2017 on 23/01/2021.
//

import RealmSwift

let realm = try! Realm()

class StorageManager {
    
    static func saveData(_ place: Place) {
        
        try! realm.write {
            realm.add(place)
        }
        
    }
    
    static func deleteObject(_ place: Place) {
        
        try! realm.write {
            realm.delete(place)
        }
        
    }
}
