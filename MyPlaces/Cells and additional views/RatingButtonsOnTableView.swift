//
//  RatingButtonsOnTableView.swift
//  MyPlaces
//
//  Created by pro2017 on 28/01/2021.
//

import UIKit

class RatingButtonsOnTableView: UIStackView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        createButton()
    }
    
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        createButton()
    }
    
    // MARK: Создание кнопки
    private func createButton() {
        
        for _ in 0..<5 {
            // Создание кнопки
            let button = UIButton()
            button.backgroundColor = .purple
            
            // Констрейнты кнопки
            button.translatesAutoresizingMaskIntoConstraints = false
            button.heightAnchor.constraint(equalToConstant: 20).isActive = true
            button.widthAnchor.constraint(equalToConstant: 20).isActive = true
            
            
            // Добавление кнопки
            addArrangedSubview(button)
        }
    }
}
