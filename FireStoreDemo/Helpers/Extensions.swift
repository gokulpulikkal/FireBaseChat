//
//  Extensions.swift
//  FireStoreDemo
//
//  Created by Gokul on 01/08/20.
//  Copyright © 2020 Gokul. All rights reserved.
//

import UIKit

extension UIColor {
    static func getColor(R: CGFloat, G: CGFloat, B: CGFloat) -> UIColor {
        return UIColor(red: (R/255.0), green: (G/255.0), blue: (B/255.0), alpha: 1.0)
    }
}
extension UIImageView{
  func imageFrom(url:URL){
    DispatchQueue.global().async { [weak self] in
      if let data = try? Data(contentsOf: url){
        if let image = UIImage(data:data){
          DispatchQueue.main.async{
            self?.image = image
          }
        }
      }
    }
  }
}
