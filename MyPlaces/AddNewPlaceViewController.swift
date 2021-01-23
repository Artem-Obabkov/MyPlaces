//
//  AddNewPlaceViewController.swift
//  MyPlaces
//
//  Created by pro2017 on 20/01/2021.
//

import UIKit

class AddNewPlaceViewController: UITableViewController {
    
    // Эта переменная будет использоваться для определения, было ли изображение измененно или нет
    var isImageChanged = false
    
    // Оутлет кнопки
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    // Оутлеты
    @IBOutlet weak var placeImage: UIImageView!
    @IBOutlet weak var placeName: UITextField!
    @IBOutlet weak var placeLocation: UITextField!
    @IBOutlet weak var placeType: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Убираем пустые строки таблицы, путем присвоения им пустого view
        tableView.tableFooterView = UIView()
        
        // Кнопка save при закгрузке view не доступна
        saveButton.isEnabled = false
        
        // Позволяет следить за изменением определенного оутлета (в данном случае placeName) в реальном времени и применять какую-нибудь логику
        placeName.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        
    }
    
    // MARK: Table view delegate
    
    // Данный метод отвечает за скрытие клавиатуры при нажатии на экран в любой точке, кроме поверхности первой ячейки
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Если индекс выбранной ячейки равен 0, то будет отрабатывать логика
        if indexPath.row == 0 {
            
            // Создаем константы с изображением, используя Image Literal
            let cameraIcon = #imageLiteral(resourceName: "camera")
            let libraryIcon = #imageLiteral(resourceName: "photo")
            
            // Создаем массив действий
            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            // Создаем сами действия
            
            let camera = UIAlertAction(title: "Camera", style: .default) { _ in
                self.chooseImagePickerType(source: .camera)
            }
            
            // Добавляем изображение к UIAlertAction, а затем перемезаем текст в левую часть
            camera.setValue(cameraIcon, forKey: "image")
            camera.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            
            let photo = UIAlertAction(title: "Photo", style: .default) { _ in
                self.chooseImagePickerType(source: .photoLibrary)
            }
            
            // Добавляем изображение к UIAlertAction, а затем перемезаем текст в левую часть
            photo.setValue(libraryIcon, forKey: "image")
            photo.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel)
            
            // Добавляем действия в массив actionSheet
            actionSheet.addAction(camera)
            actionSheet.addAction(photo)
            actionSheet.addAction(cancel)
            
            // Вызываем наш alertController
            present(actionSheet, animated: true, completion: nil)
            
        } else {
            // Скрытие клавиатуры
            
            view.endEditing(true)
        }
        
    }
    
    // Метод отвечает за присвоение значений к экземплару структуры, созданной в самом начале класса
    func saveNewController() {
        
        // В зависимости от значения подставляем нужное изображение. Для удобства создана дополнительная переменная
        var image: UIImage?
        
        if isImageChanged {
            image = placeImage.image
        } else {
            image = #imageLiteral(resourceName: "imagePlaceholder")
        }
        
        // Конвентируем изображение
        let imageData = image?.pngData()
        
        // В placeName.text мы можем указать force unwraping, т.к кнопка save работает только в том случае, когда в placeName есть хоть какое-нибудь значение
        // Создаем экземпляр типа place
        let newPlace = Place(name: placeName.text!, location: placeLocation.text, type: placeType.text, imageData: imageData)
        
        // Сохраняем созданный экземпляр класса в базу данных
        StorageManager.saveData(newPlace)
    }
}

// MARK: Text Field Delegate
// Отвечает за скрытие клавиатуры при нажатии на return key
extension AddNewPlaceViewController: UITextFieldDelegate {
    
    // Скрытие клавиатуры при нажатии на кнопку done
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // Метод для placeName.addTarget. Используется для активации кнопки save
    @objc func textFieldChanged() {
        if placeName.text?.isEmpty == false {
            saveButton.isEnabled = true
        } else {
            saveButton.isEnabled = false
        }
    }
    
}

// MARK: Work with image
extension AddNewPlaceViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // Метод, позволяющий открыть либо галерею изображений, либо камеру, в зависимости от подставленного значения
    func chooseImagePickerType(source: UIImagePickerController.SourceType) {
        
        if UIImagePickerController.isSourceTypeAvailable(source) {
            
            let imagePicker = UIImagePickerController()
            // Создаем делегату
            imagePicker.delegate = self
            
            // Разрешаем редактирование
            imagePicker.allowsEditing = true
            
            // Присваеваем указанный тип
            imagePicker.sourceType = source
            
            // Показываем меню выбора фотографий
            present(imagePicker, animated: true)
            
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        // Присваиваем нашему оутлету выбранное изображение типа .editedImage
        placeImage.image = info[.editedImage] as? UIImage
        
        // Настраиваем площадь его заполнения и размер изображение
        placeImage.contentMode = .scaleAspectFill
        placeImage.clipsToBounds = true
        
        // Т.к изображение было изменено, мы меняем значение
        isImageChanged = true
        
        // Отключаем наш UIAlertController
        dismiss(animated: true)
        
        // Этот метод делегирует свои обязанности объекту с типом данных UIImagePickerController, а сам класс являетс делегатом, т.е исполнителем задачи
    }
    
    // Присваиваем выбранное изображение из галереи в наш оутлет
    
    
}
