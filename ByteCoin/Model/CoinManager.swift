//
//  CoinManager.swift
//  ByteCoin
//
//  Created by Angela Yu on 11/09/2019.
//  Copyright © 2019 The App Brewery. All rights reserved.
//

import Foundation

protocol CoinManagerDelegate {
    
    func didUpdatePrice(price: String, currency: String)
    
    func didFailWithError(error: Error)
    
}

struct CoinManager {
    
    let baseURL = "https://apiv2.bitcoinaverage.com/indices/global/ticker/BTC"
    
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]
    
    var delegate: CoinManagerDelegate?
    
    func getCoinPrice(for currency: String)  {
                
        let stringUrl = "\(baseURL)"+currency
        
        guard let url = URL(string: stringUrl) else {
            
            print("Unable to create URL")
            
            return
        }
        
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                
               // print(error)
                
                self.delegate?.didFailWithError(error: error!)
                
                return
            }
            
            guard let safeData = data else {
                
                print("Unable to create data")
                
                return
                
            }
            
//            guard let dataString = String(data: safeData, encoding: String.Encoding.utf8) else {
//                
//                print("Unable to create string from data")
//                
//                return
//                
//            }
            
            
            guard let lastPrice = self.parseJSON(safeData) else {
                
                print("Unable to get last price")
              
                return
            }
            
            let currencyString = String(format:"%.2f", lastPrice)
            
            self.delegate?.didUpdatePrice(price: currencyString, currency: currency)
        }
       
        task.resume()
       
        
    }
    
    func parseJSON(_ data: Data) -> Double? {
        
        let decoder = JSONDecoder()
        
        do {
            
            let decodedData = try decoder.decode(CoinData.self, from: data)
            
            let lastPrice = decodedData.last
            
            return lastPrice
            
        } catch {
         
            print(error)
            
            return nil
            
        }
        
    }
    
}
