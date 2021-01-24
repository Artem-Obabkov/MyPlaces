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
        cell.imageOfPlace.contentMode = .scaleAspectFill
        cell.imageOfPlace.clipsToBounds = true

        return cell
    }
    
    // MARK: Tabel View Delegate
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            let place = places[indexPath.row]
            StorageManager.deleteObject(place)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        }
        
    }
    
    
    
    // MARK: - Navigation

    // Подготавливаем данные для редактирования их
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showEditScreen" {
            
            // Создаем indexPath
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            
            // Создаем экземпляр ячейки для передачи во второй ViewController
            let place = places[indexPath.row]
            
            // Создаем экземпляр второго ViewContoller - a
            let editVC = segue.destination as! AddNewPlaceViewController
            
            // Передаем значение place в свойство второго viewController - a
            editVC.editPlace = place
            
        }
        
    }
    
    
    // unwindSegue от второго экрана
    
    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {
        guard let addNewPlaceVC = segue.source as? AddNewPlaceViewController else { return }
        addNewPlaceVC.saveController()
        tableView.reloadData()
    }

}
