## What is it? ##

Couch Slouch allows, with the appropriate hardware, control of your Mac through the Consumer Electronics Control (CEC) protocol on the HDMI bus. More info on CEC [here](http://en.wikipedia.org/wiki/Consumer_Electronics_Control#CEC).

In plain English: Use your TV's remote control to control your Mac!

Couch Slouch requires Mac OS X 10.8 (Mountain Lion) to build and run.

## What is the "appropriate hardware"?

Currently, the only supported device is the USB-CEC Adapter by [Pulse-Eight](http://www.pulse-eight.com/store/).

## License ##

Couch Slouch is licensed under three-clause BSD. The license document can be found [here](https://github.com/iKenndac/Couch-Slouch/blob/master/LICENSE.markdown).

## Building ##

1. Clone Couch Slouch using `git clone --recursive git://github.com/iKenndac/Couch-Slouch.git` to make sure you get all the submodules too.
2. If you got excited and cloned the repo before reading this, run `git submodule update --init` in the Couch Slouch directory to grab the submodules. If I get tickets about it not building and you haven't got the submodules checked out, you lose 5 internet points!
3. Build away!