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
        
        // Создаем StackView для правильного выравнивания
        let stackView = UIStackView(arrangedSubviews: [countLabel])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 8
        
        // Создаем UIBarButtonItem с кастомным view
        let countItem = UIBarButtonItem(customView: stackView)
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        setItems([flexibleSpace, countItem, flexibleSpace, addButton], animated: false)
    }
    
    // MARK: - Публичные методы
    func updateCount(_ count: Int) {
//        let formattedCount = String(count)
        countLabel.text = tasksString(for: count)

//        countLabel.text = "\(formattedCount) задач"
    }
    
    func setAddTarget(_ target: Any?, action: Selector) {
//        addButton.target = target
        addButton.action = action
    }
    
    func tasksString(for count: Int) -> String {
        switch count % 10 {
        case 1 where count % 100 != 11:
            return "\(count) задача"
        case 2...4 where (count % 100 < 10) || (count % 100 >= 20):
            return "\(count) задачи"
        default:
            return "\(count) задач"
        }
    }
}
