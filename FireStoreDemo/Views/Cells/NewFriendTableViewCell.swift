//
//  NewFriendTableViewCell.swift
//  FireStoreDemo
//
//  Created by Gokul on 04/08/20.
//  Copyright © 2020 Gokul. All rights reserved.
//

import UIKit

class NewFriendTableViewCell: UITableViewCell {

    static let cellIdentifier = "NewFriendCell"
    
    var nameLabel = UILabel()
    var dpImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubViews()
        constrainViews()
        adjustViewStyle()
        dpImageView.image = UIImage(named: "test")
        self.backgroundColor = UIColor.getColor(R: 38, G: 36, B: 49)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func constrainViews() {
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        dpImageView.translatesAutoresizingMaskIntoConstraints = false
        
        nameLabel.textColor = .white
        
        dpImageView.width(60)
        dpImageView.height(60)
        dpImageView.centerY(to: self)
        dpImageView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 25).isActive = true
        dpImageView.layer.masksToBounds = false
        dpImageView.layer.cornerRadius = 30
        dpImageView.clipsToBounds = true
        
        let stackView = UIStackView(arrangedSubviews: [nameLabel])
        stackView.axis = .vertical
        addSubview(stackView)
        stackView.centerY(to: self)
        nameLabel.height(30)
        stackView.height(50)
        stackView.leadingAnchor.constraint(equalTo: self.dpImageView.trailingAnchor, constant: 14).isActive = true
    }
    
    private func adjustViewStyle() {
           nameLabel.font = UIFont.boldSystemFont(ofSize: 18)
       }
    
    private func addSubViews() {
        addSubview(dpImageView)
    }
}
