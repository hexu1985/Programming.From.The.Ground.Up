
# This quick and dirty makefile for  
# Programming from ground up vol.1 book by
# Jonathan Bartlett written by hands

# I strongly adivise you against making 
# your own makefile by hand from scratch
# There are enormous amount of files 
# written by hand by authors who tought
# (and still thinks) that they are absolutely sure
# what they are doing! They are mistaken!

# Use CMake, or similar tools instead!

.POSIX:
.SUFFIXES:

AS ?= as
ASFLAGS += --32
LD ?= ld
LDFLAGS += -melf_i386

MAXIMUMPROGRAM ?= maximum-4
MAXIMUMPROGRAMOBJ := maximum-4.o

INTEGERTOSTRINGOBJ := integer-to-string.o

COUNTCHARSOBJ := count-chars.o


.PHONY: all

all: maximum-4

integer-to-string.o: integer-to-string.s
	$(AS) $(ASFLAGS) $? -o $@

count-chars.o: count-chars.s
	$(AS) $(ASFLAGS) $? -o $@

maximum-4.o: maximum-4.s
	$(AS) $(ASFLAGS) $? -o $@

maximum-4: integer-to-string.o count-chars.o maximum-4.o
	$(LD) $(LDFLAGS) $? -o $@

clean:
	rm -f $(MAXIMUMPROGRAM) $(MAXIMUMPROGRAMOBJ) $(INTEGERTOSTRINGOBJ) $(COUNTCHARSOBJ)
