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
    
    private var todo: Todos?
    weak var delegate: TodoDetailViewControllerDelegate?
    private var presenter: TodoDetailPresenterProtocol!
    private let todoInputView = TodoInputView()
    
    init(todo: Todos? = nil) {
        self.todo = todo
        super.init(nibName: nil, bundle: nil)
        self.presenter = TodoDetailPresenter(view: self, todo: todo)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never

        setupUI()
        configureNavigation()
        loadTodoData()
        todoInputView.titleTextView.delegate = self
    }
    
    // MARK: - Настройка UI
    private func setupUI() {
        
        view.backgroundColor = .systemBackground
        
        view.addSubview(todoInputView)
        todoInputView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            todoInputView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            todoInputView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            todoInputView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            todoInputView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    private func configureNavigation() {
        title = todo == nil ? "Новая задача" : "Редактировать задачу"
        let backButton = BackButton(target: self, action: #selector(backButtonTapped))
        navigationItem.leftBarButtonItem = backButton.getBarButtonItem()
    }
    
    // MARK: - Загрузка данных
    private func loadTodoData() {
        guard let todo = todo else {
            todoInputView.titleTextView.becomeFirstResponder()
            return
        }
        todoInputView.titleTextView.text = todo.todo
        todoInputView.descriptionTextView.text = todo.descriptionText
    }
    
    // MARK: - Сохранение данных backButton
    @objc private func backButtonTapped() {
        presenter.saveTodo(
            title: todoInputView.titleTextView.text ?? "",
            description: todoInputView.descriptionTextView.text ?? ""
        )
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITextViewDelegate обработка ввода текста
extension TodoDetailVC: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView == todoInputView.titleTextView && text == "\n" {
            todoInputView.descriptionTextView.becomeFirstResponder()
            return false
        }
        return true
    }
}

// MARK: - TodoDetailViewProtocol обновление интерфейса (сохранение задачи, ошибка)
extension TodoDetailVC: TodoDetailViewProtocol {
    func didSaveTodo() {
        delegate?.didSaveTodo()
    }
    
    func showError(_ message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
