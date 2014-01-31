LEX=flex
YACC=bison

all: sa

clean:
	rm *.o lexer.c japanese.tab.c

sa: lexer.o japanese.tab.o
	$(CC) -o $@ $(LDFLAGS) $^

.c.o:
	$(CC) -Wall -c -o $@ $^

lexer.c: lexer.lex japanese.tab.c
	$(LEX) -d -8 -o lexer.c lexer.lex

japanese.tab.c: japanese.y
	$(YACC) -t -d $^
