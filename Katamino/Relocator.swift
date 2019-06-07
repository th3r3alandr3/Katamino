//
//  Relocator.swift
//  Katamino
//
//  Created by Andre Eidemann on 15.05.19.
//  Copyright © 2019 Andre Eidemann. All rights reserved.
//

import UIKit

extension UIView {
    //Extend the UIView by a function to relocate a view
    func addSubviewPreservingLocation(_ view: UIView) {
        let centered = self.convert(view.center, from: view.superview)
        self.addSubview(view)
        view.center = centered
    }
}
