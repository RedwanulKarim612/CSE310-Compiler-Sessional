yacc -d -y  1805111.y
g++ -w -c -o y.o y.tab.c
lex 1805111.l
g++ -w -c -o l.o lex.yy.c -lfl
g++ -w y.o l.o -lfl -o b
