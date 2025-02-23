//
//  TodosToolbar.swift
//  Todos
//
//  Created by Vika on 23.02.25.
//


import UIKit

class TodosToolbar: UIToolbar {

    // MARK: - Свойства
    private let countLabel = UILabel()
    private let addButton = UIBarButtonItem(image: UIImage(systemName: "square.and.pencil"), style: .plain, target: nil, action: nil)
    
    // MARK: - Инициализация
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Настройка UI
    private func setupUI() {
        countLabel.text = "0 задач"
        countLabel.textAlignment = .center
        countLabel.textColor = .label
        countLabel.font = UIFont.systemFont(ofSize: 16)
        addButton.tintColor = .systemYellow

//        countLabel.sizeToFit()
        
        let countItem = UIBarButtonItem(customView: countLabel)
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        setItems([countItem, flexibleSpace, addButton], animated: false)
    }
    
    private func configureConstraints() {
            translatesAutoresizingMaskIntoConstraints = false
    }
    
    // MARK: - Публичные методы
    func updateCount(_ count: Int) {
        let formattedCount = String(count)
        countLabel.text = "\(formattedCount) задач"
    }
    
    func setAddTarget(_ target: Any?, action: Selector) {
//        addButton.target = target
        addButton.action = action
    }
}
