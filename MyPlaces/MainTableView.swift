//
//  MainTableView.swift
//  MyPlaces
//
//  Created by pro2017 on 18/01/2021.
//

import UIKit
import RealmSwift

class MainTableView: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // Оутлеты для сортировки
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var reverseButton: UIBarButtonItem!
    
    
    // Вспомогательная переменная для сортировки в алфавитном порядке и обратно
    var ascending = true
    
    
    @IBOutlet weak var tableView: UITableView!
    
    // Создаем экземпляр results с типом данных place. Он работает аналогично массиву
    var places: Results<Place>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Отображаем сохраненные объекты в базе данных. Указываем Place.self, т.к нужно указать ИМЕННО тип 
        places = realm.objects(Place.self)
        
    }

    // MARK: - Table view data source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.isEmpty ? 0 : places.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
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
    
    // Кнопка сортировки
    @IBAction func reverseButtonAction(_ sender: UIBarButtonItem) {
        
        // Меняем значение вспомогательной переменной, отвечающей за сортировку в обратном порядке
        ascending.toggle()
        
        if ascending {
            reverseButton.image = #imageLiteral(resourceName: "AZ")
        } else {
            reverseButton.image = #imageLiteral(resourceName: "ZA")
        }
        
        sorting()
        
    }
    
    // Segmented Control сортировка
    @IBAction func segmentedControlAction(_ sender: UISegmentedControl) {
        
        sorting()
        
    }
    
    // Приватный метод, отвечающий за сортировку элементов
    private func sorting() {
        
        // Проверяем индекс текущего элемента, и в зависимости от него применяем разные сортировки
        if segmentedControl.selectedSegmentIndex == 0 {
            places = places.sorted(byKeyPath: "date", ascending: ascending)
        } else {
            places = places.sorted(byKeyPath: "name", ascending: ascending)
        }
        
        tableView.reloadData()
        
    }
    
    // unwindSegue от второго экрана
    
    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {
        guard let addNewPlaceVC = segue.source as? AddNewPlaceViewController else { return }
        addNewPlaceVC.saveController()
        tableView.reloadData()
    }

}
