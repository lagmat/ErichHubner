//
//  StatesTableViewController.swift
//  ErichHubner
//
//  Created by erich on 26/04/2018.
//  Copyright © 2018 Hubnerspage. All rights reserved.
//

import UIKit
import CoreData

class StatesTableViewController: UITableViewController {
    
    var statesManager = StatesManager.shared
    var state: State!
            
            override func viewDidLoad() {
                super.viewDidLoad()
                loadStates()
            }
            
            // MARK: - Methods
            func loadStates() {
            statesManager.loadStates(with: context)
            tableView.reloadData()
            }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return statesManager.states.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let state = statesManager.states[indexPath.row]
        cell.textLabel?.text = state.name
        return cell
    }
    
    
    @IBAction func addState(_ sender: UIButton) {
        showAlert(with: nil)
    }
    
    func showAlert(with state: State?) {
        let title = state == nil ? "Adicionar" : "Editar"
        let alert = UIAlertController(title: "\(title) Estado", message: nil, preferredStyle: .alert)
        alert.addTextField { (textField: UITextField) in
            textField.placeholder = "Nome do estado"
            if let name = state?.name {
                textField.text = name
            }
        }
        
        alert.addAction(UIAlertAction(title: title, style: .default, handler: { (action: UIAlertAction) in
            let state = self.state ?? State(context: self.context)
            state.name = alert.textFields?.first?.text
            do {
                try self.context.save()
                self.loadStates()
            } catch {
                print(error.localizedDescription)
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
        }




