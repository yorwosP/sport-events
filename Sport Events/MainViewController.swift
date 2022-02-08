//
//  ViewController.swift
//  Sport Events
//
//  Created by Yorwos Pallikaropoulos on 2/5/22.
//

import UIKit

class MainViewController: UIViewController {
    
    // MARK: - properties
    
    private var sports = [Sport]() // holds all the data
    private var currentDateInEpoch: Int{
        get{
            return Int(Date().timeIntervalSince1970)
        }
    }
    
    
    
    

    
    // MARK: - outlets
    @IBOutlet var tableView: UITableView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    
    //MARK: - View lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTable()
        fetchSportEvents()
        
        // start the timer to update the cells
        let timer = Timer(timeInterval: 1, target: self, selector: #selector(refreshTimeouts), userInfo: nil, repeats: true)
        RunLoop.current.add(timer, forMode: .common)
        let topLogo = UIImageView(image: UIImage(named: "top logo small"))
        topLogo.contentMode = .scaleAspectFit
        navigationItem.titleView = topLogo
        
    }

    
    // MARK: - Fetch Data

    
    // connect to API and get sport events
    // since we only have one request keeping this logic
    // in VC instead of the model (for simplicity)
    private func fetchSportEvents(){
        
        // prepare the url request
        var urlRequest = URLRequest(url:API.url)
        urlRequest.httpMethod = API.method
        urlRequest.addValue(API.header, forHTTPHeaderField: API.httpContentType)
        urlRequest.addValue(API.header, forHTTPHeaderField: API.httpAccept)
        
        // create the task
        URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            
            if let _ = error{
                // TODO: handle error
                print("error receiving data")

            }else{
                // received some response. check if it is valid
                if let httpResponse = response as? HTTPURLResponse{
                    //we have received some kind of response. check if it is an ok response
                    if (0...299).contains(httpResponse.statusCode){ //2xx response

                        // got some data, try to decode them
                        let jsonDecoder = JSONDecoder()
                        // TODO: - handle cases when data is invalid
                        if let responseData = data{
                            if let sports = try? jsonDecoder.decode([Sport].self, from: responseData){
                                // basic cleanup of events
                                for sport in sports{
                                    //throw out past events
                                    let events = sport.events.filter {
                                        $0.eventStartDate > self.currentDateInEpoch
                                    }.sorted{
                                        // and sort them by date
                                        $0.eventStartDate < $1.eventStartDate
                                    }
                                    // update the events array
                                    var modifiedSport = sport
                                    modifiedSport.events = events
                                    // congfigure the isSelected, so empty cells start in collapsed state
                                    modifiedSport.isSelected = events.count > 0 ? false : true
                                    self.sports.append(modifiedSport)
                                }
                            }
                            // TODO: -  handle cases when data cannot be decoded
                        }
                        // Done. Reload data in tableView
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }else{
                        
                        // TODO: handle non 2xx response
                        
                    }
                }
            }
            // stop indicator
            DispatchQueue.main.async{
                self.activityIndicator.stopAnimating()
            }
        }.resume()
        
    }

    // MARK: - refresh timeout in every visible cell
    @objc private func refreshTimeouts(){
        guard let visibleTableViewCells = tableView.visibleCells as? [SportTableViewCell] else{
            return
        }
        
        for tableViewCell in visibleTableViewCells{
            guard let visibleCollectionViewItems = tableViewCell.eventsCollectionView.visibleCells as? [EventCollectionViewCell] else { return }
            for visibleItem in visibleCollectionViewItems{
                visibleItem.refreshTimeout()
            }

                
            }

        }
    
        


}




// MARK: - tableView methods
extension MainViewController: UITableViewDelegate, UITableViewDataSource{
    
    // register the nib and set data source and delegate
    func setupTable(){
        
        tableView.register(SportTableViewCell.nib(), forCellReuseIdentifier: SportTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = UI.estimatedRowHeight
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sports.count
    }
    
    // create a cell and return it to the tableView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: SportTableViewCell.identifier,
            for: indexPath)
        as! SportTableViewCell // if we cannot get the custom cell, something went terribly wrong (better crash than hide it)
        
        // will map the collection view for this TV cell with the index of the sport (in the model array)
        // (indexPath.row == index for specific sport in sports array == tag)
        let tag = indexPath.row
        let sport = sports[tag]
        
        // get the sport icon for this sport, or use a predefined sport icon
        let sportIcon = UI.sportIcons[sport.sportID, default: UI.defaultIcon]
        
        // configure the cell
        cell.configure(sport: sport.sportName,
                       icon: sportIcon,
                       delegate: self,
                       tag: tag,
                       eventsCount: sport.events.count,
                       isExpanded: !sport.isSelected)
        
        // register the custom NIB (collection View) for cell reuse
        cell.eventsCollectionView.register(EventCollectionViewCell.nib(), forCellWithReuseIdentifier: EventCollectionViewCell.identifier)
        
        return cell
    }
    
    // if row is selected, toggle the expand/collapsed state
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        sports[indexPath.row].isSelected = !sports[indexPath.row].isSelected
        // use reloadRows also for the animation it provides
        tableView.reloadRows(at: [indexPath], with: .none)
    }
}

// MARK: - collection view methods

extension MainViewController: CollectionViewCombined{

    
    // the map to the model is as follows:
    // sport = sports[tag] (because tag is assigned based on the model's array index)
    // events = sport.events
    // specific event this cell is referencing --> event = sports[tag].events[indexPath.row]
    

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let tag = collectionView.tag
        return sports[tag].events.count
    }
    
    // create a cell and return it to the collectionView
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath)
                        -> UICollectionViewCell {
        // retrieve the specific event from the model
        let tag = collectionView.tag
        let event = sports[tag].events[indexPath.row]
        
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: EventCollectionViewCell.identifier,
            for: indexPath)
        as! EventCollectionViewCell // --> if we cannot get the custom cell, something went terribly wrong (better crash than hide it)
        // configure and return cell
        cell.configure(event: event.eventName, eventDate: event.eventStartDate, isFavorite: event.isStarred)
        return cell
        
    }
    // Provide the collectionView size (0,0 if the TV cell is collapsed)
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let tag = collectionView.tag
        let isExpanded = !sports[tag].isSelected
        return isExpanded == true ? UI.collectionViewStandardItemSize : CGSize(width: 0, height: 0)

    }
    
    // used to star/un-star an item (favourite)
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {

        // first deselect the item
        collectionView.deselectItem(at: indexPath, animated: false)

        // retrieve the tag so we can map the model
        let tag = collectionView.tag
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? EventCollectionViewCell else {
            return
        }
            
        
        // 1.update the model (toggle the value)
        sports[tag].events[indexPath.row].isStarred = !sports[tag].events[indexPath.row].isStarred

        // 2.notify the cell that the state changed
        cell.isFavorite = sports[tag].events[indexPath.row].isStarred
        // 3. find the new position to put the item
        //    instead of trying to find out where the correct position is
        //    we will:
        //      a. create a sorted array (what should look like after the operation)
        //      b. find the index of the element in this target array
        
        // a. Sort the array with primary key isStarred and secondary event date
        let events = sports[tag].events
        let sortedArray = events.sorted {
            // if both are starred/unstared (?) sort by secondary (event date) else (:) sort by primary (isStarred)
            $0.isStarred == $1.isStarred ? $0.eventStartDate < $1.eventStartDate : $0.isStarred && !$1.isStarred
        }

        // b. now get the new position of the event
        let event = sports[tag].events[indexPath.row]
        let newPosition = sortedArray.firstIndex { $0 == event }!

        // 4. move it to that position (both in the model and in the collection view)

        collectionView.performBatchUpdates {
            sports[tag].events.remove(at: indexPath.row)
            sports[tag].events.insert(event, at: newPosition)
            collectionView.deleteItems(at: [indexPath])
            collectionView.insertItems(at: [IndexPath(row: newPosition, section: 0)])
            collectionView.reloadData()
        }
    }
    
}


