//
//  TodoInputView.swift
//  Todos
//
//  Created by Vika on 24.02.25.
//


import UIKit

class TodoInputView: UIView {
    
    let titleTextView: UITextView = {
        let textView = UITextView()
        textView.font = .boldSystemFont(ofSize: 34)
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.isScrollEnabled = false
        textView.returnKeyType = .next
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    let descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 16, weight: .regular)
        textView.isEditable = true
        textView.isUserInteractionEnabled = true
        textView.returnKeyType = .default
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(titleTextView)
        addSubview(descriptionTextView)
        
        NSLayoutConstraint.activate([
            titleTextView.topAnchor.constraint(equalTo: topAnchor),
            titleTextView.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleTextView.trailingAnchor.constraint(equalTo: trailingAnchor),
            titleTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 50),
            
            descriptionTextView.topAnchor.constraint(equalTo: titleTextView.bottomAnchor, constant: 20),
            descriptionTextView.leadingAnchor.constraint(equalTo: leadingAnchor),
            descriptionTextView.trailingAnchor.constraint(equalTo: trailingAnchor),
            descriptionTextView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
