//
//  AlertExtension.swift
//  Virtual Tourist
//
//  Created by Elina Mansurova on 2020-10-29.
//

import UIKit

extension UIViewController {
    func showConfirmationForDelete(title: String, message: String, deleteAction: (() -> Void)?) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            deleteAction?()
        }
        alertVC.addAction(cancelAction)
        alertVC.addAction(deleteAction)
        present(alertVC, animated: true, completion: nil)
    }
}
