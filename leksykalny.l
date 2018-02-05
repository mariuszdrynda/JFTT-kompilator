%option yylineno
%option noyywrap
%{
#define YYSTYPE std::string
#include <stdlib.h>
#include <iostream>
#include <string>
#include "y.tab.h"

int yylex();
extern void yyerror (char const *);
//extern int yylineno;
%}
%%
"("[^()]*")"	{}
[ \t]+		{}
[ \n]*		{}
"+"		{return DODAWANIE;}
"-"		{return ODEJMOWANIE;}
"*"		{return MNOZENIE;}
"/"		{return DZIELENIE;}
"%"		{return MODULO;}
"="		{return ROWNY;}
"<>"		{return ROZNY;}
"<="		{return MNIEJSZYROWNY;}
">="		{return WIEKSZYROWNY;}
"<"		{return MNIEJSZY;}
">"		{return WIEKSZY;}
":="		{return PRZYPISANIE;}
"["		{return LEWYNAWIAS;}
"]"		{return PRAWYNAWIAS;}
"VAR"		{return VAR;}
"BEGIN"		{return BEG;}
"END"		{return END;}
"FROM" 		{return FROM;}
"TO"		{return TO;}
"DOWNTO"	{return DOWNTO;}
"FOR"		{return FOR;}
"ENDFOR"	{return ENDFOR;}
"IF"		{return IF;}
"THEN"		{return THEN;}
"ELSE"		{return ELSE;}
"ENDIF"		{return ENDIF;}
"WHILE"		{return WHILE;}
"ENDWHILE"	{return ENDWHILE;}
"DO"		{return DO;}
"READ"		{return READ;}
"WRITE"		{return WRITE;}
[0-9]+ 		{yylval = (yytext); return NUM;}
[_a-z]+		{yylval = (yytext); return PIDENTIFIER;}
";"		{return SREDNIK;}
