//
//  eventCollectionViewCell.swift
//  Sport Events
//
//  Custom Collection View's cell
//  Created by Yorwos Pallikaropoulos on 2/4/22.
//

import UIKit

class EventCollectionViewCell: UICollectionViewCell {
    
    // MARK: - private properties
    private weak var timer:Timer! // used to update the countdown
    private var eventDateInEpoch: Int = 0 // holds the event date in epoch (Unix) time
    

    
    // MARK: - reuse identifier and nib
    static let identifier = "eventCell"
    static func nib() -> UINib{
        return UINib(nibName: "EventCollectionViewCell", bundle: nil)
        
    }
    
    // MARK: - outlets

    @IBOutlet private weak var countDownLabel: UILabel!
    @IBOutlet private var starButton: UIButton!
    @IBOutlet private var eventDetailLabel: UILabel!
    

    // MARK: - configure the cell with the data passed from VC
    func configure(event:String, eventDate: Int, isFavorite: Bool){
        
        self.eventDateInEpoch = eventDate  //keep it to track the countdown
        updateCountdown(eventDate)
        eventDetailLabel.text = event.replacingOccurrences(of: " - ", with: "\n")
        self.isFavorite = isFavorite
        // set a timer for 1 sec, to update the countdown
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] _ in
            // don't want to keep a reference to the timer if the cell is thrown out
            guard let self = self else { return }
            self.updateCountdown(self.eventDateInEpoch)
        })

    }
    
    // receives a date in epoch time
    // calculates the difference in d/h/m/s
    // and updates the countDownLabel
    func updateCountdown(_ eventDateInEpoch: Int){
        self.eventDateInEpoch = eventDateInEpoch
        // calculate the time difference between today and the event date
        let dateNow = Date()
        let eventDate = Date(timeIntervalSince1970: Double(eventDateInEpoch))
        // break it to days/hours/minutes
        let diffDateComponents = Calendar.current.dateComponents(
            [.day, .hour, .minute, .second],
            from: dateNow,
            to: eventDate)
        // configure the text to show (add leading zeros if needed (in hours, minutes, seconds)
        let string = String(format: "%dd\n%02d:%02d:%02d", //eg "5 days\n 09:45:00"
                            diffDateComponents.day ?? 0,
                            diffDateComponents.hour ?? 0,
                            diffDateComponents.minute ?? 0,
                            diffDateComponents.second ?? 0)
        
        // function is  called from another queue (due to timer)
        // dispatch it to the main queue (since it's UI stuff)
        DispatchQueue.main.async {
            self.countDownLabel?.text = string
            self.countDownLabel?.setNeedsDisplay()
        }
 
    }
    
    var isFavorite:Bool = false{
        didSet{
            starButton.isEnabled = isFavorite
        }
    }
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // setup the favourite (star) button for enabled/disabled state
        starButton.setTitle("★", for: .normal)
        starButton.setTitleColor(.yellow, for: .normal)
        starButton.setTitle("☆", for: .disabled)
        starButton.setTitleColor(.white, for: .disabled)

    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        starButton.isEnabled = false
        timer?.invalidate() // lose the timer
    }

}
