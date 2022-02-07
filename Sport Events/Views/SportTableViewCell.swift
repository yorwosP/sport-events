//
//  SportTableViewCell.swift
//  Sport Events
//
//  Custom Table View's cell
//
//  Created by Yorwos Pallikaropoulos on 2/4/22.
//

import UIKit

class SportTableViewCell: UITableViewCell{
    
    // MARK: - reuse identifier and nib
    static let identifier = "sportCell"
    static func nib() -> UINib{
        return UINib(nibName: "SportTableViewCell", bundle: nil)
        
    }
    
    // MARK: - outlets
    @IBOutlet var sportSymbolLabel: UILabel!
    @IBOutlet var sportTitleLabel: UILabel!
    @IBOutlet var detailsLabel: UILabel!
    @IBOutlet var countView: UIView!
    @IBOutlet var countLabel: UILabel!
    @IBOutlet weak var eventsCollectionView: UICollectionView! // this will be referenced by the VC (hence weak)
    @IBOutlet var detailViewConstraintHeight: NSLayoutConstraint!  // used for expanding/collapsing the view
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout! // this will be referenced by the VC (hence weak)
    

    // MARK: - properties

    var isExpanded:Bool = true{
        // when set, toggle expansion and change the details icon
        didSet{
            // collapsed state has a view with events count
            detailsLabel.text = isExpanded ? UI.expandedIcon : ""
            // collapse by setting the view's constraint (height) to 0
            detailViewConstraintHeight.constant = isExpanded ? UI.expandedHeight : UI.collapsedHeight
            
            // if expanded hide the count (opacity=0), else show it
            // use an opacity animation
            let fromOpacity:Float = isExpanded ? 1 : 0
            let toOpacity:Float = isExpanded ? 0 : 1
            let delay: Double = isExpanded ? 0 : UI.standardAnimationDuration
            countView.layer.opacity = fromOpacity
            countLabel.layer.opacity = fromOpacity
            UIView.animate(
                withDuration: UI.standardAnimationDuration * 2,
                delay: delay,
                options: .curveEaseIn) {
                    self.countView.layer.opacity = toOpacity
                    self.countLabel.layer.opacity = toOpacity
            }
        }
    }

    

    
    // MARK: - congigure cell with data from VC
    func configure(sport sportTitle:String,
                   icon sportIcon: String,
                   delegate:CollectionViewCombined,
                   tag: Int,
                   eventsCount: Int,
                   isExpanded: Bool = true){
        
        sportSymbolLabel.text = sportIcon
        sportTitleLabel.text = sportTitle
        // expansion and events count could also be considered
        // to be handled by the VC
        countLabel.text = String(eventsCount)
        self.isExpanded =  isExpanded
        // set the data source and delegate for the collection to the VC that called us
        eventsCollectionView.delegate = delegate
        eventsCollectionView.dataSource = delegate
        eventsCollectionView.tag = tag  // used for VC to identify the collection view it's talking to
        eventsCollectionView.reloadData() // make sure that the events are updated (no stale data)
        
    }
    
    

  // MARK: - reset the cell for reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        // reset heigh constraint
        detailViewConstraintHeight.constant = UI.expandedHeight
        setNeedsLayout()
        // remove delegates and data sources of the collection view
        eventsCollectionView.delegate = nil
        eventsCollectionView.dataSource = nil
  
    } 
}

