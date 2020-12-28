//
//  ChatCell.swift
//  FireStoreDemo
//
//  Created by Gokul on 12/08/20.
//  Copyright © 2020 Gokul. All rights reserved.
//

import UIKit

class ChatCell: UICollectionViewCell {
    
    static let cellIdentifier = "ChatCell"
    var textViewLeadingAnchor: NSLayoutConstraint?
    var textViewTrailingAnchor: NSLayoutConstraint?
    
    let textLabel: UILabel = {
        let tv = UILabel(frame: .zero)
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.numberOfLines = 0
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = .clear
        return tv
    }()
    
    let bubbleBackgroundView: UIView = {
        let bbv = UIView(frame: .zero)
        bbv.translatesAutoresizingMaskIntoConstraints = false
        bbv.layer.cornerRadius = 5
        return bbv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addViews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addViews() {
        addSubview(bubbleBackgroundView)
        addSubview(textLabel)
        
        textViewLeadingAnchor = textLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32)
        textViewTrailingAnchor = textLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32)
        textViewLeadingAnchor?.isActive = true
        textViewTrailingAnchor?.isActive = false
        textLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
        textLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20).isActive = true
        textLabel.widthAnchor.constraint(lessThanOrEqualToConstant: self.frame.width - 100 ).isActive = true
        bubbleBackgroundView.leadingAnchor.constraint(equalTo: textLabel.leadingAnchor, constant: -16).isActive = true
        bubbleBackgroundView.trailingAnchor.constraint(equalTo: textLabel.trailingAnchor, constant: 16).isActive = true
        bubbleBackgroundView.bottomAnchor.constraint(equalTo: textLabel.bottomAnchor, constant: 16).isActive = true
        bubbleBackgroundView.topAnchor.constraint(equalTo: textLabel.topAnchor, constant: -16).isActive = true
        
    }
    
    func setDataToViews(chatData: BaseChatModel) {
        textLabel.text = chatData.message
    }
}
