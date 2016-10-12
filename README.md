# Pango (& Glib)

## INFO

Block that wraps the [Pango](http://www.pango.org/) text layout and rendering library. Includes an installation script for building on multiple platforms.

## INSTALLATION

- First, `git clone git@github.com:ryanbartley/Cinder-Pango.git`. 
- Make sure you've pulled [this](https://github.com/ryanbartley/Cinder/tree/CairoUpdate) branch of Cinder from my repo, which currently contains the needed Cairo build dependencies. Follow the instructions [here](https://github.com/ryanbartley/Cinder/blob/CairoUpdate/blocks/Cairo/README.md) to build the libraries for your current platform. (This will hopefully be merged soon, making this step unneeded.)
- Also, make sure you have the [Cinder-Harfbuzz](https://github.com/ryanbartley/Cinder-Harfbuzz) block. (Note: You don't have to build the Harfbuzz block if you're only using it with this block, as the included install here will build Cinder-Harfbuzz automatically with the needed dependencies. You can of course, build Harfbuzz as a standalone, but it won't be used by this.)
- You'll notice that this block doesn't contain the normal `lib/` and `include/` folders, as much of this is still in the experimental phase and supports building on multiple platforms. This support is found in the `install/` folder.
- On Mac and Linux, `cd install && ./install.sh [platform]` to build the Pango library. Possible choices for [platform] are `linux`, `macosx`. Note: iOS functionality not included because the scripts and dependencies aren't really able to configure for iOS. Also, the licensing of Pango is a little hairy for iOS, more below.
- On Windows, open a visual studio command prompt for the platform you'd like to build for. Then `cd path\to\Cinder-Pango\install && install.bat`. 
- These scripts will build for a while, go get some coffee. Then, you'll be left with Pango libraries and includes in the normal Cinder block format of `lib/[platform]` and `include/[platform]`.
- Like the cairo block, after the build, there'll be a `tmp/` folder left in the install folder containing the final install folders built from the script and useable for other libraries that depend on it.

## LICENSE NOTE

The licensing of Pango is more complicated than Cinder, which is why the block exists. Pango and Glib are under LGPL v3. The pertinent difference in the license is this...

>The license only requires software under the LGPL be modifiable by end users via source code availability. For proprietary software, code under the LGPL is usually used in the form of a shared library such as a DLL, so that there is a clear separation between the proprietary and LGPL components.

...Basically, you have to modify your build and include. In the future, I hope to make this part "easy" for the end user but right now, you're on your own when using this block. As mentioned above, this license frustratingly makes this block nearly unusable on iOS. However, I would like to try and build support in for it.
