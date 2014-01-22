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

%token ADJ NOUN GA WA WO NO VERB MARU DA

%left NO

%glr-parser

%%

session: %empty
| session noun-phrase MARU { printf("# 発話:\n\t%s\n", $2); }
| session sentence    MARU { printf("# 発話:\n\t%s\n", $2); }

sentence: subject predicate 	{ $$ = format("Sentence[%s, %s]", $1, $2); }

predicate: VERB			{ $$ = format("Predicate[Verb['%s']]", $1); }
| ADJ			{ $$ = format("Predicate[Adj['%s']]", $1); }
| noun-phrase copula	{ $$ = format("Predicate[%s, %s]", $1, $2); }

copula: DA		{ $$ = format("Copula['だ']"); }

subject: noun-phrase WA	{ $$ = format("Subject[%s, Particle['は']]", $1); }
| noun-phrase GA	{ $$ = format("Subject[%s, Particle['が']]", $1); }

noun-phrase: NOUN			{ $$ = format("Noun['%s']", $1); } /* NP[Noun[]] ? */
| modifier noun-phrase	%merge <mnpMerge> { $$ = format("NP[%s, %s]", $1, $2); }

modifier: noun-phrase NO 	{ $$ = format("Mod[%s, Particle['の']]", $1); }
| ADJ			{ $$ = format("Mod[Adj['%s']]", $1); }

%%

YYSTYPE
mnpMerge(YYSTYPE x0, YYSTYPE x1)
{
  return format("Alt[%s, %s]", x0, x1);
}

const char *format(const char * fmt, ...)
{
    va_list ap;
    char *ret = malloc(1000);

    va_start(ap, fmt);
    vsprintf(ret, fmt, ap);
    va_end(ap);
    return ret;
}

void yyerror(const char *msg) { printf("%s\n", msg); }

int main()
{
    yyparse();
}
