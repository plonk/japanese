%{
 #include <stdio.h>
 #include <string.h>
 #include <stdarg.h>
 int yylex(void);
 void yyerror(char const *);
 const char*format(const char *, ...);
 #define YYSTYPE char const *
 YYSTYPE mnpMerge(YYSTYPE x0, YYSTYPE x1);
%}

%define api.value.type {char const *}

%token ADJ NOUN GA WA WO NO VERB MARU DA KA

%left NO

%glr-parser

%%

session: %empty
| session noun-phrase MARU { printf("# 発話:\n\t%s\n", $2); }
| session sentence    MARU { printf("# 発話:\n\t%s\n", $2); }

sentence: clause { $$ = format("Sentence[%s]", $1); }
| nominative clause { $$ = format("WSubjSent[%s, %s]", $1, $2); }

clause: nominative predicate 	{ $$ = format("Clause[%s, %s]", $1, $2); }

predicate: VERB			{ $$ = format("Predicate[Verb['%s']]", $1); }
| adjective-phrase		{ $$ = format("Pred[%s]", $1); }
| noun-phrase copula	{ $$ = format("Pred[%s, %s]", $1, $2); }
| predicate KA predicate	{ $$ = format("Pred[Or[%s, %s]]", $1, $3); }

adjective-phrase: ADJ			{ $$ = format("Adj['%s']", $1); }

copula: DA		{ $$ = format("Copula['だ']"); }

/* subject: noun-phrase WA	{ $$ = format("Subject[%s, Particle['は']]", $1); } */

noun-phrase: NOUN			{ $$ = format("Noun['%s']", $1); } /* NP[Noun[]] ? */
| adjective noun-phrase	%merge <mnpMerge> { $$ = format("NP[%s, %s]", $2, $1); }
| genitive noun-phrase	%merge <mnpMerge> { $$ = format("NP[%s, %s]", $2, $1); }
| relative noun-phrase	%merge <mnpMerge> { $$ = format("NP[%s, %s]", $2, $1); }
| noun-phrase KA noun-phrase	{ $$ = format("NP[Or[%s, %s]]", $1, $3); }

relative: clause

genitive: noun-phrase NO 	{ $$ = format("Gen[%s]", $1); }
nominative: noun-phrase GA 	{ $$ = format("Nom[%s]", $1); }

adjective: ADJ			{ $$ = format("Adj['%s']", $1); }

%%

YYSTYPE
mnpMerge(YYSTYPE x0, YYSTYPE x1)
{
  return format("Alt[%s, %s]", x0, x1);
}

const char *format(const char * fmt, ...)
{
    va_list ap;
    static char buf[4096];

    va_start(ap,fmt);
    vsprintf(buf,fmt,ap);
    va_end(ap);

    char *ret = malloc(strlen(buf)+1);
    strcpy(ret,buf);

    return ret;
}

void yyerror(const char *msg) { printf("%s\n", msg); }

int main()
{
    yyparse();
}
