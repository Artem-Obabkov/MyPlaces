//
//  MainTableView.swift
//  MyPlaces
//
//  Created by pro2017 on 18/01/2021.
//

import UIKit
import RealmSwift

class MainTableView: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // Создаем экземпляр класс UISearchBar -------------------------------------------
    private let searchController = UISearchController(searchResultsController: nil)
    
    // Создаем массив отсортированных элементов
    private var filteredPlaces: Results<Place>!
    
    // Переменная, определяющая есть ли символы в строке поиска
    private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else { return false }
        return text.isEmpty
    }
    
    // Переменная, определяющая показан ли SearchBar и есть ли в нем символы
    private var searchBarIsShown: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }

    
    // Создаем экземпляр results с типом данных place. Он работает аналогично массиву ---------------
    private var places: Results<Place>!
    
    // Вспомогательная переменная для сортировки в алфавитном порядке и обратно
    private var ascending = true
    
    
    @IBOutlet weak var tableView: UITableView!
    // Оутлеты для сортировки
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var reverseButton: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
        
        // Отображаем сохраненные объекты в базе данных. Указываем Place.self, т.к нужно указать ИМЕННО тип 
        places = realm.objects(Place.self)
        
        
        
        // Настраиваем SearchController -------------------------------------------------------
        
        // Получатель информации об изменении строки SearchController - a является сам класс
        searchController.searchResultsUpdater = self
        
        // Разрешаем пользователю взаимодействовать с ViewController, пока открыт SearchController
        searchController.obscuresBackgroundDuringPresentation = false
        
        // Присваиваем текст Placeholder - у
        searchController.searchBar.placeholder = "Search"
        
        // Интегрируем SearchController в NavigationBar
        navigationItem.searchController = searchController
        
        // Отпускаем SearchController при переходе на другой экран
        definesPresentationContext = true
        
        // Позволяет скрыть строку поиска при запуске приложения
        searchController.isActive = false
    }
    

    // MARK: - Table view data source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //В зависимости от searchBarIsShown показывается либо массив places, либо filteredPlaces
        
        if searchBarIsShown {
            return filteredPlaces.count
        }
        return places.isEmpty ? 0 : places.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as! CustomCell
        
        // Работа со звездами. В каждой новой ячейки изначально все звезды пустые, а после второго цикла заполняются нужными элементами
        for star in cell.ratingStars {
            star.image = UIImage()
        }
        
        // Создаем экземпляр модели данных
        var place: Place
        
        if searchBarIsShown {
            place = filteredPlaces[indexPath.row]
        } else {
            place = places[indexPath.row]
        }

        cell.nameLabel.text = place.name
        cell.locationLabel.text = place.location
        cell.typeLabel.text = place.type
        
        // Конвентируем изображение
        cell.imageOfPlace.image = UIImage(data: place.imageData!)
        
        // Работа со звездами рейтинга ----------------------------------------------------
        let rating = Int(place.rating)
        
        // Переворачиваем массив. Все зависит от того в какой последовательности мы добавляли UIImageView в массив оутлетов в CustomCell. Используется если мы заменяем изображения, а не скрываем их
//        let reversedRatingStars: [UIImageView] = cell.ratingStars.reversed()

        for index in 0..<rating {
            let star = cell.ratingStars[index]
            star.image = #imageLiteral(resourceName: "filledStar")
        }
        

        // Делаем изображение круглым
        cell.imageOfPlace.layer.cornerRadius = cell.imageOfPlace.frame.height / 2
        cell.imageOfPlace.contentMode = .scaleAspectFill
        cell.imageOfPlace.clipsToBounds = true

        return cell
    }
    
    // MARK: Tabel View Delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
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
            
            // Экземпляр модели данных
            var place: Place
            
            // В зависимости от searchBarIsShown мы будем передавать элемент с индексом присущим определенному массиву
            if searchBarIsShown {
                place = filteredPlaces[indexPath.row]
            } else {
                place = places[indexPath.row]
            }
            
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

// MARK: Расширение для SearchController
extension MainTableView: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        
        sorting(searchController.searchBar.text!)
        
    }
    
    // Создаем метод сортировки элементов
    
    private func sorting(_ searchText: String) {
        
        filteredPlaces = places.filter("name CONTAINS[c] %@ OR location CONTAINS[c] %@ OR type CONTAINS[c] %@", searchText, searchText, searchText)
        tableView.reloadData()
        
    }
    
}
