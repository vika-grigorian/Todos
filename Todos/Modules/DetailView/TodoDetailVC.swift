//
//  TodoDetailViewController.swift
//  Todos
//
//  Created by Vika on 23.02.25.
//


import UIKit
import CoreData

protocol TodoDetailViewControllerDelegate: AnyObject {
    func didSaveTodo()
}

class TodoDetailVC: UIViewController {
    
    // MARK: - Свойства
    private var todo: Todos?
    weak var delegate: TodoDetailViewControllerDelegate?
    private let coreDataManager = CoreDataManager.shared
    
    // UI элементы
    private let titleTextField: UITextField = {
        let textField = UITextField()
        textField.font = .boldSystemFont(ofSize: 34)
        textField.placeholder = "Название задачи"
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 16, weight: .regular)
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.borderWidth = 1.0
        textView.layer.cornerRadius = 8.0
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    // MARK: - Инициализация
    init(todo: Todos? = nil) {
        self.todo = todo
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Жизненный цикл
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureNavigation()
        loadTodoData()
    }
    
    // MARK: - Настройка UI
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(titleTextField)
        view.addSubview(descriptionTextView)
        
        NSLayoutConstraint.activate([
            titleTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            descriptionTextView.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 20),
            descriptionTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            descriptionTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            descriptionTextView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    private func configureNavigation() {
        title = todo == nil ? "Новая задача" : "Редактировать задачу"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "< Назад", style: .plain, target: self, action: #selector(backButtonTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Сохранить", style: .done, target: self, action: #selector(saveButtonTapped))
    }
    
    // MARK: - Загрузка данных
    private func loadTodoData() {
        guard let todo = todo else {
            titleTextField.becomeFirstResponder() // Курсор на поле заголовка для новой задачи
            return
        }
        titleTextField.text = todo.todo
        descriptionTextView.text = todo.descriptionText
    }
    
    // MARK: - Действия
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func saveButtonTapped() {
        guard let title = titleTextField.text, !title.isEmpty else {
            showError("Название задачи не может быть пустым")
            return
        }
        
        let context = coreDataManager.context
        if let existingTodo = todo {
            // Редактирование существующей задачи
            existingTodo.todo = title
            existingTodo.descriptionText = descriptionTextView.text
            existingTodo.date = Date()
        } else {
            // Создание новой задачи
            let newTodo = Todos(context: context)
            newTodo.id = Int64(Date().timeIntervalSince1970)
            newTodo.todo = title
            newTodo.descriptionText = descriptionTextView.text
            newTodo.completed = false
            newTodo.userId = 1
            newTodo.date = Date()
        }
        
        do {
            try context.save()
            delegate?.didSaveTodo()
            navigationController?.popViewController(animated: true)
        } catch {
            showError("Ошибка при сохранении: \(error.localizedDescription)")
        }
    }
    
    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
