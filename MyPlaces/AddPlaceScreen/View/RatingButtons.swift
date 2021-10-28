//
//  RatingButtons.swift
//  MyPlaces
//
//  Created by pro2017 on 27/01/2021.
//

import UIKit

// @IBDesignable выдает ошибку, поэтому пока что без него
class RatingButtons: UIStackView {
    
    // MARK: Свойства
    
    // Массив кнопок
    private var ratingButtons = [UIButton]()
    
    // Рейтинг
    var rating = 0 {
        didSet {
            // Каждый раз при выюоре новой кнопки будет вызываться функция, заполняющая звезды
            updateButtonSelection()
        }
    }
    
    // Свойства, для работы с кодом из StoryBoard. didSet позволяет вызывать метод createButtons() при каждом изменении значения этих свойств
    @IBInspectable var starSize: CGSize = CGSize(width: 44.0, height: 44.0) {
        didSet {
            createButtons()
        }
    }
    
    @IBInspectable var starCount: Int = 5 {
        didSet {
            createButtons()
        }
    }
    
    
    // MARK: Инициализация
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createButtons()
    }
    
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        createButtons()
    }
    
    // MARK: Логика работы кнопки
    
    @objc func buttonIsPressed(button: UIButton) {
        
        // Создаем индекс текущей кнопки
        guard let index = ratingButtons.firstIndex(of: button) else { return }
        
        let indexOfSelectedButton = index + 1
        
        if indexOfSelectedButton == rating {
            rating = 0
        } else {
            rating = indexOfSelectedButton
        }
        
    }
    
    
    // MARK: Настройка кнопки
    
    private func createButtons() {
        
        // Удаляем кнопки из массива, это нужно что бы избежать бага, во время которого происходит добавление кнопок к уже существующим вместо их замены
        for button in ratingButtons {
            removeArrangedSubview(button)
            button.removeFromSuperview()
        }
        
        ratingButtons.removeAll()
        
        let bundle = Bundle(for: type(of: self))
        let emptyStar = UIImage(named: "emptyStar", in: bundle, compatibleWith: self.traitCollection)
        let filledStar = UIImage(named: "filledStar", in: bundle, compatibleWith: self.traitCollection)
        let highlightedStar = UIImage(named: "highlightedStar", in: bundle, compatibleWith: self.traitCollection)
        
        
        for _ in 0..<starCount {
            
            // Создаем кнопку
            let button = UIButton()
            
            // Устанавливаем изображение для каждого случая
            button.setImage(emptyStar, for: .normal)
            button.setImage(filledStar, for: .selected)
            button.setImage(highlightedStar, for: .highlighted)
            button.setImage(highlightedStar, for: [.highlighted, .selected])
            
            // Добавляем констрейнты и размеры кнопки
            button.translatesAutoresizingMaskIntoConstraints = false
            button.heightAnchor.constraint(equalToConstant: starSize.height).isActive = true
            button.widthAnchor.constraint(equalToConstant: starSize.width).isActive = true
            
            // Добавляем кнопку в Stack View
            addArrangedSubview(button)
            
            // Логика работы кнопки
            button.addTarget(self, action: #selector(buttonIsPressed(button:)), for: .touchUpInside)
            
            ratingButtons.append(button)
        }
        updateButtonSelection()
    }
    
    private func updateButtonSelection() {
        for (index, button) in ratingButtons.enumerated() {
            button.isSelected = index < rating
        }
    }
}
