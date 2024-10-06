//
//  ViewController.swift
//  FortPaymentExample
//
//  Created by Hafiz Muhammad Junaid on 07/03/2018.
//  Copyright © 2018 Appabilities. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController {
    
    var payFort = PayFortController(enviroment: KPayFortEnviromentSandBox)
    
    let testURL = "https://sbpaymentservices.payfort.com/FortAPI/paymentApi"
    let MERCHANT_IDENTIFIER = "";
    let ACCESS_CODE = "";
    let SHA_REQUEST_PHRASE = "TESTSHAIN";
    let CURRENCY_TYPE = "SAR";
    let LANGUAGE_TYPE = "en";

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Button Actions
    @IBAction func actionPlaceOrderAlamofire(_ sender: Any) {
        self.fetchTokenUsingAlamofire()

    }
    
    @IBAction func actionPlaceOrderWebService(_ sender: Any) {
        self.fetchToken()
    }
    
    // MARK: - PayFort Method
    fileprivate func fetchToken() {

        let url = URL(string: testURL)!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "POST"
        
        let strSign = SHA_REQUEST_PHRASE + "access_code" + "=" + ACCESS_CODE + "device_id" + "=" + payFort!.getUDID() + "language" + "=" + LANGUAGE_TYPE + "merchant_identifier" + "=" + MERCHANT_IDENTIFIER + "service_command" + "=" + "SDK_TOKEN" + SHA_REQUEST_PHRASE;
        
        
        let params = ["service_command": "SDK_TOKEN",
                      "access_code": ACCESS_CODE,
                      "merchant_identifier": MERCHANT_IDENTIFIER,
                      "language": LANGUAGE_TYPE,
                      "device_id": payFort!.getUDID(),
                      "signature": strSign.sha256()]
        
        print(params)

        
        var nsdata = NSData()
        do {
            let dat = try JSONSerialization.data(withJSONObject: params, options: [])
             nsdata = dat as NSData
        }
        catch { }
        
        


        request.httpBody = nsdata as Data
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error= \(error as Any)")
                return
            }

            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response as Any)")
                
            }
            
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(responseString as Any)")
            
            do {
                
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                
                if let dict = json as? [String:Any] {
                    
                    DispatchQueue.main.async {
                         self.presentPayFort(responseData: dict)
                    }
                   
                }
            }
            catch {
                print(error.localizedDescription)
            }

           
        }
        task.resume()
    }
    
    fileprivate func fetchTokenUsingAlamofire() {

        let strSign = SHA_REQUEST_PHRASE + "access_code" + "=" + ACCESS_CODE + "device_id" + "=" + payFort!.getUDID() + "language" + "=" + LANGUAGE_TYPE + "merchant_identifier" + "=" + MERCHANT_IDENTIFIER + "service_command" + "=" + "SDK_TOKEN" + SHA_REQUEST_PHRASE;
        
        let params:Parameters = ["service_command": "SDK_TOKEN",
                      "access_code": ACCESS_CODE,
                      "merchant_identifier": MERCHANT_IDENTIFIER,
                      "language": LANGUAGE_TYPE,
                      "device_id": payFort!.getUDID(),
                      "signature": strSign.sha256()]
        
        
        
        
        let url = URL(string: testURL)!
        

        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: ["Content-Type" :"application/json"]).responseJSON{ (response) in
            
            print(params)
            switch(response.result) {
            case .success(_):
                debugPrint(response.result as Any)
                if let result = response.result.value as? [String:Any] {
                    debugPrint(result)
                    
                   self.presentPayFort(responseData: result)
                    
                }
                break
                
            case .failure(_):
                debugPrint(response.result.error as Any)
                debugPrint(response.result.error!.localizedDescription)
                
                break
                
            }
            
        }

    }
    
    fileprivate func presentPayFort(responseData: [String:Any]) {
        
        let dict = NSMutableDictionary()
        
        let numberRandom = Int(arc4random_uniform(200))
        dict.setValue("1000", forKey: "amount")
        dict.setValue("PURCHASE", forKey: "command")
        dict.setValue(CURRENCY_TYPE, forKey: "currency")
        dict.setValue("email@domain.com", forKey: "customer_email")
        dict.setValue(LANGUAGE_TYPE, forKey: "language")
        dict.setValue("\(numberRandom)", forKey: "merchant_reference")
        if let token = responseData["sdk_token"] as? String {
            dict.setValue(token, forKey: "sdk_token")
        }
        
        print(dict)
        
        
        self.payFort?.isShowResponsePage = true
        
        
        self.payFort?.callPayFort(withRequest: dict, currentViewController: self, success: { (requestDict, responseDict) in
            
            print("success")
            print("responeDic = \(responseDict as Any)")
            print("responeDic = \(responseDict as Any)")
            
        }, canceled: { (requestDict, responseDict) in
            
            print("canceled")
            print("requestDic = \(requestDict as Any)")
            print("responeDic = \(responseDict as Any)")
            
        }, faild: { (requestDict, responseDict, message) in
            
            print("faild")
            print("requestDic = \(requestDict as Any)")
            print("responeDic = \(responseDict as Any)")
            print("message = \(message as Any)")
            
        })
        
    }
    
}

