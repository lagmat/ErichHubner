//
//  TotalViewController.swift
//  ErichHubner
//
//  Created by erich on 24/04/2018.
//  Copyright © 2018 Hubnerspage. All rights reserved.
//

import UIKit
import CoreData

class TotalViewController: UIViewController {
    
    //Definindo os outlets
    @IBOutlet weak var lbTotalUs: UILabel!
    @IBOutlet weak var lbTotalBr: UILabel!
    
    //Declarando as variáveis
    var totalUs : Double = 0
    var totalBr : Double = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Exibindo os resultados dos cálculos
        getTotal()
    }
    
    //Realizando os cálculos
    func getTotal() {
        
        totalUs = 0
        totalBr = 0
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        let entityDescription = NSEntityDescription.entity(forEntityName: "Product", in: self.context)
        fetchRequest.entity = entityDescription
        
        do {
            //Recuperando os valores dos produtos
            let result = try self.context.fetch(fetchRequest)
            for element  in result {
                let product = element as! Product
                totalUs += product.price
                print("totalUs: \(totalUs)")
                
                //Recuperando o valor da cotação do dólar
                var dolar = 0.0
                if UserDefaults.standard.string(forKey: "cotacao") != nil {
                    dolar = Double(UserDefaults.standard.string(forKey: "cotacao")!)!
                }
                
                //Recuperando o valor do iof
                var iof = 0.0
                if UserDefaults.standard.string(forKey: "iof") != nil {
                    iof = Double(UserDefaults.standard.string(forKey: "iof")!)!
                }
                
                //Multiplicando pelo valor do dolar
                let valor = product.price * dolar
                
                //Calculando o imposto por estado
                var cimp = 0.0
                cimp = valor * (product.state?.tax)!/100
                print("imposto: \(cimp)")
               
               //Calculando o iof se for cartão
                var ciof = 0.0
                if product.card {
                    ciof =  valor * iof/100
                    print("iof: \(ciof)")
                }
                
                //Somando o valor total de produtos com todos impostos
                totalBr += valor + cimp + ciof
                print("totalBr: \(totalBr)")
            }
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
        
        lbTotalUs.text = "\(totalUs)"
        lbTotalBr.text = "\(totalBr)"
    }
}
