//
//  ViewController+CoreData.swift
//  ErichHubner
//
//  Created by erich on 26/04/2018.
//  Copyright © 2018 Hubnerspage. All rights reserved.
//

import UIKit
import CoreData

extension UIViewController {
    var appDelegate: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    var context: NSManagedObjectContext {
        return appDelegate.persistentContainer.viewContext
    }
    
    //Definindo mensagens de erro
    func showError(text: String) {
        showError(text: text, field: nil)
    }
    
    func showError(text: String, field: UITextField?) {
        let title = "Ops!"
        let alert = UIAlertController(title: "\(title)", message: text, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (UIAlertAction) in
            if field != nil {
                field?.becomeFirstResponder()
            }
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    // Definindo tratamento para campos vazios
    func fieldValidation(field: UITextField, fieldName: String) -> Bool {
        if (field.text?.isEmpty)! || (field.text?.trimmingCharacters(in: NSCharacterSet.whitespaces).isEmpty)! {
            showError(text: "O campo \(fieldName) é requerido!", field: field)
            return false
        }
        return true
    }
}
