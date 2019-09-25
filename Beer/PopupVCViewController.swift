//
//  PopupVCViewController.swift
//  Beer
//
//  Created by Gianluca Caliendo on 17/09/2019.
//  Copyright © 2019 Gianluca Caliendo. All rights reserved.
//

import UIKit
import Alamofire

class PopupVCViewController: UIViewController {
    
    //variabili di sistema
    var defaults = UserDefaults.standard
    
    //variabili locali
    var thumbnail: String!
    var name: String!
    var tagline: String!
    var descript: String!
    
    @IBOutlet weak var pic: UIImageView!
    @IBOutlet weak var beer_name: UILabel!
    @IBOutlet weak var beer_tagline: UILabel!
    @IBOutlet weak var beer_description: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        if thumbnail != nil {
        
        Alamofire.request(thumbnail).response { response in
            guard let image = UIImage(data:response.data!) else {
                // Handle error
                return
            }
            let imageData = image.pngData()
            self.pic.contentMode = .scaleAspectFit
            self.pic.image = UIImage(data : imageData!)
        }
        }
        beer_name.text = name
        
        beer_tagline.text = tagline
        
        beer_description.text = descript
    }

    @IBAction func close(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
