%option noyywrap
%{
#include<iostream>
#include<bits/stdc++.h>
#include "1705028.cpp"
#include "y.tab.h"
using namespace std;
extern YYSTYPE yylval;
void yyerror(char *);

int line_count=1;

int error_count = 0;
int multiline_start =0;
std::string s="";
std::string s1="";
vector <SymbolInfo*> vec;
extern string datatype;
extern int syntax_errors;
extern std::ofstream error;
extern std::ofstream logout;
extern int line_count;
string id="";
void IncLc(){
	line_count++;
}
int Get_LineC(){
	return line_count;
}




char buffer[500];
int str_cmt_start=0;


%}
WS [ \t\f\v]
LETTER [a-zA-Z]
DIGIT [0-9]


%%
[\n]|(\r\n) {IncLc();}
{WS}+	{}

"if"	{return IF;}
"else"	{return ELSE;}
"for"   {return FOR;}
"while"   {return WHILE;}
"do"   {return DO;}
"break"   {return BREAK;}
"int" { return INT;}
"char"   { return CHAR;}
"float"   {return FLOAT;}
"double"   {return DOUBLE;}
"void"   {return VOID;}
"return"   {return RETURN;}
"switch"	{return SWITCH;}
"case"   {return CASE;}
"println" {return PRINTLN;}		
"default"	{return DEFAULT;}
"continue"   {return CONTINUE;}


{DIGIT}+	{SymbolInfo* newid = new SymbolInfo(yytext, "integer");
	yylval.si =newid;
	return CONST_INT;	}
{DIGIT}*(\.{DIGIT}*)?(E[+|-]?{DIGIT}+)?	{	SymbolInfo* newid = new SymbolInfo(yytext, "float");
	yylval.si =newid;
	return CONST_FLOAT;	  }


";" 	{return SEMICOLON;}
"," 	{return COMMA;}
"+"	|
"-"	{SymbolInfo* newid = new SymbolInfo(yytext, "ADDOP");
	yylval.si =newid;
	return ADDOP;}
"*"	|
"/"	|
"%"	{SymbolInfo* newid = new SymbolInfo(yytext, "MULOP");
	yylval.si =newid;
	return MULOP;}
"++" 	{return INCOP;}
"--" 	{return DECOP;}

"!"		{	return NOT; }

"<"	|
"<="	|
">"	|
">="	|
"=="	|
"!="	{SymbolInfo* newid = new SymbolInfo(yytext, "RELOP");
	yylval.si =newid;
	return RELOP;}
"="	{return ASSIGNOP;}
"&&"	|
"||"	{SymbolInfo* newid = new SymbolInfo(yytext, "LOGICLOP");
	yylval.si =newid;
	return LOGICOP;}
"("	{return LPAREN;}
")"	{return RPAREN;}
"{"	{return  LCURL;}
"}"	{return  RCURL;}
"[" 	{return LTHIRD ;}
"]"	{return RTHIRD ;}
[a-zA-Z_]+[a-zA-Z0-9_]*	{	SymbolInfo* newid = new SymbolInfo(yytext, "ID");
					newid->set_dataType(datatype);
					yylval.si =newid;
					vec.push_back(newid);
					id=yytext;
					return ID;
				}
. { 	
	
  }


%%
