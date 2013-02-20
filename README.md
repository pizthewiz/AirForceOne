
# AirForceOne
a Quartz Composer plug-in to display an image on a 2nd generation Apple TV

### HOW TO INSTALL
move AirForceOne.plugin into ~/Library/Graphics/Quartz Composer Plug-Ins/

### NOTES
* any AirPlay receiver (without a password) can be targeted, not just an Apple TV
* the Image Location input should be a fully qualified url with scheme, or a file path relative to the composition
* the image should be sensitive to the 1280x720 resolution of the 2nd generation Apple TV, larger images will take longer to transmit, while smaller images will be scaled up
* images more than 150% larger in either dimension will be internally resized and JPEG compressed before being sent to the Apple TV
* the Apple TV supports the JPEG, GIF and TIFF image formats

### THANKS
- Erica Sandun for her AirPlay utility [AirFlick](http://ericasadun.com/ftp/AirPlay/) and [programatic means to use it](https://gist.github.com/755600)
- Norio Nomura for the infinitely helpful [SendToAirFlick](https://github.com/norio-nomura/SendToAirFlick)
- Pascal Widdershoven for [Airplayer](https://github.com/PascalW/Airplayer) which uncovers many details on AirPlay functions
