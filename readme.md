# Cynthcart

A synthesizer program for the Commodore 64 computer designed with live performance in mind. Includes arpeggiator, portamento, stereo SID and MIDI support, realtime filter control, many other features.  The program is written entirely in 6510 assembly language.

![Cynthcart screenshot](images/cynth_screen_main.png) ![Cynthcart SID editor screenshot](images/cynth_screen_sidedit.png)



## Running The Program

Cartridges are available from [Shareware Plus on Ebay](https://www.ebay.com/usr/tim685?_trksid=p2047675.l2559) and the ROM (cynthcart.prg) can be played on emulators like VICE or on real Commodore 64 hardware using an SD2IEC or similar.


### Building From Source

I use the [DASM assembler](http://dasm-dillon.sourceforge.net/) (old DOS/Win version included) to build the game, and the project also uses [Pucrunch](https://github.com/mist64/pucrunch) to compresses the cartridge ROM image to fit into 8K.  More info on assembly coming soon...


## License

©2005-2018 Paul Slocum, All rights reserved.  Source, binary, and other files provided for personal use only.  Will likely eventually switch to an MIT license but I've had problems with people selling poor quality cartridges on ebay.
