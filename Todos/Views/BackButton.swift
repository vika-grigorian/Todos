//
//  BackButton.swift
//  Todos
//
//  Created by Vika on 24.02.25.
//

import UIKit

class BackButton: UIView {
    
    private let button: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Назад", for: .normal)
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = .systemYellow
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        button.semanticContentAttribute = .forceLeftToRight
        
        return button
    }()
    
    init(target: Any?, action: Selector) {
        super.init(frame: .zero)
        button.addTarget(target, action: action, for: .touchUpInside)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: leadingAnchor),
            button.trailingAnchor.constraint(equalTo: trailingAnchor),
            button.topAnchor.constraint(equalTo: topAnchor),
            button.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    func getBarButtonItem() -> UIBarButtonItem {
        return UIBarButtonItem(customView: self)
    }
}
