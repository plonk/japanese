%option noyywrap
%{
#include <string.h>
#include "japanese.tab.h"
%}

%%

[ \t]
"美しい"	{ yylval = strdup(yytext); return ADJ; }
[^ \n]+"い"	{ yylval = strdup(yytext); return ADJ; }
"日本"|"私"	{ yylval = strdup(yytext); return NOUN; }
"の"		{ yylval = strdup(yytext); return NO; }
"\n"		{ yylval = "\n"; return MARU; }
"は"		{ yylval = strdup(yytext); return WA; }
"が"		{ yylval = strdup(yytext); return GA; }
"だ"		{ yylval = strdup(yytext); return DA; }
"か"		{ yylval = strdup(yytext); return KA; }
[^ \n]+("る"|"た")	{ yylval = strdup(yytext); return VERB; }
[^ \n]+		{ yylval = strdup(yytext); return NOUN; }
