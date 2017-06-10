//
//  ViewController.swift
//  WordSelector
//
//  Created by Luca on 2/25/17.
//  Copyright © 2017 Luca. All rights reserved.
//

import UIKit
import GameplayKit


class ViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    //MARK: Properties
    @IBOutlet weak var randomWordLabel: UILabel!
    @IBOutlet weak var wordTextfield: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    
    var words: [String] = []
    var wordDictionary: [String:[String]] = [:]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        wordTextfield.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tap(gesture:)))
        view.addGestureRecognizer(tapGesture)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Clear Entries", style: .plain, target: self, action: #selector(clearEntries(_:)))
      
    }
    
    override func viewWillAppear(_ animated: Bool) {
        wordDictionary = WordManager.sharedInstance.wordDictionary
        if !WordManager.sharedInstance.currentlySelectedWords.isEmpty {
             words = WordManager.sharedInstance.currentlySelectedWords
        }
        tableView.reloadData()
        print(wordDictionary)
        
    }
    
    // MARK: UITextFieldDelegate
    func textFieldDidEndEditing(_ textField: UITextField) {
        wordTextfield.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        words.append(wordTextfield.text!)
        wordTextfield.text = ""
        wordTextfield.resignFirstResponder()
        tableView.reloadData()
        scrollToBottomOfView()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard string.characters.count > 0 else {
            return true
        }
        
        let currentText = textField.text ?? ""
        
        let prospectiveText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        return prospectiveText.characters.count <= 30
    }
    
    func clearEntries(_ sender: UIButton) {
        words = []
        tableView.reloadData()
    }
    
    // MARK: UITableViewDelegate
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return words.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "word", for: indexPath)
        cell.textLabel?.text = words[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            words.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)  
        }
    }
    
    // MARK: Scroll to bottom
    func scrollToBottomOfView() {
        let indexPath = IndexPath(row: words.count - 1, section: 0)
        self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
    
    // MARK: Keyboard
    
    func tap(gesture: UITapGestureRecognizer) {
        wordTextfield.resignFirstResponder()
    }
    
    // MARK: Data Management
    func saveData() {
        let dictionary = WordManager.sharedInstance.wordDictionary
        UserDefaults.standard.setValue(dictionary, forKey: "wordList")
        
       
    }
    
    // MARK: Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // pass in data to SavedListTableViewController
        if segue.identifier == "load" {
            let savedListVC = segue.destination as! SavedListTableViewController
            print(wordDictionary)
            savedListVC.dictionary = wordDictionary
            WordManager.sharedInstance.wordDictionary = wordDictionary
        }
    }
       
    //MARK: Actions
    
    @IBAction func randomizeWords(_ sender: UIButton) {
        wordTextfield.resignFirstResponder()
        // If there is at least one entry then shuffle the array.
        if !words.isEmpty {
            randomWordLabel.text = words[Int(arc4random_uniform(UInt32(words.count)))]
        }
    }
    
    @IBAction func enterWord(_ sender: UIButton) {
        
        if wordTextfield.text != "" {
            words.append(wordTextfield.text!)
            wordTextfield.text = ""
            wordTextfield.resignFirstResponder()
            tableView.reloadData()
            scrollToBottomOfView()
        }
    }
    @IBAction func saveList(_ sender: UIButton) {
        if !words.isEmpty {
        
            let ac = UIAlertController(title: "Enter Title", message: nil, preferredStyle: .alert)
            ac.addTextField()
            
            let submitAction = UIAlertAction(title: "Submit", style: .default) { [unowned ac] _ in
                let title = ac.textFields![0]
                let key = title.text
                let value = self.words
                if key == ""{
                    let ac2 = UIAlertController(title: "You must give this list a title!", message: nil, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
                    
                    ac2.addAction(okAction)
                    self.present(ac2, animated: true)
                    return
                    
                }
                
                if self.wordDictionary[key!] == nil {
                    self.wordDictionary[key!] = value
                    WordManager.sharedInstance.wordDictionary = self.wordDictionary
                    print(self.wordDictionary)
                    self.saveData()
                } else {
                    let ac3 = UIAlertController(title: "There's already a title with this name. Overwrite?", message: nil, preferredStyle: .alert)
                    let confirmAction = UIAlertAction(title: "Confirm", style: .default) { _ in
                        self.wordDictionary[key!] = value
                        WordManager.sharedInstance.wordDictionary = self.wordDictionary
                        self.saveData()
                        
                    }
                    let cancelAction2 = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                    
                    ac3.addAction(confirmAction)
                    ac3.addAction(cancelAction2)
                    self.present(ac3, animated: true)
                }
                print(self.wordDictionary)
                
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            ac.addAction(submitAction)
            ac.addAction(cancelAction)
            present(ac, animated: true)
        }else{
            let ac = UIAlertController(title: "You can't save a list with no entrys!", message: nil, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
            
            ac.addAction(okAction)
            self.present(ac, animated: true)
        }
        
    }
}

extension String {
    func appendingPathComponent(_ string: String) -> String {
        return URL(fileURLWithPath: self).appendingPathComponent(string).path
    }
}
