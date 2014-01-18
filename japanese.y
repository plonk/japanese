%{
 #include <stdio.h>
 #include <string.h>
 #include <stdarg.h>
 int yylex(void);
 void yyerror(char const *);
 const char *format(const char *, ...);
 #define YYSTYPE char const *
 YYSTYPE mnpMerge(YYSTYPE x0, YYSTYPE x1);
%}

%define api.value.type {char const *}

%token ADJ NOUN NO MARU

%left NO

%glr-parser

%%

/*
美しい[日本の私]。
[美しい日本]の私。

  ADJ        NOUN    NO     NOUN
modifier noun-phrase NO noun-phrase
modifier     modifier   noun-phrase  ... (a)
   m o d i f i e r      noun-phrase  ... (a')
modifier  n  o  u  n - p h r a s e   ... (b)
  n  o  u  n  -  p  h  r  a  s  e    ... (c)
*/
 

session:
/* empty */
	| session noun-phrase MARU { printf("発話:\n\t%s。\n", $2); }

noun-phrase:
        | NOUN			{ $$ = format("[NP:%s_noun]", $1); }
        | modifier noun-phrase		%merge <mnpMerge> {
                   $$ = format("[NP:%s%s]", $1, $2);
        }

modifier:
        noun-phrase NO 	{ $$ = format("(MOD:%sの)", $1); }
	| ADJ		{ $$ = format("(MOD:%s_adj)", $1); }

%%

YYSTYPE
mnpMerge(YYSTYPE x0, YYSTYPE x1)
{
  return format("{%s\n\tあるいは\n\t%s}", x0, x1);
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

/*
int yylex(void)
{
    static int pos = 0;
    char *words[] = { "美しい", "日本", "の", "私", "。", NULL };
    int token_type[] = { ADJ, NOUN, NO, NOUN, MARU,  0 };
//    char *words[] = { "美しい", "私", NULL };
//    int token_type[] = { ADJ, NOUN, 0 };

    yylval = words[pos];
    return token_type[pos++];
}
*/

void yyerror(const char *msg) { printf("%s\n", msg); }

int main()
{
    yyparse();
}
