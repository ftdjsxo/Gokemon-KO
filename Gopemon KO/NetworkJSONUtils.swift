//
//  NetworkJSONUtils.swift
//  Gopemon KO
//
//  Created by Francesco Thiery on 26/07/16.
//  Copyright © 2016 Coocked. All rights reserved.
//

import Foundation

class NetworkJSONUtils{
    
    class func JSONData(fromDictionay aDictionary : NSDictionary) -> NSData?{
        do {
            let jSON = try NSJSONSerialization.dataWithJSONObject(aDictionary, options: .PrettyPrinted)
            //            let parsedJSON = NSString(data: jSON, encoding: NSUTF8StringEncoding)!
            //            NSLog("PARSED JSON :" + (parsedJSON as String))
            return jSON
        }catch {
            return nil
        }
    }
    
    //Le chiavi del JSON devono essere i nomi delle proprietà del bean
    //È necessario che il bean sia NSObject (Wrap di ObjectiveC) e non AnyObject (Swift) poichè per settare il valore alla proprietà bisogna richiamare il metodo "setValue(value : AnyObject? forKey : String)" non richiamabile altrimenti
    class func bindMembers(fromData data : AnyObject, toObject bean : NSObject) -> NSObject{
        /*Effettuo il cast del JSON da AnyObject a un Dictionary, mi ciclo tutte le chiavi e controllo che effettivamente appartangano all'oggetto; In tal caso setto il valore alla proprietà */
        if let jsonDict = data as? [String : AnyObject]{
            let keysArray = Array(jsonDict.keys)
            for label in keysArray{
                let value = jsonDict[label]
                let child = Mirror(reflecting: bean).children
                for c in child{
                    if c.label == label{
                        print(value, label)
                        bean.setValue(value, forKey: label)
                    }
                }
                
            }
        }
        return bean
    }
    
    //    class func bindMembers <T : NSObject> (fromData data : AnyObject, toObject bean : T) -> T{
    //        return bindMembers(fromData: data, toObject: bean) as T
    //    }
}