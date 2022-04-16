AS = as -g
LD = ld

SOURCES = $(shell ls *.s)
PROGS = $(SOURCES:%.s=%)

all: $(PROGS)
	@echo "PROGS = $(PROGS)" 

clean:
	$(RM) $(PROGS) *.o

%.o:%.s
	$(AS) -o $@ $<

$(PROGS): %: %.o
	$(LD) -o $@ $<

