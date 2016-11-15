//
//  Constants.swift
//  Autobuses Madrid
//
//  Created by Angel Sans Muro on 13/2/16.
//  Copyright © 2016 Angel Sans. All rights reserved.
//

import UIKit

struct Constants {
    struct TimeParser{
        static let serviceClient = "WEB.PORTALMOVIL.GLF"
        static let passKey = "EAC8DF74-C12C-4DAC-A60D-993C4BB14CDC"
        static let serviceURL = "https://servicios.emtmadrid.es:8443/geo/servicegeo.asmx/"
    }
    
    struct BlueColor{
        static let red = CGFloat(60.0)
        static let green = CGFloat(133.0)
        static let blue = CGFloat(247.0)
    }
    
    struct EMTKeys{
        static let favoriteKey = "kFavoriteKey"
    }
    
    struct MetroKeys{
        static let favoriteKey = "kFavoriteKeyMetro"
    }
    

    
}
