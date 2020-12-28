//
//  CustomNavigationBar.swift
//  FireStoreDemo
//
//  Created by Gokul on 13/12/20.
//  Copyright © 2020 Gokul. All rights reserved.
//

import UIKit

class CustomNavigationBar: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var labelView: UILabel!
    @IBOutlet weak var rightButton: UIImageView!
    @IBOutlet weak var searchBackgroundView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("CustomNavigationBar", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        searchBackgroundView.layer.cornerRadius = 5
        searchBackgroundView.layer.masksToBounds = true
        
    }
}
