
# AirForceOne
a quartz composer patch to display an image on an 2nd generation Apple TV

### HOW TO INSTALL
move AirForceOne.plugin into ~/Library/Graphics/Quartz Composer Plug-Ins/

### NOTES
* the Image Location input should be a fully qualified url with scheme, or a file path relative to the composition
* the image should be sensitive to the 1280x720 display resolution, larger images will take much longer to transmit, while smaller images will be scaled up
* images more than 150% either dimension will be internally resized and JPEG compressed before sent to the Apple TV
* the Apple TV supports the JPEG, GIF and TIFF image formats
* Apple TV's requiring password to access are not yet supported

### THANKS
- Erica Sandun for her AirPlay utility [AirFlick](http://ericasadun.com/ftp/AirPlay/) and [programatic means to use it](https://gist.github.com/755600)
- Norio Nomura for the infinitely helpful [SendToAirFlick](https://github.com/norio-nomura/SendToAirFlick)
- Pascal Widdershoven for [Airplayer](https://github.com/PascalW/Airplayer) which uncovers many details on AirPlay functions
