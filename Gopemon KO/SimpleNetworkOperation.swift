//
//  SimpleNetworkOperation.swift
//  MyAngel
//
//  Created by Andrea Belli on 08/03/16.
//  Copyright © 2016 Groupama. All rights reserved.
//
import Foundation

extension NSMutableURLRequest{
    
    /*Ritorna base64EncodedData risultato da username & password
     Aggiunge il parametro per la BasicAthentication nel HTTPHeaderField "Authorization"
     */
    func setBasicAuthentication(username: String, password: String) ->  String{
        let loginString = NSString(format: "%@:%@", username, password)
        let loginData: NSData = loginString.dataUsingEncoding(NSUTF8StringEncoding)!
        let base64LoginString = loginData.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
        self.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        return base64LoginString
    }
}

class SimpleNetworkOperation {
    
    var session: NSURLSession // = NSURLSession.sharedSession();
    var queryURL =  NSURL()
    var urlString : String!
    
    typealias JSONDictionaryCompletion = (AnyObject?, Int?, NSError?) -> Void
    
    init(url: String) {
        self.urlString = url
        let urlconfig = NSURLSessionConfiguration.defaultSessionConfiguration()
        
        // --- TimeOut config -----//
        urlconfig.timeoutIntervalForRequest = 30
        urlconfig.timeoutIntervalForResource = 30
        //---- END TIMEOUT CONFIG ---- //
        
        self.session = NSURLSession(configuration: urlconfig)
        if let queryURL = NSURL(string: url){
            self.queryURL = queryURL
        }
        
    }
    
    func get(completion: JSONDictionaryCompletion, headerParams: Dictionary<String, String>?) {
        let request = NSMutableURLRequest(URL: queryURL)
        print(queryURL.absoluteString)
        
        headerParams?.forEach({ (body: (key: String, value: String)) -> () in
            request.addValue(body.value, forHTTPHeaderField: body.key)
        })
        
        
        let dataTask = session.dataTaskWithRequest(request) {
            (let data: NSData?, let response: NSURLResponse?, let error: NSError?) -> Void in
            
            // 1: Check HTTP Response for successful GET request
            guard let httpResponse = response as? NSHTTPURLResponse, receivedData = data
                else {
                    completion(nil, 0, error);
                    return
            }
            
            var jsonDictionary:AnyObject? = nil;
            
            switch (httpResponse.statusCode) {
            case 200:
                // 2: Create JSON object with data
                do {
                    jsonDictionary = try NSJSONSerialization.JSONObjectWithData(receivedData, options: NSJSONReadingOptions.MutableContainers);
                    completion(jsonDictionary, httpResponse.statusCode, error);
                } catch {
                    completion(nil, 0, NSError(domain: "Error parsing JSON data", code: 0, userInfo: nil));
                }
            default:
                print("GET request got response \(httpResponse.statusCode)")
            }
        }
        dataTask.resume()
    }
    
    
    func post(body: NSData?,  completion: JSONDictionaryCompletion, headerParams: Dictionary<String, String>?) {
        let request = NSMutableURLRequest(URL: queryURL)
        request.HTTPMethod = "POST";
        request.HTTPBody = body;
        //request.setBasicAuthentication(username, password: password)
        
        headerParams?.forEach({ (body: (key: String, value: String)) -> () in
            request.addValue(body.value, forHTTPHeaderField: body.key)
        })
        
        let dataTask = session.dataTaskWithRequest(request) {
            (let data: NSData?, let response: NSURLResponse?, let error: NSError?) -> Void in
            if let httpResponse = response as? NSHTTPURLResponse,  receivedData = data {
                
                
                var jsonDictionary:AnyObject? = nil;
                switch (httpResponse.statusCode) {
                case 200:
                    // 2: Create JSON object with data
                    do {
                        jsonDictionary = try NSJSONSerialization.JSONObjectWithData(receivedData, options: NSJSONReadingOptions.AllowFragments)
                    } catch {
                        completion(nil, 0, NSError(domain: "Error parsing JSON data", code: 0, userInfo: nil));
                    }
                default:
                    NSLog("POST request got response \(httpResponse.statusCode)")
                }
                
                completion(jsonDictionary, httpResponse.statusCode, error)
                
            }else{
                completion(nil, 0, error);
            }
            
        }
        
        dataTask.resume()
    }
    
    func post(body: NSData?,  completion: JSONDictionaryCompletion, headerParams: Dictionary<String, String>?, getParameters: Dictionary<String, String>) {
        var getParamsString : String = "?"
        getParameters.forEach({ (body: (key: String, value: String)) in
            getParamsString.appendContentsOf(body.key)
            getParamsString.appendContentsOf("=")
            getParamsString.appendContentsOf(body.value)
        })
        
        let url = NSURL(string: urlString.stringByAppendingString(getParamsString))
        NSLog(urlString.stringByAppendingString(getParamsString))
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST";
        request.HTTPBody = body;
        
        headerParams?.forEach({ (body: (key: String, value: String)) -> () in
            request.addValue(body.value, forHTTPHeaderField: body.key)
        })
        
        
        let dataTask = session.dataTaskWithRequest(request) {
            (let data: NSData?, let response: NSURLResponse?, let error: NSError?) -> Void in
            if let httpResponse = response as? NSHTTPURLResponse,  receivedData = data {
                
                
                var jsonDictionary:AnyObject? = nil;
                switch (httpResponse.statusCode) {
                case 200:
                    // 2: Create JSON object with data
                    do {
                        jsonDictionary = try NSJSONSerialization.JSONObjectWithData(receivedData, options: NSJSONReadingOptions.AllowFragments)
                        
                        print(jsonDictionary)
                    } catch {
                        completion(nil, 0, NSError(domain: "Error parsing JSON data", code: 0, userInfo: nil));
                    }
                default:
                    NSLog("POST request got response \(httpResponse.statusCode)")
                }
                
                completion(jsonDictionary, httpResponse.statusCode, error)
                
            }else{
                completion(nil, 0, error);
            }
            
        }
        
        dataTask.resume()
    }
    
    
    func postWithAthorization(body: NSData?,  completion: JSONDictionaryCompletion, headerParams: Dictionary<String, String>?, getParameters: Dictionary<String, String>, username : String, password: String) {
        var getParamsString : String = "?"
        getParameters.forEach({ (body: (key: String, value: String)) in
            getParamsString.appendContentsOf(body.key)
            getParamsString.appendContentsOf("=")
            getParamsString.appendContentsOf(body.value)
        })
        
        let url = NSURL(string: urlString.stringByAppendingString(getParamsString))
        NSLog(urlString.stringByAppendingString(getParamsString))
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST";
        request.HTTPBody = body;
        request.setBasicAuthentication(username, password: password)
        
        
        NSLog("POST FOR URL " + url!.absoluteString)
        
        headerParams?.forEach({ (body: (key: String, value: String)) -> () in
            request.addValue(body.value, forHTTPHeaderField: body.key)
        })
        
        let dataTask = session.dataTaskWithRequest(request) {
            (let data: NSData?, let response: NSURLResponse?, let error: NSError?) -> Void in
            if let httpResponse = response as? NSHTTPURLResponse,  receivedData = data {
                var jsonDictionary:AnyObject? = nil;
                
                switch (httpResponse.statusCode) {
                case 200:
                    // 2: Create JSON object with data
                    do {
                        jsonDictionary = try NSJSONSerialization.JSONObjectWithData(receivedData, options: NSJSONReadingOptions.AllowFragments)
                        print(jsonDictionary)

                    } catch {
                        completion(nil, 666, NSError(domain: "Error parsing JSON data", code: 666, userInfo: nil));
                    }
                    
                default:
                    NSLog("POST request got response \(httpResponse.statusCode)")
                }
                completion(jsonDictionary, httpResponse.statusCode, error)
                
            }else{
                completion(nil, 0, error);
            }
        }
        dataTask.resume()
    }
    
    func postObtainFullRequestObject(body: NSData?,  completion: JSONDictionaryCompletion, headerParams: Dictionary<String, String>?) {
        let request = NSMutableURLRequest(URL: queryURL)
        request.HTTPMethod = "POST";
        request.HTTPBody = body;
        //request.setBasicAuthentication(username, password: password)
        
        headerParams?.forEach({ (body: (key: String, value: String)) -> () in
            request.addValue(body.value, forHTTPHeaderField: body.key)
        })
        
        let dataTask = session.dataTaskWithRequest(request) {
            (let data: NSData?, let response: NSURLResponse?, let error: NSError?) -> Void in
            if let httpResponse = response as? NSHTTPURLResponse,  receivedData = data {
                
                
                var jsonDictionary:AnyObject? = nil;
                switch (httpResponse.statusCode) {
                case 200:
                    // 2: Create JSON object with data
                    do {
                        jsonDictionary = try NSJSONSerialization.JSONObjectWithData(receivedData, options: NSJSONReadingOptions.AllowFragments)
                    } catch {
                        completion(nil, 0, NSError(domain: "Error parsing JSON data", code: 0, userInfo: nil));
                    }
                default:
                    NSLog("POST request got response \(httpResponse.statusCode)")
                }
                
                completion(jsonDictionary, httpResponse.statusCode, error)
                
            }else{
                completion(nil, 0, error);
            }
            
        }
        
        dataTask.resume()
    }
    
    
    func postWithAthorization(body: NSData?,  completion: JSONDictionaryCompletion, headerParams: Dictionary<String, String>?, username : String, password: String) {
        let request = NSMutableURLRequest(URL: queryURL)
        request.HTTPMethod = "POST";
        request.HTTPBody = body;
        request.setBasicAuthentication(username, password: password)
        
        NSLog("POST FOR URL " + self.queryURL.absoluteString)
        
        headerParams?.forEach({ (body: (key: String, value: String)) -> () in
            request.addValue(body.value, forHTTPHeaderField: body.key)
        })
        
        let dataTask = session.dataTaskWithRequest(request) {
            (let data: NSData?, let response: NSURLResponse?, let error: NSError?) -> Void in
            if let httpResponse = response as? NSHTTPURLResponse,  receivedData = data {
                var jsonDictionary:AnyObject? = nil;
                
                switch (httpResponse.statusCode) {
                case 200:
                    // 2: Create JSON object with data
                    do {
                        jsonDictionary = try NSJSONSerialization.JSONObjectWithData(receivedData, options: NSJSONReadingOptions.AllowFragments)
                    } catch {
                        completion(nil, 666, NSError(domain: "Error parsing JSON data", code: 666, userInfo: nil));
                    }
                    
                default:
                    NSLog("POST request got response \(httpResponse.statusCode)")
                }
                completion(jsonDictionary, httpResponse.statusCode, error)
                
            }else{
                completion(nil, 0, error);
            }
        }
        dataTask.resume()
    }
    
    
    func put(body: NSData?,  completion: JSONDictionaryCompletion, headerParams: Dictionary<String, String>?) {
        let request = NSMutableURLRequest(URL: queryURL)
        request.HTTPMethod = "PUT";
        request.HTTPBody = body;
        //request.setBasicAuthentication(username, password: password)
        
        headerParams?.forEach({ (body: (key: String, value: String)) -> () in
            request.addValue(body.value, forHTTPHeaderField: body.key)
        })
        
        let dataTask = session.dataTaskWithRequest(request) {
            (let data: NSData?, let response: NSURLResponse?, let error: NSError?) -> Void in
            if let httpResponse = response as? NSHTTPURLResponse,  receivedData = data {
                
                
                var jsonDictionary:AnyObject? = nil;
                switch (httpResponse.statusCode) {
                case 200:
                    // 2: Create JSON object with data
                    do {
                        jsonDictionary = try NSJSONSerialization.JSONObjectWithData(receivedData, options: NSJSONReadingOptions.AllowFragments)
                    } catch {
                        completion(nil, 0, NSError(domain: "Error parsing JSON data", code: 0, userInfo: nil));
                    }
                default:
                    NSLog("PUT request got response \(httpResponse.statusCode)")
                }
                
                completion(jsonDictionary, httpResponse.statusCode, error)
                
            }else{
                completion(nil, 0, error);
            }
            
        }
        
        dataTask.resume()
    }
    
    func putWithAthorization(body: NSData?,  completion: JSONDictionaryCompletion, headerParams: Dictionary<String, String>?, username : String, password: String) {
        let request = NSMutableURLRequest(URL: queryURL)
        request.HTTPMethod = "PUT";
        request.HTTPBody = body;
        request.setBasicAuthentication(username, password: password)
        
        NSLog("PUT FOR URL " + self.queryURL.absoluteString)
        
        headerParams?.forEach({ (body: (key: String, value: String)) -> () in
            request.addValue(body.value, forHTTPHeaderField: body.key)
        })
        
        let dataTask = session.dataTaskWithRequest(request) {
            (let data: NSData?, let response: NSURLResponse?, let error: NSError?) -> Void in
            if let httpResponse = response as? NSHTTPURLResponse,  receivedData = data {
                var jsonDictionary:AnyObject? = nil;
                
                switch (httpResponse.statusCode) {
                case 200:
                    // 2: Create JSON object with data
                    do {
                        jsonDictionary = try NSJSONSerialization.JSONObjectWithData(receivedData, options: NSJSONReadingOptions.AllowFragments)
                    } catch {
                        completion(nil, 666, NSError(domain: "Error parsing JSON data", code: 666, userInfo: nil));
                    }
                    
                default:
                    NSLog("PUT request got response \(httpResponse.statusCode)")
                }
                completion(jsonDictionary, httpResponse.statusCode, error)
                
            }else{
                completion(nil, 0, error);
            }
        }
        dataTask.resume()
    }

}