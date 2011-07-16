
# AirForceOne
a quartz composer patch to output an image to a paired Apple TV 2 through AirFlick

### HOW TO INSTALL
move AirForceOne.plugin into ~/Library/Graphics/Quartz Composer Plug-Ins/

### NOTES
* [AirFlick](http://ericasadun.com/ftp/AirPlay/) must be running and the desired Apple TV 2 selected
* the Image Location may be a file path or a file url
* the on-disk image should be sensitive to the 1280x720 display resolution, larger images will take much longer to transmit, and may not display, while smaller images will be scaled up
* the Apple TV 2 supports the JPEG, GIF and TIFF image formats

### THANKS
- Erica Sandun for her AirPlay utility [AirFlick](http://ericasadun.com/ftp/AirPlay/) and [programatic means to use it](https://gist.github.com/755600)
