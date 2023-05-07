//
//  Extensions.swift
//  TakeMeHome
//
//  Created by Алексей Шамрей on 4.02.23.
//

import Foundation
import UIKit

protocol AlertPresenting {}

extension UIViewController {
    static func instantiate() -> Self {
        let nibName = String(describing: self)
        let nib = UINib(nibName: nibName, bundle: nil)
        return nib.instantiate(withOwner: self, options: nil)[0] as! Self
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(_:)))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard(_ sender: Any) {
        guard let tapGesture = sender as? UITapGestureRecognizer else {
            // Если sender не является UITapGestureRecognizer, закрываем клавиатуру
            view.endEditing(true)
            return
        }
        let tappedView = tapGesture.view
        if !(tappedView is UIControl) {
            // Если нажато на любое представление, кроме элементов управления, закрываем клавиатуру
            view.endEditing(false)
        }
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

extension UIView {
    class func loadFromNib<T:UIView>() -> T {
        return Bundle.main.loadNibNamed(String(describing: T.self), owner: self, options: nil)![0] as! T
    }
}
