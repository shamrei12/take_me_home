//
//  Extensions.swift
//  TakeMeHome
//
//  Created by Алексей Шамрей on 4.02.23.
//

import Foundation
import UIKit

extension UIViewController {
    static func instantiate() -> Self {
        let nibName = String(describing: self)
        let nib = UINib(nibName: nibName, bundle: nil)
        return nib.instantiate(withOwner: self, options: nil)[0] as! Self
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension UIScrollView {
    func scrollToTop() {
        let desiredOffset = CGPoint(x: 0, y: contentInset.bottom + 750)
        setContentOffset(desiredOffset, animated: true)
   }
    
    func scrollToDown() {
        let desiredOffset = CGPoint(x: 0, y: contentInset.bottom + 450)
        setContentOffset(desiredOffset, animated: true)
    }
}


