%option noyywrap
%{
#include <string.h>
#include "japanese.tab.h"
%}

%%

[ \t]
"美しい"	{ yylval = strdup(yytext); return ADJ; }
[^ ]+"い"	{ yylval = strdup(yytext); return ADJ; }
"日本"|"私"	{ yylval = strdup(yytext); return NOUN; }
"の"		{ yylval = strdup(yytext); return NO; }
"\n"		{ yylval = "\n"; return MARU; }
[^ \n]+		{ yylval = strdup(yytext); return NOUN; }
