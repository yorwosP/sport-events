# Sport Events

A small iOS app showing upcoming sport events. The events are retrieved from an API and shown in a table view, where each row shows the sport type and related events sorted by event start date. 


## Features

- Events are shown horizontally in the sport row, and user can scroll through them, sorted by event date (sooner first) 
- User can mark/unmark one (or many events) as favourite. Favourites move to the start of the row, with respect to the event date (favourites are always shown first, but still in date order)
- Each event has a countdown timer to the start date/time
- Sport rows can be collapsed (i.e not show the events) or expanded. By default, they are shown expanded unless a sport doesn't have any upcoming events to show
- When collapsed, the sport row shows the number of events 
- A navigation bar is shown at the top with the logo of the app.


## Design of the app

The app is designed following MVC pattern: 

- Sports are rows in a Table View (TV) and events are Collection Views (CV) in the rows (one collection view per row) with scroll direction: horizontal

- There is a single View Controller (VC) that controls (delegate, data source, etc)  both the TV and all the CVs. 
- Both TV and CVs are controlled by the View Controller
- TV and CV cells are custom cells (with accompanied  XIB files).
 
No third party libraries are used 

### Table View Custom Cell (SportTableViewCell)
TV cell is separated in 2 parts (UIViews): 
1. top part (sport section) to show:
	- sport "icon" (sport emoji to be exact) 
	- sport name
	- either a collapse "icon" (character "^") or a small view with a text label showing the events count
2. details part  which hold the collection view with the events. 

The TV cell view is responsible for
 - handling the actual expansion or collapse of the details view
 - layout the data passed by the VC

### Collection View Custom Cell (EventCollectionViewCell) 

CV cell has:
-  a text label to show the countdown in 2 lines (days and HH:MM:SS)
- a "dummy" UIbutton (user interaction is disabled) which shows a star either empty (button disabled state) or filled (enabled) 
- a text showing the actual event

This view is responsible for laying out the data passed from the VC and also for: 

- updating the countdown each second (each cell holds a recurring timer) 
- converting the date/time provided (in Unix time) to a more sensible format. 
- setting the star button to enabled (highlighted) or disabled, depending if this event is favourite or not

### View Controller (MainViewController)


VC holds the actual table view and it is set as its data source and delegate. 

Each time  table view asks  for a row (cell), VC will set the Table cell's Collection View cell delegate and data source to itself. So each CV is linked to the view controller as well

VC implements the collection view methods so it can pass data to the event cells when asked (more info below in implementation details).

VC is also responsible for fetching (and decoding) the data from the API. 
Since throughout the app lifecycle, only one request is sent, it was decided to do that in VC rather than the model for simplicity. 

### Model (Sport)
The model is just 2 structs: Sport and Event. Sport holds an array of Event(s). It maps the JSON structure so it is used for the decoding of the response from the API. 
2 additional properties (not found in the JSON object) are added: 

- isStarred in Event to track the favourite events.
- isSelected in Sport to track which Sports are expanded

This breaks the MVC concept, since Model shouldn't be aware of any presentation details, but again it was decided to follow this approach for simplicity  


## Implementation Details

### 1. Setup of the table view
As soon as the view controller is loaded (viewDidLoad) it setups the table View (registers the NIB of the custom cell, sets delegate and data source etc) 


### 2. Retrieval of data from API
Also in viewDidLoad an async request (URLSession data task) is sent to the API. 
Upon retrieval of JSON data, VC uses the Sport struct (Codable) to decode the data. 
The data is cleaned up, by removing past events and sorting by start date (sooner first) and then fed to a Sport array. If a Sport object has no events then its isSelected property is set to false (all other to true) 

### 3. Coordination (mapping) between table view and collection view
VC can reference the TV with a static outlet set. 
However, for the collection views this cannot be done: collection views are created dynamically and are volatile (since they exist within re-usable cells). To overcome this the following approach was followed: 
- Each table view cell has an outlet to the collection view is holding 
- Each time a cell is requested by the Table View (cellForRow) VC does 2 things:
	- sets its collection view delegate/data source to self
	- sets a tag to the collection view. The tag is the same as the current indexPath.row and consequently to the index of the specific Sport in the Sport array (indexPath.row == index for specific sport in sports array == tag)
	- When a collection view asks for a cell (cellForItemAt), VC will inspect it's  tag and use this mapping (sports[tag].events[indexPath.row]) to retrieve the appropriate data  

### 4. Expand/collapse the cells
Each time a row is selected (didSelectRowAt), VC will toggle the isSelected property in its array and reload the specific row (reloadRows)
This will inform the corresponding TableView cell for the new data. The cell has a constraint for the height (fixed size) of its "details" view. If the isSelected is set to false the height constraint is set to 0, else is set to the predefined height. Due to reloadRows this action is also animated. 
Cell has also an events count label which sits on top of the expand icon. 
Its opacity is set to either 0 if isSelected is set (true) or 1 if it is false. The opacity change is animated (UIView.animate)

### 5. Mark/unmark an event as favourite
Each time a collection view is selected (didSelectItemAt) VC does the following: 
1. Toggle the isHighlighted value in the model
2. Notify the cell (cell.isFavorite =...) that the state has changed
3. Finds the new position to put the item. It does that by: 
	 - making a copy of the array sorted by isHighlighted and start date (isHighlighted is primary in the comparison)
	 - finds the index of this event in the new array
4. deletes the event from the array and the collection view and adds it to the new position (within performBatchUpdates). Since this is an action in the table view, it is animated automatically

the cell view sets its star button to enabled/disabled which changes its appearance

### 6. Countdown to event

This is handled by the collection view cell as follows: 
Cell has a function that takes the epoch time, calculates the difference to the current date/time and breaks it to days, hours, minutes, seconds (using Calendar's dateComponents). It also stores the epoch time 
Each cell also has a timer running each second and calling this function. Timer is invalidated in prepare for reuse.


## TODO

- handle connection error and give an option to the user to retry
- handle json invalid data
- decouple model and VC 
- maybe use a single timer in the VC that will run in the main queue (no interruption upon user interaction) 

