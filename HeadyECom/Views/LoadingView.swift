//
//  LoadingView.swift
//  HeadyECom
//
//  Created by Personal on 24/07/18.
//  Copyright © 2018 Kamal Wadhwa. All rights reserved.
//

import UIKit

class LoadingView: UIView {

    class func instanceFromNib() -> UIView {
        return UINib(nibName: "LoadingView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }

}
