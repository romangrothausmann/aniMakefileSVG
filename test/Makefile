
SHELL:= /bin/bash
GVmake=$(MAKE) #any line with $(MAKE) gets exectued even with -n, GVmake should merely be used for makefile-visualization to avoid its execution with -n



.PHONY: all clean

all : x.z

clean:
	-rm all.gv stime.lst
	-rm all.dot.Make.svg all.dot.Make.asvg all.dot.Make.avi all.dot.Make.mp4
	-rm divx2pass.log divx2pass.log.mbtree x.a x.a.stime x.b x.b.stime x.z x.z.stime
	-rm x_t1_t2.c x_t1_t2.c.stime
	-rm x.y x.y.stime



%_t1_t2.c: %.a
	touch $@.stime
	sleep 2
	touch $@

%.b: %.a
	touch $@.stime
	sleep 1
	touch $@

%.z: %_t1_t2.c %.b x.y
	touch $@.stime
	sleep 4
	touch $@

x.y:
	touch $@.stime
	sleep .2
	touch $@

%.a:
	touch $@.stime
	sleep 3
	touch $@



stime.lst : all
	for i in `find -name '*.stime'`; do \
	    printf "%s\t%s\t%s\n" \
		`ls -lgG --time-style='+%s %N' $$i | awk '{printf ("%d", ($$4 + $$5/1e9)*1e3)}'` \
		` ( ls -lgG --time-style='+%s %N' $${i%.stime} || ls -lgG --time-style='+%s %N' $${i%.stime}.gz ) | awk '{printf ("%d", ($$4 + $$5/1e9)*1e3)}'` \
		$${i%.stime} ; \
	done > $@


## below a rule with "make", a very special case for NOT using $(MAKE) or +make
### lines that contain "$(MAKE)" even in a comment get exectued even with -n|--dry-run !!!
%.gv : % Makefile $(MAKEFILES) # put % to get executed after target has been made to avoid make2graph error due to missing files; http://www.gnu.org/software/make/manual/make.html#MAKEFILES-Variable
	$(GVmake) -Bnd $* | make2graph > $@ # DO NOT PUT a comment with make-var here


## prevent removal of any intermediate files
.SECONDARY: 
