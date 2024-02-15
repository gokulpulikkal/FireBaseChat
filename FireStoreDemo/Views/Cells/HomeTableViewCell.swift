//
//  HomeTableViewCell.swift
//  FireStoreDemo
//
//  Created by Gokul on 18/06/20.
//  Copyright © 2020 Gokul. All rights reserved.
//

import UIKit

class HomeTableViewCell: UITableViewCell {
    
    static let cellIdentifier = "HomeCell"

    var nameLabel = UILabel()
    var timeLabel = UILabel()
    var recentMessage = UILabel()
    var newMessageView = UIView()
    var dpImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubViews()
        constrainViews()
        adjustViewStyle()
        dpImageView.image = UIImage(named: "test")
        recentMessage.text = "Haai"
        timeLabel.text = "9:00 PM"
        self.backgroundColor = UIColor.getColor(R: 38, G: 36, B: 49)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func constrainViews() {
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        recentMessage.translatesAutoresizingMaskIntoConstraints = false
        dpImageView.translatesAutoresizingMaskIntoConstraints = false
        newMessageView.translatesAutoresizingMaskIntoConstraints = false
        
        dpImageView.width(60)
        dpImageView.height(60)
        dpImageView.centerY(to: self)
        dpImageView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 25).isActive = true
        dpImageView.layer.masksToBounds = false
        dpImageView.layer.cornerRadius = 30
        dpImageView.contentMode = .scaleAspectFill
        dpImageView.clipsToBounds = true
        
        newMessageView.width(22)
        newMessageView.height(22)
        newMessageView.layer.cornerRadius = 11
        newMessageView.clipsToBounds = true
        newMessageView.backgroundColor = .yellow
        
        nameLabel.textColor = .white
        
        let label = UILabel()
        label.text = "1"
        newMessageView.addSubview(label)
        label.textColor = .black
        label.centerInSuperview()
        addSubview(newMessageView)
        newMessageView.centerYToSuperview()
        newMessageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10).isActive = true
        
        let stackView = UIStackView(arrangedSubviews: [nameLabel, recentMessage])
        stackView.axis = .vertical
        addSubview(stackView)
        stackView.centerY(to: self)
        nameLabel.height(30)
        recentMessage.height(30)
        stackView.height(50)
        stackView.leadingAnchor.constraint(equalTo: self.dpImageView.trailingAnchor, constant: 14).isActive = true
        
        timeLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -10).isActive = true
        timeLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 20).isActive = true
        
        recentMessage.isHidden = true
        timeLabel.isHidden = true
        newMessageView.isHidden = true
    }
    
    private func adjustViewStyle() {
        nameLabel.font = UIFont.boldSystemFont(ofSize: 18)
        recentMessage.font = UIFont.systemFont(ofSize: 15)
        timeLabel.font = UIFont.systemFont(ofSize: 13)
    }
    
    private func addSubViews() {
        addSubview(timeLabel)
        addSubview(dpImageView)
    }

}
