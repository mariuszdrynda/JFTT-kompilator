all:
	bison -yd skladniowy.y
	flex -o 1.c leksykalny.l
	g++ y.tab.c y.tab.h 1.c -std=c++11 -lfl
