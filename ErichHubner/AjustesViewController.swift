//
//  AjustesViewController.swift
//  ErichHubner
//
//  Created by erich on 24/04/2018.
//  Copyright © 2018 Hubnerspage. All rights reserved.
//

import UIKit
import CoreData

enum StateType {
    case add
    case edit
}

class AjustesViewController: UIViewController {

    //Definindo os outlets
    @IBOutlet weak var tfCotacao: UITextField!
    @IBOutlet weak var tfIOF: UITextField!
    @IBOutlet weak var tbStates: UITableView!
    
        //Declarando as variáveis
        var label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 22))
        var fetchedResultController: NSFetchedResultsController<State>!
        var dataSource: [State] = []
    
        override func viewDidLoad() {
            super.viewDidLoad()
            
            //Carregando a lista de Estados
            tbStates.estimatedRowHeight = 106
            tbStates.rowHeight = UITableViewAutomaticDimension
            label.text = "Lista de estados vazia!"
            label.textAlignment = .center
            label.textColor = .black
            tbStates.delegate = self
            tbStates.dataSource = self
            loadStates()
        }
    
    //Tentei implementar isso pra sumir com o teclado, mas não rolou
    func touchesBegan(_touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
        //Definindo os valores inicias de cotacão e iof
        override func viewWillAppear(_ animated: Bool) {
            if UserDefaults.standard.string(forKey: "cotacao") == nil {
                UserDefaults.standard.set(3.2, forKey: "cotacao")
            }
            if UserDefaults.standard.string(forKey: "iof") == nil {
                UserDefaults.standard.set(6.38, forKey: "iof")
            }
            
            tfCotacao.text = UserDefaults.standard.string(forKey: "cotacao")
            tfIOF.text = UserDefaults.standard.string(forKey: "iof")
        }
        
        override func viewWillDisappear(_ animated: Bool) {
            if (tfCotacao.text != "") {
                UserDefaults.standard.set(tfCotacao.text!, forKey: "cotacao")
            }
            else {
                UserDefaults.standard.set(3.2, forKey: "cotacao")
            }
            
            if tfIOF.text != ""{
                UserDefaults.standard.set(tfIOF.text!, forKey: "iof")
            }
            else {
                UserDefaults.standard.set(6.38, forKey: "iof")
            }
        }
        
        func loadStates() {
            let fetchRequest: NSFetchRequest<State> = State.fetchRequest()
            let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
            fetchRequest.sortDescriptors = [sortDescriptor]
            fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            fetchedResultController.delegate = self
            do {
                try fetchedResultController.performFetch()
            } catch {
                print(error.localizedDescription)
            }
            do {
                dataSource = try context.fetch(fetchRequest)
            } catch {
                print(error.localizedDescription)
            }
        }
    
        //Inserindo um Estado
        @IBAction func addState(_ sender: Any) {
            showAlert(type: .add, state: nil)
        }
        
        func showAlert(type: StateType, state: State?) {
            let title = (type == .add) ? "Adicionar" : "Editar"
            let alert = UIAlertController(title: "\(title) Estado", message: nil, preferredStyle: .alert)
            alert.addTextField { (textField: UITextField) in
                textField.placeholder = "Nome do estado"
                if let name = state?.name {
                    textField.text = name
                }
                textField.addTarget(self, action: #selector(self.textChanged), for: .editingChanged)
            }
            alert.addTextField { (textField: UITextField) in
                textField.placeholder = "Imposto"
                if let tax = state?.tax {
                    textField.text = "\(tax)"
                }
                textField.keyboardType = .decimalPad
                textField.addTarget(self, action: #selector(self.textChanged), for: .editingChanged)
            }
            alert.addAction(UIAlertAction(title: title, style: .default, handler: { (action: UIAlertAction) in
                let state = state ?? State(context: self.context)
                state.tax = Double((alert.textFields?[1].text?.replacingOccurrences(of: ",", with: "."))!)!
                state.name = alert.textFields?.first?.text
                do {
                    try self.context.save()
                    self.loadStates()
                } catch {
                    print(error.localizedDescription)
                }
            }))
            alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
            alert.actions[0].isEnabled = (alert.textFields?.first?.text != "" && alert.textFields?[1].text != "")
            present(alert, animated: true, completion: nil)
        }
        
    @objc func textChanged(_ sender: Any) {
            let tf = sender as! UITextField
            var resp : UIResponder! = tf
            while !(resp is UIAlertController) { resp = resp.next }
            let alert = resp as! UIAlertController
            alert.actions[0].isEnabled = (alert.textFields?.first?.text != "" && alert.textFields?[1].text != "")
        }
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    extension AjustesViewController: NSFetchedResultsControllerDelegate {
        func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            tbStates.reloadData()
        }
    }
    
    // MARK: - UITableViewDelegate
    extension AjustesViewController: UITableViewDelegate {
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let state = dataSource[indexPath.row]
            showAlert(type: .edit, state: state)
            tableView.deselectRow(at: indexPath, animated: false)
        }
        
         func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
            if editingStyle == .delete {
                let state = fetchedResultController.object(at: indexPath)
                context.delete(state)
                do {
                    try context.save()
                    self.loadStates()
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: - UITableViewDelegate
    extension AjustesViewController: UITableViewDataSource {
        
        func numberOfSections(in tableView: UITableView) -> Int {
            return 1
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            if let count = fetchedResultController.fetchedObjects?.count {
                tableView.backgroundView = (count == 0) ? label : nil
                return count
            } else {
                tableView.backgroundView = label
                return 0
            }
        }
        
        //Método que define a célula que será apresentada em cada linha
            func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                let cell = tableView.dequeueReusableCell(withIdentifier: "stateCell", for: indexPath) as! StateTableViewCell
                let state = dataSource[indexPath.row]
                
                cell.textLabel?.text = state.name
                cell.detailTextLabel?.text = String(state.tax)
                cell.detailTextLabel?.textColor = .red
                return cell
        }
}
