# Location Images
<img src="https://github.com/elina-mns/Virtual-Tourist/blob/main/map.png"
align="right" width=200/>
Virtual map with location images associated with the pin placed by user.

## _Description_

This app allows users specify travel locations around the world, and create virtual photo
albums for each location. The locations and photo albums are stored in Core Data. 
The posted pins are saved when a user quits the application.
When user taps on a pin, there is a collection view with images from Flickr associated with the pin placed. 

This project is a part of iOS online degree which allows to dowload images from Flickr open API. 

The app has two view controller scenes:
* Map: allows to place pins, save them 
* Detailed map and images collection: allows to see all the pictures connected to the pin

### _Map_ 
When the app first starts it will open to the map view. User will be able to zoom and scroll around the map using standard pinch and drag gestures.
If the app is turned off, the map returns to the same state when it is turned on again. 
Tapping and holding the map drops a new pin. Users can place any number of pins on the map. 
When a pin is tapped, user can delete pin or go to _Info_ `(i)` tab which navigate to the Photo Album view associated with the pin.

### _Detailed map and images collection_
If the user taps a pin that does not yet have a photo album, the app will download Flickr images associated with the latitude and
longitude of the pin. 
If no images are found a `No Images found` label is displayed. 
If there are images, then they will be displayed in a collection view.
While the images are downloading, the photo album is in a temporary “downloading” state in which the `New Collection` button is disabled. 
Once the images have all been downloaded, the app enables the `New Collection` button at the bottom of thepage. 
Tapping this button empties the photo album and fetch a new set of images. User can remove photos from an album by tapping them. 
Pictures flow up to fill the space vacated by the removed photo.
Tapping the back button return the user to the Map view.
If the user selects a pin that already has a photo album then the Photo Album view displays the album and the New Collection button is enabled.


## _Skills that were developed_

* Accessing networked data using Apple’s URL loading framework
* Creating user interfaces that are responsive, and communicate network activity
* Use Core Location and the MapKit framework for to display annotated pins on a map
* Use Core Data to save pins placed on the map 
