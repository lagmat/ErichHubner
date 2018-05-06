//
//  AddEditViewController.swift
//  ErichHubner
//
//  Created by erich on 26/04/2018.
//  Copyright © 2018 Hubnerspage. All rights reserved.
//

import UIKit
import CoreData

class AddEditViewController: UIViewController {


   //Definindo os outlets
    @IBOutlet weak var tfName: UITextField!
    @IBOutlet weak var ivPhoto: UIImageView!
    @IBOutlet weak var swCard: UISwitch!
    @IBOutlet weak var tfState: UITextField!
    @IBOutlet weak var tfPrice: UITextField!
    @IBOutlet weak var btAddPhoto: UIButton!
    @IBOutlet weak var btAddEdit: UIButton!
    
    //Desclarando as variáveis
    var product: Product!
    var smallImage: UIImage!
    var pickerView: UIPickerView!
    var selectedState: State!
    var statesList: [State]! = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Recuperando as informações de um produto para atualização
        if product != nil {
            self.title = "Atualizar Produto"
            tfName.text = product.name
            swCard.isOn = product.card
            tfPrice.text = "\(product.price)"
            tfState.text = product.state?.name
            selectedState = product.state
            if let image = product.photo as? UIImage {
                ivPhoto.image = image
                btAddPhoto.setTitle("", for: .normal)
            }
            btAddEdit.setTitle("Atualizar", for: .normal)
        }
        
        //Configurando o pickerview do Estado
        pickerView = UIPickerView()
        pickerView.backgroundColor = .white
        pickerView.delegate = self
        pickerView.dataSource = self
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 44))
        
        //O botão cabcel cancela escolha de estado, chamando o método cancel
        let btCancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        let btSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        //O botão done confirma a escolha do estado, chamando o método done.
        let btDone = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        toolbar.items = [btCancel, btSpace, btDone]
        
        //Definindo o pickerView como entrada do textField
        tfState.inputView = pickerView
        
        //Definindo a toolbar como view de apoio ao textField
        tfState.inputAccessoryView = toolbar
    }
    
    //Exibindo a lista de Estados
    func loadState() {

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        let entityDescription = NSEntityDescription.entity(forEntityName: "State", in: self.context)
        fetchRequest.entity = entityDescription
        
        do {
            let result = try self.context.fetch(fetchRequest)
            for element  in result {
                let state = element as! State
                statesList.append(state)
            }
            
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
    }
    
    //Cancelando a inclusão ou atualização de um Estado
    @objc func cancel() {
        tfState.resignFirstResponder()
    }
    
    //Atribuindo ao textField o estado escolhido no pickerView
    @objc func done() {
        if (statesList.count > 0) {
            selectedState = statesList[pickerView.selectedRow(inComponent: 0)]
            tfState.text = statesList[pickerView.selectedRow(inComponent: 0)].name
        }
        cancel()
    }
    
    
    @IBAction func close(_ sender: UIButton?) {
        navigationController?.popViewController(animated: true)
    }
    
    //Adicionando a foto do produto
    @IBAction func addPhoto(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "Selecionar Foto", message: "De onde você quer escolher a foto?", preferredStyle: .actionSheet)
        
        //Verificamos se o device possui câmera. Se sim, adicionamos a devida UIAlertAction
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraAction = UIAlertAction(title: "Câmera", style: .default, handler: { (action: UIAlertAction) in
                self.selectPicture(sourceType: .camera)
            })
            alert.addAction(cameraAction)
        }
        
        //As UIAlertActions de Biblioteca de fotos e Álbum de fotos também são criadas e adicionadas
        let libraryAction = UIAlertAction(title: "Biblioteca de fotos", style: .default) { (action: UIAlertAction) in
            self.selectPicture(sourceType: .photoLibrary)
        }
        alert.addAction(libraryAction)
        
        let photosAction = UIAlertAction(title: "Álbum de fotos", style: .default) { (action: UIAlertAction) in
            self.selectPicture(sourceType: .savedPhotosAlbum)
        }
        alert.addAction(photosAction)
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    //Inserindo um novo produto
    @IBAction func addEditProduct(_ sender: UIButton) {
        
        if product == nil {
            product = Product(context: context)
        }
        
        //Validando os campos do produto
        if !fieldValidation(field: tfName, fieldName: "Nome do produto") {
            return
        } else {
            product.name = tfName.text!
        }
        
        if !fieldValidation(field: tfPrice, fieldName: "Valor (US$)") {
            return
        } else {
            product.price = Double(tfPrice.text!.replacingOccurrences(of: ",", with: "."))!
        }
        product.card = swCard.isOn
        
        if !fieldValidation(field: tfState, fieldName: "Estado da compra") {
            return
        } else {
            product.state = selectedState
        }
        
        if smallImage != nil {
            product.photo = smallImage
        }
        do {
            //Salvando o contexto
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
        
        close(nil)
    }
    
    func selectPicture(sourceType: UIImagePickerControllerSourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = sourceType
        imagePicker.delegate = self
        imagePicker.navigationBar.tintColor = UIColor(named: "main")
        present(imagePicker, animated: true, completion: nil)
    }
}

@objc extension AddEditViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        let smallSize = CGSize(width: 300, height: 280)
        UIGraphicsBeginImageContext(smallSize)
        image.draw(in: CGRect(x: 0, y: 0, width: smallSize.width, height: smallSize.height))
        smallImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        ivPhoto.image = smallImage
        dismiss(animated: true, completion: nil)
    }
}

extension AddEditViewController: UIPickerViewDelegate {
    
    override func viewWillAppear(_ animated: Bool) {
        loadState()
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        //Retornando o nome do Estado baseado na linha selecionada
        return statesList[row].name
    }
}

extension AddEditViewController: UIPickerViewDataSource {
    
    //Exibindo apenas uma coluna no pickerView
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //Retornando o total de ítens da lista de Estados
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return statesList.count
    }
}
