//
//  Utility.swift
//  FireStoreDemo
//
//  Created by Gokul on 05/08/20.
//  Copyright © 2020 Gokul. All rights reserved.
//

import UIKit

class Utility {
    class func activityIndicatorView(_ viewModel:Any) -> UIActivityIndicatorView {
        
        var viewForActivity = (viewModel as? UIViewController)?.view
        if(viewForActivity == nil) {
            viewForActivity = viewModel as? UIView
        }
        let activityIN : UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 100 ,y: 200, width: 50, height: 50)) as UIActivityIndicatorView
        activityIN.center = viewForActivity!.center
        viewForActivity?.addSubview(activityIN)
        activityIN.hidesWhenStopped = true
        activityIN.color = .white
        activityIN.style = UIActivityIndicatorView.Style.large
        activityIN.startAnimating()
        return activityIN
    }
}
