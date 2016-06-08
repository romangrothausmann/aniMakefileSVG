# aniMakefileSVG
animate a graphviz SVG visualization of dependencies defined by a Makefile according to the duration of each file creation

<img src="http://romangrothausmann.github.io/aniMakefileSVG/all.dot.Make.svg" width="250">
<img src="http://romangrothausmann.github.io/aniMakefileSVG/all.dot.MakeJ1.svg" width="250">
<img src="http://romangrothausmann.github.io/aniMakefileSVG/all.dot.MakeJ6.svg" width="250">

Using [make2graph](https://github.com/lindenb/makefile2graph), the Makefile in the test directory leads to the static visualization as visible in the left SVG.
In combination with the start and end times of the file creation (simulated by sleep in the test Makefile) and [aniMakefileSVG.pl](aniMakefileSVG.pl) this SVG can be animated.
The animated SVG (aSVG) in the middle shows the result from `make` working in serial mode (`-j1`) and the aSVG on the right from `make` working in parallel (e.g. `-j6`).

The animation is realized with SMIL (apparently the least invasive method). 
The aSVG can be "rendered"/converted into videos with e.g. 
[MP4client](https://gpac.wp.mines-telecom.fr/), 
[SVG Salamander](http://java.net/projects/svgsalamander) or 
[canvg](http://superuser.com/questions/48532/convert-animated-svg-to-movie#353207), 
e.g. in case [SMIL gets deprecated](https://developer.mozilla.org/en-US/docs/Web/SVG/SVG_animation_with_SMIL) in recent web-browsers.
