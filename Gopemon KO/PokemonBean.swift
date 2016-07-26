//
//  PokemonBean.swift
//  Gopemon KO
//
//  Created by Francesco Thiery on 26/07/16.
//  Copyright © 2016 Coocked. All rights reserved.
//

import Foundation

class PokemonBean : NSObject{
    var expiration_time : NSNumber?
    var latitude : NSNumber?
    var longitude : NSNumber?
    var pokemonId : NSNumber?
    
    func isValid() -> Bool{
        return latitude != nil && longitude != nil && pokemonId != nil
    }
}