//
//  ViewController.swift
//  Beer
//
//  Created by Gianluca Caliendo on 16/09/2019.
//  Copyright © 2019 Gianluca Caliendo. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SVProgressHUD
import PunkAPI

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    //Interface Builders
    @IBOutlet weak var searchContainerView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var Tabella: UITableView!
    
    //dichiarazione variabile contenente la UserDefaults.standard
    var defaults = UserDefaults.standard
    
    
    //variabili per il controllo barra di ricerca
    var searchController: UISearchController!
    var beerArray = [Beer]()
    var currentBeerArray = [Beer]() //update table
    var searching = false
    
    
    //variabili per la gestione del database
    var thumbnailChar=[Character]()
    var thumbnailVar: String!
    var thumbnailArr=[String]()
    
    var nameChar=[Character]()
    var nameVar: String!
    var nameArr=[String]()
    
    var taglineChar=[Character]()
    var taglineVar: String!
    var taglineArr=[String]()
    
    var descriptionChar=[Character]()
    var descriptionVar: String!
    var descriptionArr=[String]()
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
        retrieveDataFromPunkAPIDatabase()
        Tabella.reloadData()
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //tableView
        Tabella.delegate = self
        Tabella.dataSource = self
        Tabella.reloadData()
        
        searchController = UISearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = false
        searchContainerView.addSubview(searchController.searchBar)
        searchController.searchBar.delegate = self
        searchController.searchBar.barTintColor = UIColor(red:0.04, green:0.09, blue:0.11, alpha:1.0)
        
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = UIColor(red:0.10, green:0.15, blue:0.17, alpha:1.0)
        
       UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).textColor = UIColor.white
        
        
        let attributes:[NSAttributedString.Key:Any] = [
            NSAttributedString.Key.foregroundColor : UIColor(red:0.99, green:0.69, blue:0.20, alpha:1.0),
        ]
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes(attributes, for: .normal)
        
        setUpSearchBar()
        alterLayout()
    }
    

    
     
    
    //MARK: - Search Bar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        currentBeerArray = beerArray.filter({ Beer -> Bool in
            if searchText.isEmpty {
                searching = false
                return true
            }
            self.searching = true
            return Beer.name.lowercased().contains(searchText.lowercased())
            })
        Tabella.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        searchBar.showsCancelButton = false
        // Remove focus from the search bar.
        searchBar.endEditing(true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        //restore data
        currentBeerArray = beerArray
        Tabella.reloadData()
    }
    
    
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
            currentBeerArray = beerArray
            Tabella.reloadData()
    }
    
    
    //MARK: - Punk API
    func retrieveDataFromPunkAPIDatabase() {
        // Prendi dati dal database
        let request = BeersRequest(filter: [.abv(condition: .more, value: 4.3)])
        
        PunkApi().get(request, queue: .main) { [weak self] beersResult in
            
            guard let self = self else { return }
            
            //thumbnail
            do {
                let beers = try beersResult.get()
                let string = beers.reduce(into: "", { (result, beer) in
                    
                    guard let thumbnail = beer.imageUrl else { return }
                    if result.isEmpty {
                        result = thumbnail
                        return
                    }
                    
                    return self.thumbnailChar.append(contentsOf: "\(thumbnail)\n")
                })
                self.thumbnailVar = string.isEmpty ? "Not Found" : string
            } catch let error {
                self.thumbnailVar = error.localizedDescription
            }
            
            
            //name
            do {
                let beers = try beersResult.get()
                let string = beers.reduce(into: "", { (result, beer) in
                    
                    guard let name = beer.name else { return }
                    if result.isEmpty {
                        result = name
                        return
                    }
                    
                    return self.nameChar.append(contentsOf: "\(name)\n")
                })
                self.nameVar = string.isEmpty ? "Not Found" : string
            } catch let error {
                self.nameVar = error.localizedDescription
            }
            
            
            //tagline
            do {
                let beers = try beersResult.get()
                let string = beers.reduce(into: "", { (tagline_result, beer) in
                    
                    guard let tagline = beer.tagline else { return }
                    if tagline_result.isEmpty {
                        tagline_result = tagline
                        return
                    }
                    
                    return self.taglineChar.append(contentsOf: "\(tagline)\n")
                })
                self.taglineVar = string.isEmpty ? "Not Found" : string
            } catch let error {
                self.taglineVar = error.localizedDescription
            }
            
            
            //description
            do {
                let beers = try beersResult.get()
                let string = beers.reduce(into: "", { (description_result, beer) in
                    
                    guard let description = beer.description else { return }
                    if description_result.isEmpty {
                        description_result = description
                        return
                    }
                    
                    return self.descriptionChar.append(contentsOf: "\(description)\n")
                })
                self.descriptionVar = string.isEmpty ? "Not Found" : string
            } catch let error {
                self.descriptionVar = error.localizedDescription
            }
            
            
            //per l'icona
            self.thumbnailVar = String(self.thumbnailChar)
            let thumbnail_components = self.thumbnailVar.components(separatedBy: .newlines)
            self.thumbnailArr = thumbnail_components
            self.thumbnailArr.removeLast()
            
            
            //per il nome
            self.nameVar = String(self.nameChar)
            let name_components = self.nameVar.components(separatedBy: .newlines)
            self.nameArr = name_components
            self.nameArr.removeLast()
            
            
            //per la tagline
            self.taglineVar = String(self.taglineChar)
            let tagline_components = self.taglineVar.components(separatedBy: .newlines)
            self.taglineArr = tagline_components
            self.taglineArr.removeLast()
            
            //per la descrizione
            self.descriptionVar = String(self.descriptionChar)
            let description_components = self.descriptionVar.components(separatedBy: .newlines)
            self.descriptionArr = description_components
            self.descriptionArr.removeLast()
            
            
            //chiama la default
            self.defaults.set(self.thumbnailArr, forKey: "thumbnails")
            self.defaults.synchronize()
            
            self.defaults.set(self.nameArr, forKey: "names")
            self.defaults.synchronize()
            
            self.defaults.set(self.taglineArr, forKey: "taglines")
            self.defaults.synchronize()
            
            self.defaults.set(self.descriptionArr, forKey: "descriptions")
            self.defaults.synchronize()
            
            self.setUpBeers()
        }
    }
    
    
    
    //MARK: - TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return currentBeerArray.count
        }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) ->
        UITableViewCell {
            //        let row = indexPath.row
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? TableViewCell else {
                return UITableViewCell()
            }
            
            cell.name.text = currentBeerArray[indexPath.row].name
            cell.tagline.text = currentBeerArray[indexPath.row].tagline
            cell.descrp.text = currentBeerArray[indexPath.row].description
            
            
            Alamofire.request("\(currentBeerArray[indexPath.row].image)").response { response in
                guard let image = UIImage(data:response.data!) else {
                    // Handle error
            return
                    
                }
                            let imageData = image.pngData()
                            cell.thumbnail.contentMode = .scaleAspectFit
                            cell.thumbnail.image = UIImage(data : imageData!)
                        }
            
            return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case indexPath.row:
            
            if searching == true {
                self.dismiss(animated: true, completion: nil)
                searching = false
                performSegue(withIdentifier: "more_info", sender: nil)
            } else {
                self.dismiss(animated: true, completion: nil)
                performSegue(withIdentifier: "more_info", sender: nil)
            }
            default:
            break;
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 180
    }
    
    
    //MARK: - Configure Beer Class
    func setUpBeers() {
                let names = self.defaults.array(forKey: "names")!
                let taglines = self.defaults.array(forKey: "taglines")!
                let thumbnails = self.defaults.array(forKey: "thumbnails")!
                let detail = self.defaults.array(forKey: "descriptions")!
                
                
                for i in 0...names.count - 1 {
                    self.beerArray.append(Beer(name: names[i] as! String, tagline: taglines[i] as! String, image: thumbnails[i] as! String, description: detail[i] as! String))
                }
                self.currentBeerArray = self.beerArray
                self.Tabella.reloadData()
            }
    
    private func setUpSearchBar() {
        searchBar.delegate = self
    }
    
    
    func alterLayout() {
        Tabella.tableHeaderView = UIView()
        // search bar in section header
        Tabella.estimatedSectionHeaderHeight = 50
        // search bar in navigation bar
        //navigationItem.leftBarButtonItem = UIBarButtonItem(customView: searchBar)
        searchBar.showsScopeBar = false // you can show/hide this dependant on your layout
        searchBar.placeholder = "Search"
    }
    
    //MARK: - prepare
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "more_info" {
            if let indexPath = Tabella.indexPathForSelectedRow {
                let destinationController = segue.destination as! PopupVCViewController
                destinationController.name = currentBeerArray[indexPath.row].name
                destinationController.tagline = currentBeerArray[indexPath.row].tagline
                destinationController.thumbnail = currentBeerArray[indexPath.row].image
                destinationController.descript = currentBeerArray[indexPath.row].description
            }
        }
    }

    
    
}


//MARK: - Initialize Beer Class
class Beer {
    var name: String
    var description: String
    var image: String
    var tagline: String
    
    init(name: String, tagline: String, image: String, description: String) {
        self.name = name
        self.tagline = tagline
        self.image = image
        self.description = description
    }
}
