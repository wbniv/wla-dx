CC = $(WLAVALGRIND) wla-gb
CFLAGS = -i -x -o
LD = $(WLAVALGRIND) wlalink
LDFLAGS = -i -v -c -s

all: linked.gb check

linked.gb: a.o b.o main.o makefile
	$(LD) $(LDFLAGS) linkfile linked.gb

a.o: a.s
	$(CC) $(CFLAGS) a.o a.s

b.o: b.s
	$(CC) $(CFLAGS) b.o b.s

main.o: main.s
	$(CC) $(CFLAGS) main.o main.s

check: linked.gb
	byte_tester -s main.s

clean:
	rm -f a.o b.o main.o core *~ linked.gb linked.sym *.lst
