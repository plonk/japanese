LEX=flex
YACC=bison

all: sa

clean:
	rm *.o lexer.c japanese.tab.c

sa: lexer.o japanese.tab.o
	$(CC) -o $@ $(LDFLAGS) $^

.o.c:
	$(CC) -o $@ $^

lexer.c: lexer.lex
	$(LEX) -8 -o lexer.c lexer.lex

japanese.tab.c: japanese.y
	$(YACC) -d $^
