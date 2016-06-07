
### exemplary Makefile
## needs a dot/graphviz file (*.gv) and a list of start and end time list (stime.lst)
## run make test/all.gv test/stime.lst to generate exemplary all.gv and stime.lst under test/
## or run make test to also create an animated SVG (test/all.dot.Make.asvg) and its rendered video (test/all.dot.Make.mp4)


SHELL:= /bin/bash


SPACE := $(eval) $(eval)
base_ = $(subst $(SPACE),_,$(filter-out $(lastword $(subst _, ,$1)),$(subst _, ,$1)))
base. = $(subst $(SPACE),.,$(filter-out $(lastword $(subst ., ,$1)),$(subst ., ,$1)))



.PHONY: test



%.asvg : %.svg stime.lst
	$(eval ETIME?= $(shell \
	aniMakefileSVG.pl stime.lst $< $@ ))

%.avi : %.asvg
	$(eval SIZE= $(shell grep -oP 'viewBox="\K.*?(?=")' $< | awk '{printf("%dx%d", $$3-$$1, $$4-$$2)}')) # http://unix.stackexchange.com/questions/13466/can-grep-output-only-specified-groupings-that-match
	MP4Client -no-audio -size $(SIZE)  -avi 0-$(ETIME) -fps 25  $< -out $@

%.mp4 : %.avi
	mencoder $< -o $@  -ovc x264 -x264encopts preset=veryslow:fast_pskip=0:tune=film:frameref=15:bitrate=3000:threads=auto:pass=1  -fps 25 && \
	mencoder $< -o $@  -ovc x264 -x264encopts preset=veryslow:fast_pskip=0:tune=film:frameref=15:bitrate=3000:threads=auto:pass=2  -fps 25





test : test/all test/all.gv test/stime.lst
	$(MAKE) -C test -f ../Makefile all.dot.Make.mp4
	mv test/all.dot.Make.mp4 test/all.dot.MakeJ1.mp4

test/all : test/Makefile
	$(MAKE) -C test clean
	$(MAKE) -C test

test/all.gv : test/Makefile
	$(MAKE) -C test  all.gv

test/stime.lst : test/Makefile
	$(MAKE) -C test  stime.lst

testJ6 : test/allJ6 test/all.gv test/stime.lst
	$(MAKE) -C test -f ../Makefile all.dot.Make.mp4
	mv test/all.dot.Make.mp4 test/all.dot.MakeJ6.mp4

test/allJ6 : test/Makefile
	$(MAKE) -C test clean
	$(MAKE) -j6 -C test


.SECONDEXPANSION: # https://www.gnu.org/software/make/manual/html_node/Secondary-Expansion.html

%.Make.svg : $$(call base.,%).gv # rule should be more specific than %.svg!
	$(eval pos= $(subst $(basename $+),,$*))
	$(eval pos= $(subst .,,$(pos)))

	$(pos) -Tsvg -o $@ $<


## prevent removal of any intermediate files
.PRECIOUS: %.Make.svg %.asvg %.avi


