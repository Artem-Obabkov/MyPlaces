//
//  MainTableView.swift
//  MyPlaces
//
//  Created by pro2017 on 18/01/2021.
//

import UIKit
import RealmSwift

class MainTableView: UITableViewController {

    // Создаем экземпляр results с типом данных place. Он работает аналогично массиву
    var places: Results<Place>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Отображаем сохраненные объекты в базе данных. Указываем Place.self, т.к нужно указать ИМЕННО тип 
        places = realm.objects(Place.self)
        
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.isEmpty ? 0 : places.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as! CustomCell
        
        // Упрощаем читабельность кода
        let place = places[indexPath.row]

        cell.nameLabel.text = place.name
        cell.locationLabel.text = place.location
        cell.typeLabel.text = place.type
        
        // Конвентируем изображение
        cell.imageOfPlace.image = UIImage(data: place.imageData!)
        

        // Делаем изображение круглым
        cell.imageOfPlace.layer.cornerRadius = cell.imageOfPlace.frame.height / 2
        cell.imageOfPlace.clipsToBounds = true

        return cell
    }
    
    
    // MARK: Tabel View Delegate
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // unwindSegue от второго экрана
    
    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {
        guard let addNewPlaceVC = segue.source as? AddNewPlaceViewController else { return }
        addNewPlaceVC.saveNewController()
        tableView.reloadData()
    }

}
