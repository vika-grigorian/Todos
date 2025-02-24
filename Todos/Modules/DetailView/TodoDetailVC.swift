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
    private let titleTextView: UITextView = {
        let textView = UITextView()
        textView.font = .boldSystemFont(ofSize: 34)
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.isScrollEnabled = false
        textView.returnKeyType = .next
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    private let descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 16, weight: .regular)
        textView.isEditable = true
        textView.isUserInteractionEnabled = true
        textView.returnKeyType = .default
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
        titleTextView.delegate = self
    }
    
    // MARK: - Настройка UI
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(titleTextView)
        view.addSubview(descriptionTextView)
        
        NSLayoutConstraint.activate([
            titleTextView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            descriptionTextView.topAnchor.constraint(equalTo: titleTextView.bottomAnchor, constant: 20),
            descriptionTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            descriptionTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            descriptionTextView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    private func configureNavigation() {
        title = todo == nil ? "Новая задача" : "Редактировать задачу"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.left"),
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(backButtonTapped))
    }
    
    // MARK: - Загрузка данных
    private func loadTodoData() {
        guard let todo = todo else {
            titleTextView.becomeFirstResponder()
            return
        }
        titleTextView.text = todo.todo
        descriptionTextView.text = todo.descriptionText
    }
    
    // MARK: - Действия
    @objc private func backButtonTapped() {
        let titleText = titleTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        let descriptionText = descriptionTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let context = coreDataManager.context

        if let existingTodo = todo {
            if titleText.isEmpty && descriptionText.isEmpty {
                context.delete(existingTodo)
            } else {
                       existingTodo.todo = titleText
                       existingTodo.descriptionText = descriptionText
                       existingTodo.date = Date()
                   }
        } else {
                if titleText.isEmpty && descriptionText.isEmpty {
                    navigationController?.popViewController(animated: true)
                    return
                } else {
                    let newTodo = Todos(context: context)
                    newTodo.id = Int64(Date().timeIntervalSince1970)
                    newTodo.todo = titleText
                    newTodo.descriptionText = descriptionText
                    newTodo.completed = false
                    newTodo.userId = 1
                    newTodo.date = Date()
                }
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

// MARK: - UITextViewDelegate
extension TodoDetailVC: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView == titleTextView && text == "\n" {
            print("Return нажато в заголовке")
            
            descriptionTextView.becomeFirstResponder()
            return false
        }
        return true
    }
}

extension TodosListVC: TodoDetailViewControllerDelegate {
    func didSaveTodo() {
        presenter?.refreshData()
    }
}
