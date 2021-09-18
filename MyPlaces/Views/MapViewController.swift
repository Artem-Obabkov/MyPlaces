//
//  MapViewController.swift
//  MyPlaces
//
//  Created by pro2017 on 28/01/2021.
//

import UIKit
import MapKit
import CoreLocation

// Этот протокол используется для передачи адреса на NewPlaceVC. При вызове метода он сохраняет значение текущего VC и потос при вызове в другом VC можно просто использовать это значение
protocol MapViewControllerDelegate {
    func getAddress(_ address: String?)
}

class MapViewController: UIViewController {
    
    // MARK: Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var currentAdress: UILabel!
    @IBOutlet weak var centerMarker: UIImageView!
    @IBOutlet weak var sendAdressButton: UIButton!
    @IBOutlet weak var getDirection: UIButton!
    
    
    // MARK: Properties
    
    // Объявляем свойство с типом данных MapViewControllerDelegate. Последующая работа в IBAction кнопки Done
    var mapViewControllerDelegate:  MapViewControllerDelegate?
    
    // Сюда передаются данные с AddNewPlaceViewController
    var place = Place()
    
    // ID - для создания меток с кастомным стилем
    let customAnnotationID = "annotationID"
    
    let locationManager = CLLocationManager()
    let regionInMeters = 0_400.00
    var incomeIdentifier = ""
    var userCoordinate: CLLocationCoordinate2D?
    
    // Массив,для удалеления старых маршрутов при постройке новых
    var previousDirections: [MKDirections] = []
    
    // Предыдущее местоположение пользователя, инициализируется это свойство начальными координатами пользователя в методе goDirection(). В observer - е мы будем вызывать метод по отслеживанию пользователя
    var previousLocation: CLLocation? {
        didSet {
            startTrackingUserLocation()
        }
    }
    
    //MARK: Overriden funcs
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        currentAdress.text = ""
        isGeolocationEnabled()
        showPlace()
    }
    
    // Выравниваем mapView по пользователю
    @IBAction func centerViewAtUser() {
        showUserLocation()
    }
    
    @IBAction func createDirectionButton() {
        createDirections()
    }
    
    @IBAction func sendAdressToNewPlaceVC(_ sender: Any) {
        
        // Вызываем метод протокола и передаем ему значение текущего адреса
        mapViewControllerDelegate?.getAddress(currentAdress.text)
        dismiss(animated: true)
        
        // После чего идем в extension NewPlaceVC подписанный на протокол MapViewControllerDelegate
    }
    
    @IBAction func close() {
        dismiss(animated: true)
    }
    
    
    //MARK: Action funcs
    
    private func showPlace() {

        getDirection.isHidden = true
        
        if incomeIdentifier == "showPlace" {
            
            setupPlacemark()
            currentAdress.isHidden = true
            centerMarker.isHidden = true
            sendAdressButton.isHidden = true
            getDirection.isHidden = false
        }
    }
    
    private func setupPlacemark() {
        
        // Проверяем есть ли адрес
        guard let location = place.location else { return }
        
        let geocoder = CLGeocoder()
        
        // Настрока метки
        geocoder.geocodeAddressString(location) { (placemarksOptionl, error) in
            
            if let error = error {
                print(error)
                return
            }
            
            // Извлекаем опционал из массива placemarksOptional
            guard let placemarks = placemarksOptionl else { return }
            
            let placemark = placemarks.first
            
            // Создаем метку
            let annotation = MKPointAnnotation()
            
            annotation.title = self.place.name
            annotation.subtitle = self.place.type
            
            // Извлекаем опциональный адрес из placemark в виде координат
            guard let placemarkLocation = placemark?.location else { return }
            
            // Присваеваем метке координаты первого элемента массива
            annotation.coordinate = placemarkLocation.coordinate
            
            self.userCoordinate = placemarkLocation.coordinate
            
            // Показываем список меток на карте
            self.mapView.showAnnotations([annotation], animated: true)
            
            // Выделяем метку на карте
            self.mapView.selectAnnotation(annotation, animated: true)
        }
    }
    
    // Метод отвечает за проверку разрешено использовать геолокацию телефона приложением
    private func isGeolocationEnabled() {
        
        if CLLocationManager.locationServicesEnabled() {
            setupUserLocation()
            allowedTypeOfUserGeolocation()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.createAlert(title: "Упс... Геолокация не включена", message: "Вам нужно ее включить. Вот как это можно сделать: Настройки -> Конфиденциальность -> Службы геолокации"
                )
            }
        }
    }
    
    // Метод отвечает за настройку точности определения местоположения
    private func setupUserLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    // Определяем способ отслеживания
    private func allowedTypeOfUserGeolocation() {
        
        switch locationManager.authorizationStatus {
        
        // Геолокация используется только во время работы приложения
        case .authorizedWhenInUse:
            
            mapView.showsUserLocation = true
            
            // Если мы хотип получить адрес
            if incomeIdentifier == "getAdress" {
                showUserLocation()
            }
            break
        
        // Отслеживание местонахождения пользователя запрещено. Показывается уведомление.
        case .denied:
            createAlert(title: "Упс... Геолокация не включена", message: "Вам нужно ее включить. Вот как это можно сделать: Настройки -> Конфиденциальность -> Службы геолокации"
            )
            break
        
        // Вызывается в том случае, когда пользователь еще не выбирал способ отслеживания.
        // !!! В info.plist в строке Location When In Use объясняется зачем нашему приложению использовать геолокацию
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            
        // Определение локации ограничено через настройки. Показываем уведомление
        case .restricted:
            createAlert(title: "Упс... Геолокация не включена", message: "Вам нужно ее включить. Вот как это можно сделать: Настройки -> Конфиденциальность -> Службы геолокации"
            )
            break
            
        // Срабатывает, когда местоположение пользователя определяется постоянно
        case .authorizedAlways:
            break
            
        // Если будет добавлена новая функция вызовется этот default блок 
        @unknown default:
            print("Новая фича появилась")
        }
    }
    
    // Уведомление
    private func createAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        
        let doneButton = UIAlertAction(title: "Понял!", style: .default, handler: nil)
        alert.addAction(doneButton)
        present(alert, animated: true, completion: nil)
    }
    
    // Находим координаты центра экрана, того места, где находится пользователь
    private func getUserLocation(for mapView: MKMapView) -> CLLocation {
        
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    // Фокусируемся на метстоположении пользователя
    private func showUserLocation() {
        
        // Определяется ли местоположение пользователя
        if let location = locationManager.location?.coordinate {
            
            // Определяем радиус показываемой территории, в центре - пользователь
            let region = MKCoordinateRegion(center: location,
                                            latitudinalMeters: regionInMeters,
                                            longitudinalMeters: regionInMeters)
            
            // Отображаем определенные координаты на mapView
            mapView.setRegion(region, animated: true)
        }
    }
    
    // Метод, фокусирующий карту на пользователе при изменении его местоположения
    private func startTrackingUserLocation() {
        
        guard let previousLocation = previousLocation else { return }
        
        // Находим текущие координаты центра отображаемой области
        let center = getUserLocation(for: mapView)
        
        // Проверяем смещение пользователя
        guard center.distance(from: previousLocation) > 50 else { return }
        
        // Перемещаем координаты предыдущей точки на координаты текущей
        self.previousLocation = center
        
        // Задержка 3 секунды до фокусировки карты.
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.showUserLocation()
        }
    }
    
    // Удаляем предыдущие маршруты.
    private func replaceOldDirections(with directions: MKDirections) {
        
        mapView.removeOverlays(mapView.overlays)
        previousDirections.append(directions)
        
        // Перебираем все маршруты и отключаем их
        let _ = previousDirections.map { $0.cancel() }
        previousDirections.removeAll()
        
        // Вызываем его перед добавлением новых маршрутов.
    }
    
    // MARK: Строим маршрут
    
    private func createDirections() {
        
        // Определяется ли местоположение пользователя
        guard let location = locationManager.location?.coordinate else {
            createAlert(title: "Упс...", message: "Не получается определить ваше местоположение")
            return
        }
        
        // Обновляем местоположение пользователя в настоящем времени, а затем инициализируем предыдущее местоположение пользователя текущими коодинатами
        locationManager.startUpdatingLocation()
        previousLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        
        // В это свойство передается дополнительный метод, который создает запрос на построение маршрута.
        // Но сначала создаем свойство типа CLLocationCoordinate2D, в которое будеи передавать текущее место заведения из метода setupPlacemark
        guard let request = createDirectionRequest(from: location) else {
            createAlert(title: "Упс...", message: "Не удалось построить маршрут")
            return
        }
        
        // Отправляем запрос на построение маршрута
        let direction = MKDirections(request: request)
        
        // Удаляем старые маршруты
        replaceOldDirections(with: direction)
        
        // Расчитываем маршрут, где responce является коллекцией маршрутов, а error - сообщением об ошибке
        direction.calculate { (responce, error) in

            if let error = error {
                print(error)
                return
            }
            
            guard let responce = responce else {
                self.createAlert(title: "Упс...", message: "Не получилось построить маршрут")
                return
            }
            
            for route in responce.routes {
                
                // Создаем точное наложение геометрической фигуры маршрута на карту
                self.mapView.addOverlay(route.polyline)
                
                // Оперделяем область видимости карты в зависимоти от маршрута. Т.е будут видны начало и конец маршрута
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                
                // Определяем длину маршрута и примерное время езды
                let distance = String(format: "%.1f", route.distance / 1000)
                let timeInterval = String(format: "%.1f", route.expectedTravelTime / 60)
                
                print(distance)
                print(timeInterval)
                
                // После чего идем в MKMapViewDelegate, рендерим маршрут и даем ему цвет
            }
        }
    }
    
    // Дополнительная функция
    private func createDirectionRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request? {
        
        // Определяем координаты места назначения
        guard let destinationCoordinate = userCoordinate else { return nil }
        
        // Определяем точки отправки и назначения на карте
        let startLocation = MKPlacemark(coordinate: coordinate)
        let destination = MKPlacemark(coordinate: destinationCoordinate)
        
        // Создаем запрос на построение маршрута от точки startLocation до destination
        let request = MKDirections.Request()
        
        // Указываем начало и конец пути
        request.source = MKMapItem(placemark: startLocation)
        request.destination = MKMapItem(placemark: destination)
        
        // Указываем тип транспорта
        request.transportType = .automobile
        
        // Разрешаем строить альтернативные маршруты
        request.requestsAlternateRoutes = true
        
        return request
    }
}


// MARK: MapViewDelegate

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        // Проверяем не является ли метка только что поставленной пользователем
        guard !(annotation is MKUserLocation) else { return nil }
        
        // Если метка уже есть на карте, то используем ее
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: customAnnotationID) as? MKPinAnnotationView
        
        // Если метки все такие нету, то создаем ее и показываем ее как карточку
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: customAnnotationID)
            annotationView?.canShowCallout = true
        }
        
        // Извлекаем опционал из place.imageData. По его значению будем устанавливать картинку
        if let imageData = place.imageData {
            
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            imageView.layer.cornerRadius = 10
            imageView.clipsToBounds = true
            
            imageView.image = UIImage(data: imageData)
            
            // Добавляем imageView, к аксессуар к карточке метки
            annotationView?.rightCalloutAccessoryView = imageView
            
        }
        return annotationView
    }
    
    
    // Определяем текущий адрес и затем присваиваем его в currentAdress
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        // Определяем центр
        let center = getUserLocation(for: mapView)
        
        let geocoder = CLGeocoder()
        
        // При изменении масштаба карты через 4 секунды она будет автоматически фокусироваться на пользователе
        if incomeIdentifier == "showPlace" && previousLocation != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                self.showUserLocation()
            }
        }
        
        // Отменяем отложенные запросы
        geocoder.cancelGeocode()
        
        // Перевернутый массив меток, которые мы выделяем на карте, т.к мы определяем координаты только центральной точки, то и массив будет состоять из одного элемента
        geocoder.reverseGeocodeLocation(center) { (placemarks, error) in
            
            if let error = error {
                print(error)
                return
            }
            
            guard let placemarks = placemarks else { return }
            let placemark = placemarks.first
            
            let streetName = placemark?.thoroughfare
            let buildNumber = placemark?.subThoroughfare
            
            // Десинхронизируем карту и изменение значения currentAdress
            DispatchQueue.main.async {
                
                // В зависимости от названия улицы и номера дома, мы присваиваем различные значения currentAdress
                if streetName != nil && buildNumber != nil {
                    self.currentAdress.text = "\(streetName!), \(buildNumber!)"
                } else if streetName != nil {
                    self.currentAdress.text = "\(streetName!)"
                } else {
                    self.currentAdress.text = ""
                }
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        // Рендерим маршрут и накладываем его на уже созданный маршрут
        let render = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        render.strokeColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
        
        return render
    }
    
}


// MARK: CLLocationManagerDelegate - позволяет определять в настоящем времени местоположение пользователя

extension MapViewController: CLLocationManagerDelegate {
    
    // ! В методе настройки местоположения объявляем MapViewController как делегату CLLOcationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        allowedTypeOfUserGeolocation()
    }
    
}

