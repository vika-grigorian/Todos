//
//  TodoCell.swift
//  Todos
//
//  Created by Vika on 21.02.25.
//

import UIKit

class TodoCell: UITableViewCell {
    
    static let identifier = "TodoCell"
    
    private var todoItem: Todos?
    
    private let checkBox: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "circle"), for: .normal)
        button.setImage(UIImage(systemName: "checkmark.circle"), for: .selected)
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.numberOfLines = 2
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .gray
        label.numberOfLines = 2
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .lightGray
        label.textAlignment = .right
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(checkBox)
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(dateLabel)
        
        checkBox.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            checkBox.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            checkBox.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            checkBox.widthAnchor.constraint(equalToConstant: 24),
            checkBox.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.leadingAnchor.constraint(equalTo: checkBox.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            
            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            
            dateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            dateLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 4),
            dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
        
        checkBox.addTarget(self, action: #selector(didTapCheckBox), for: .touchUpInside)
    }
    
    func configure(with todo: Todos) {
        self.todoItem = todo
        titleLabel.text = todo.todo
        descriptionLabel.text = (todo.descriptionText?.isEmpty ?? true) ? "Нет дополнительного текста" : todo.descriptionText
        dateLabel.text = formatDate(todo.date)
        
        checkBox.isSelected = todo.completed
        checkBox.tintColor = todo.completed ? .systemYellow : .systemGray
        
        if todo.completed {
            titleLabel.textColor = .darkGray
            titleLabel.attributedText = NSAttributedString(string: todo.todo ?? "",
                                                           attributes: [.strikethroughStyle: NSUnderlineStyle.single.rawValue])
            descriptionLabel.textColor = .gray
        } else {
            titleLabel.textColor = traitCollection.userInterfaceStyle == .dark ? .white : .black
            titleLabel.attributedText = NSAttributedString(string: todo.todo ?? "",
                                                           attributes: [.strikethroughStyle: []])
            descriptionLabel.textColor = traitCollection.userInterfaceStyle == .dark ? .white : .black
        }
        
        dateLabel.textColor = .gray
    }
    
    @objc private func didTapCheckBox() {
        checkBox.isSelected.toggle()
        
        if let todo = todoItem {
            todo.completed = checkBox.isSelected
            configure(with: todo)
        }
    }
    
    private func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "Нет даты" }
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
