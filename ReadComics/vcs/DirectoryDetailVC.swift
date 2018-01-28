//
//  DirectoryDetailVC.swift
//  ReadComics
//
//  Created by Javi Manzano on 25/01/2018.
//  Copyright © 2018 Javi Manzano. All rights reserved.
//

import UIKit

class DirectoryDetailVC: UITableViewController {
    
    let apiClient = ReadComicsApiClient.sharedInstance
    
    enum TableSection: Int {
        case comics = 0, directories
    }
    
    let SectionHeaderHeight: CGFloat = 25
    
    var tableData = [TableSection: [Any]]()
    
    var directory: Directory?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableData[.comics] = [Comic]()
        tableData[.directories] = [Directory]()
        
        // Set table cells automatic height
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.estimatedRowHeight = 64
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // Pull to refresh
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(self.reloadDirectory as () -> Void), for: UIControlEvents.valueChanged)
        if let refreshControl = refreshControl {
            tableView.addSubview(refreshControl)
        }
        
        reloadDirectory()
    }


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "readComic" {
            let destination = segue.destination as! ReadComicVC
            destination.comic = sender as? Comic
        }
    }
    
    // MARK: - IBActions
    
    @IBAction func backToParent(_ sender: Any) {
        if directory != nil {
            directory = directory!.parentDirectory
            reloadDirectory()
        }
    }
    
    
    // MARK: - Table View
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return tableData.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let tableSection = TableSection(rawValue: section), let itemData = tableData[tableSection]
        {
            return itemData.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // If we wanted to always show a section header regardless of whether or not there were rows in it,
        // then uncomment this line below:
        //return SectionHeaderHeight
        // First check if there is a valid section of table.
        // Then we check that for the section there is more than 1 row.
        if let tableSection = TableSection(rawValue: section), let itemData = tableData[tableSection], itemData.count > 0 {
            return SectionHeaderHeight
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: SectionHeaderHeight))
        view.backgroundColor = UIColor(red: 253.0/255.0, green: 240.0/255.0, blue: 196.0/255.0, alpha: 1)
        let label = UILabel(frame: CGRect(x: 15, y: 0, width: tableView.bounds.width - 30, height: SectionHeaderHeight))
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textColor = UIColor.black
        if let tableSection = TableSection(rawValue: section) {
            switch tableSection {
            case .comics:
                label.text = "Comics"
            case .directories:
                label.text = "Directories"
            }
        }
        view.addSubview(label)
        return view
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        // Similar to above, first check if there is a valid section of table.
        // Then we check that for the section there is a row.
        if let tableSection = TableSection(rawValue: indexPath.section),
            let item = tableData[tableSection]?[indexPath.row]
        {
            if let directory = item as? Directory {
                cell.textLabel!.text = directory.title
            } else if let comic = item as? Comic {
                cell.textLabel!.text = comic.title
            } else {
                cell.textLabel!.text = "Not a comic, nor a directory"
            }
            
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let tableSection = TableSection(rawValue: indexPath.section) else {
            return
        }
        guard let indexPath = tableView.indexPathForSelectedRow as IndexPath! else {
            return
        }
        
        if tableSection == TableSection.comics {
            let comic = self.tableData[TableSection.comics]?[indexPath.row] as? Comic
            performSegue(withIdentifier: "readComic", sender: comic)
        } else {
            self.directory = self.tableData[TableSection.directories]?[indexPath.row] as? Directory
            reloadDirectory()
        }
    }
    
    // MARK: - Private
    
    @objc
    private func reloadDirectory () -> Void {
        self.refreshControl?.beginRefreshing()
        
        tableData[.comics] = []
        tableData[.directories] = []
        
        self.tableView.reloadData()
        
        apiClient.getDirectoryContents(directory: directory, onItemsFetched:{ (comicList, directoryList) in
            self.tableData[TableSection.comics] = comicList
            self.tableData[TableSection.directories] = directoryList
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
            }, onError: {
                self.refreshControl?.endRefreshing()
            })
    }

}
