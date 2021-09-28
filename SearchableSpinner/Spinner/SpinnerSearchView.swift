//
//  SpinnerSearchView.swift
//  SearchableSpinner
//
//  Created by Romana on 2/9/21.
//

import UIKit

@objc protocol SearchViewDelegate{
    func selectedValue(index:Int, value:String, object: Any)
}

class SpinnerSearchView: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    var searchBar = UITextField()
    var searchList = UITableView()
    var itemArray = [String]()
    var tempArray = [String]()
    var delegate: SearchViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.tempArray = self.itemArray
        setView()
    }
    
    func setView(){
        searchBar.delegate = self
        searchBar.backgroundColor = UIColor.clear
        searchBar.clearButtonMode = .whileEditing
        searchBar.addTarget(self, action: #selector(handleEditingChanged(textField:)), for: .editingChanged)
        
        
        let searchBg = UIView()
        searchBg.translatesAutoresizingMaskIntoConstraints = false
        searchBg.backgroundColor = UIColor.white
        searchBg.layer.borderWidth = 2
        searchBg.layer.cornerRadius = 5
        searchBg.layer.borderColor =  UIColor.black.cgColor
        
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.backgroundColor = .white
        
        searchBg.addSubview(searchBar)
        
        self.view.addSubview(searchBg)
        
        searchList.translatesAutoresizingMaskIntoConstraints = false
        searchList.backgroundColor = .white
        searchList.delegate = self
        searchList.dataSource = self
        self.view.addSubview(searchList)
        
        let cancelBtn = UIButton(type: .system)
        cancelBtn.translatesAutoresizingMaskIntoConstraints = false
        cancelBtn.setTitle("Cancel", for: .normal)

        
        self.view.addSubview(cancelBtn)
        
        let constraints = [
            searchBg.heightAnchor.constraint(equalToConstant: 55),
            searchBg.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 50),
            searchBg.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 30),
            searchBg.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -30),
            
            searchBar.heightAnchor.constraint(equalToConstant: 45),
            searchBar.topAnchor.constraint(equalTo: searchBg.topAnchor, constant: 5),
            searchBar.leadingAnchor.constraint(equalTo: searchBg.leadingAnchor, constant: 5),
            searchBar.trailingAnchor.constraint(equalTo: searchBg.trailingAnchor, constant: -5),
            
            searchList.topAnchor.constraint(equalTo: searchBg.bottomAnchor, constant: 10),
            searchList.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 30),
            searchList.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -30),
            searchList.bottomAnchor.constraint(equalTo: cancelBtn.topAnchor, constant: -20),
            
            cancelBtn.heightAnchor.constraint(equalToConstant: 40),
            cancelBtn.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 30),
            cancelBtn.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -30),
            cancelBtn.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -30),
        ]
        NSLayoutConstraint.activate(constraints)
        cancelBtn.addTarget(self, action: #selector(self.cancel), for: .touchUpInside)
    }
    @objc func cancel() {
        self.view.endEditing(true)
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    @objc
    func handleEditingChanged(textField: UITextField) {
        if (searchBar.text?.isEmpty)! {
            tempArray = itemArray
        }else{
            tempArray = itemArray.filter({(contact) -> Bool in
                return contact.lowercased().contains((searchBar.text?.lowercased())!)
            })
        }
        searchList.reloadData()
    }
    
    func filterTableView(text: String){
        tempArray = tempArray.filter({(mod) -> Bool in
            return mod.lowercased().contains(text.lowercased())
        })
        searchList.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tempArray.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.selectedValue(index: indexPath.row, value: tempArray[indexPath.row], object: tempArray[indexPath.row])
        self.view.endEditing(true)
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "DropDownCell"
        
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
        }
        
        cell!.textLabel!.text = "\(tempArray[indexPath.row])"
        cell!.selectionStyle = .none
      
        cell?.textLabel?.numberOfLines = 0
        cell?.backgroundColor = .white
        return cell!
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
}




