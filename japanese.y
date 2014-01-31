%{
 #include <stdio.h>
 #include <string.h>
 #include <stdarg.h>

 extern int yy_flex_debug;

 int yylex(void);
 void yyerror(char const *);
 const char *format(const char *, ...);
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

predicate: VERB			{ $$ = format("Pred[Verb['%s']]", $1); }
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
| noun-phrase KA noun-phrase %merge <mnpMerge>	{ $$ = format("NP[Or[%s, %s]]", $1, $3); }

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

void usage_exit()
{
    fprintf(stderr, "Usage: sa [ -l ]\n"
                    "\t-l   print each lexeme\n");
    exit(1);
}
#include <unistd.h>

int main(int argc, char *argv[])
{
    int opt;

    // グローバル変数の初期設定
    yy_flex_debug = 0;

    // スイッチの解析
    while ((opt = getopt(argc, argv, "l")) != -1) {
        switch (opt) {
        case 'l':
            yy_flex_debug = 1;
            break;
        default:
            fprintf(stderr, "Unknown option `%c'\n", opt);
            usage_exit();
            break;
        }
    }

    if (optind > argc) {
        usage_exit();
    }

    // 0 SUCCESS
    // 1 PARSE ERROR
    // 2 MEMORY EXHAUSTION ERROR
    return yyparse();
}
