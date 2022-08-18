%option noyywrap

%x SINGLE_LINE_COMMENT_STATE
%x MULTILINE_COMMENT_STATE
%x STRING_SCANNING_STATE

%{
#include<bits/stdc++.h>
#include "1805111_SymbolTable.cpp"
#include "SimpleText.cpp"
#include "y.tab.h"
#define YYSTYPE SymbolInfo*
using namespace std;

int line_count = 1;
int error_count = 0;
int comment_line_count = 0;
int string_line_count = 0;
// extern SymbolTable symbolTable;
char * comment = "";
char * curStr = "";

FILE *logout;
FILE *tokenout;

void printToFileKeyWords(char * tokenName){
    fprintf(tokenout,"<%s> ", tokenName);
    fprintf(logout,"Line no %d: Token <%s> Lexeme %s found\n\n",line_count,tokenName, yytext);
}

void printToFile(char *tokenName){
    fprintf(tokenout,"<%s, %s> ", tokenName, yytext);
    fprintf(logout,"Line no %d: Token <%s> Lexeme %s found\n\n",line_count,tokenName, yytext);
}

char getASCII(char ch){
    if(ch=='n') return '\n';
    else if(ch=='t') return '\t';
    else if(ch=='\\') return '\\';
    else if(ch=='\'') return '\'';
    else if(ch=='a') return '\a';
    else if(ch=='f') return '\f';
    else if(ch=='r') return '\r';
    else if(ch=='b') return '\b';
    else if(ch=='v') return '\v';
    else if(ch=='\0') return '\0';
    else if(ch=='\"') return '\"';
    return '\\';
}

string getTokenAttribute(char * curStr){
    string str(curStr);
    str = str.substr(0, str.length()-1);
    str = str.substr(1);
    string ans = "";
    for(int i=0;i<strlen(curStr)-1;i++){
        if(str[i]!='\\'){ans+=str[i];}
        else{
            i++;
            if(str[i]=='\n') continue;
            ans+=getASCII(str[i]);
        }
    }
    return ans;   
}

%}


WHITESPACE [ \t\f\r\v]+ 
NEWLINE [\n]
LETTER [a-zA-Z]
DIGIT [0-9]
INCOP ("++")
DECOP ("--")
RELOP ("\>"|"<="|"\<"|">="|"=="|"!=")
ASSIGNOP [=]
LOGICOP ("&&"|"||")
NOT [!]
LPAREN [(]
RPAREN [)]
LCURL [{]
RCURL [}]
LTHIRD [[]
RTHIRD []]
COMMA [,]
SEMICOLON [;]
ADDOP [+-]
MULOP [*/%]
ID ({LETTER}|"_")({LETTER}|{DIGIT}|"_")*
INTEGER_LITERAL {DIGIT}+
FLOAT_LITERAL {DIGIT}*([.]{DIGIT}+)([E]{DIGIT}+)?
CHARACTER_LITERAL ['](.|"\\t"|"\\n"|"\\'"|"\\a"|"\\f"|"\\r"|"\\b"|"\\v|\\0")[']
INVALID_FLOAT {DIGIT}+"."({DIGIT}*(".")*)+
ILL_FORMED_FLOAT {DIGIT}*("."{DIGIT}+)?"E"{DIGIT}*("."){DIGIT}*
INVALID_INDENTIFIER {DIGIT}+({LETTER}|{DIGIT}|"_")+
MULTI_CHARACTER ['](.)(.)+[']
EMPTY_CHARACTER [']("")['] 
Unterminated_CHARACTER ['](.|"\\t"|"\\n"|"\\"|"\\a"|"\\f"|"\\r"|"\\b"|"\\v"|"\\0")?



%%
{WHITESPACE} {}

{NEWLINE}   {
                line_count++;
            }

"if"	    {
                return IF;
		    }
		
"else"	    {
                return ELSE;
		    }

"for"       {
                return FOR;
		    }

"while"     {
                return WHILE;
		    }

"do"        {
                return DO;
		    }

"break"     {
                return BREAK;
		    }

"int"       {
                return INT;
		    }

"char"      {
                return CHAR;
		    }

"float"     {
                return FLOAT;
		    }

"double"    {
                return DOUBLE;
		    }

"void"      {
                return VOID;
		    }

"return"    {
                return RETURN;
		    }

"switch"    {
                return SWITCH;
		    }

"case"      {
                return CASE;
		    }
            
"default"   {
                return DEFAULT;
		    }
            

"continue"  {
                return CONTINUE;
		    }

"println"    {
                 return PRINTLN;
            }

["] {
                // BEGIN STRING_SCANNING_STATE;
                // curStr = (char *)(malloc(3000));
                // strcat(curStr, yytext);
                // string_line_count = 0;
            } 

<STRING_SCANNING_STATE>(.*)["] {
                // strcat(curStr, yytext);
                // string ans = getTokenAttribute(curStr);
                // fprintf(logout,"Line no %d: Token <STRING> Lexeme %s found --> <STRING, \"%s\">\n\n",line_count,curStr,ans.c_str());
                // line_count+=string_line_count;
                // BEGIN INITIAL;
            }     

<STRING_SCANNING_STATE><<EOF>> {
                // fprintf(logout,"Line no %d: Unterminated string %s\n\n",line_count, curStr);
                // line_count+=string_line_count;
                // error_count++;
                // BEGIN INITIAL;
            }


<STRING_SCANNING_STATE>(.*)("\\"{NEWLINE}) {
                // strcat(curStr, yytext);
                // string_line_count++;
            }

<STRING_SCANNING_STATE>[^\\\"\n]*{NEWLINE} {
                // strcat(curStr, yytext);
                // fprintf(logout,"Line no %d: Unterminated string %s\n\n",line_count, curStr);
                // line_count+=string_line_count+1;
                // error_count++;
                // BEGIN INITIAL;
            }




"//"        {
                BEGIN SINGLE_LINE_COMMENT_STATE;
                comment_line_count = 0;
                comment = (char *)malloc(3000);
                strcat(comment, yytext);
            }

<SINGLE_LINE_COMMENT_STATE>(.*)("\\"{NEWLINE})* {
                // strcat(comment, yytext);
                // comment_line_count++;
            }
<SINGLE_LINE_COMMENT_STATE>{NEWLINE} {
                // fprintf(logout, "Line no %d: TOKEN <COMMENT> Lexeme %s found\n\n", line_count, comment);
                // line_count+=comment_line_count;
                // comment_line_count=0;
                // BEGIN INITIAL;
            }
<SINGLE_LINE_COMMENT_STATE><<EOF>> {
                // line_count+=comment_line_count;
                // fprintf(logout, "Line no %d: TOKEN <COMMENT> Lexeme %s found\n\n", line_count, comment);
                // BEGIN INITIAL;
            } 

"/*"       {    
                // BEGIN MULTILINE_COMMENT_STATE;
                // comment_line_count = 0;
                // comment = (char *)malloc(3000);
                // strcat(comment, yytext);
            }

<MULTILINE_COMMENT_STATE><<EOF>> {
                // fprintf(logout, "Error at line no %d: Unterminated comment %s\n\n", line_count, comment);
                // error_count++;
                // line_count+=comment_line_count;
                // BEGIN INITIAL;
            }

<MULTILINE_COMMENT_STATE>(.*)"*/" {
                // strcat(comment, yytext);
                // fprintf(logout, "Line no %d: TOKEN <COMMENT> Lexeme %s found\n\n", line_count, comment);
                // line_count+=comment_line_count;
                // comment_line_count=0;
                // BEGIN INITIAL;
            }      

<MULTILINE_COMMENT_STATE>(.*) {
                // strcat(comment, yytext);
            }

<MULTILINE_COMMENT_STATE>{NEWLINE} {
                // strcat(comment, yytext);
                // comment_line_count++;
            }



{COMMA}     {
                return COMMA;
		    }

{SEMICOLON} {
                return SEMICOLON;
		    }           

{ASSIGNOP}  {
                return ASSIGNOP;
		    }          

{INCOP}     {
                return INCOP;
		    }

{DECOP}     {
                return DECOP;
            }

{RELOP}     {
                SymbolInfo * info = new SymbolInfo(yytext, "RELOP");
                yylval.symbolInfo = (YYSTYPE)info;
                return RELOP;
		    }

{ADDOP}     {
                SymbolInfo * info = new SymbolInfo(yytext, "ADDOP");
                yylval.symbolInfo = (YYSTYPE)info;
                return ADDOP;
            }

{MULOP}     {
                SymbolInfo * info = new SymbolInfo(yytext, "MULOP");
                yylval.symbolInfo = (YYSTYPE)info;
                return MULOP;
            }

{LOGICOP}   {
                SymbolInfo * info = new SymbolInfo(yytext, "LOGICOP");
                yylval.symbolInfo = (YYSTYPE)info;
                return LOGICOP;
            }

{NOT}       {
                return NOT;
		    }

{LPAREN}    {
                return LPAREN;
		    }

{RPAREN}    {
                return RPAREN;
		    }            

{LCURL}    {
                return LCURL;
		    }            

{RCURL}    {
                return RCURL;
		    }            

{LTHIRD}    {
                return LTHIRD;
		    }            

{RTHIRD}    {
                return RTHIRD;
		    }            

{FLOAT_LITERAL} {
                SymbolInfo * info = new SymbolInfo(yytext, "CONST_FLOAT");
                yylval.symbolInfo = (YYSTYPE)info;
                return CONST_FLOAT;
            }   

{INTEGER_LITERAL} {
                SymbolInfo* info = new SymbolInfo(yytext, "CONST_INT");
                yylval.symbolInfo = (YYSTYPE)info;
                return CONST_INT;
            }   

{CHARACTER_LITERAL} {
                // SymbolInfo * info = new SymbolInfo(yytext, "CONST_CHAR");
                // yylval.symbolInfo = (YYSTYPE)info;
                return CONST_CHAR;

            }

{INVALID_FLOAT} {
                // fprintf(logout, "Error at line no %d: Too many decimal points %s\n\n", line_count, yytext);
                // error_count++;
            }   
{ILL_FORMED_FLOAT} {
                // fprintf(logout, "Error at line no %d: Ill formed number %s\n\n", line_count, yytext);
                // error_count++;
            }

{ID}        {
                SymbolInfo * info = new SymbolInfo(yytext, "ID");
                yylval.symbolInfo = (YYSTYPE)info;
                return ID;
            }

{INVALID_INDENTIFIER} {
                // fprintf(logout, "Error at line no %d: Invalid prefix on ID or invalid suffix on number %s\n\n", line_count, yytext);
                // error_count++;
            }

{MULTI_CHARACTER}   {
                // fprintf(logout, "Error at line no %d: Multi character constant error %s\n\n", line_count, yytext);
                // error_count++;
            }

{EMPTY_CHARACTER}   {
                // fprintf(logout, "Error at line no %d: Empty character constant error %s\n\n", line_count, yytext);
                // error_count++;
            
            }

{Unterminated_CHARACTER} {
                // fprintf(logout, "Error at line no %d: Unterminated character constant error %s\n\n", line_count, yytext);
                // error_count++;
        
        }


    .     {
            //     fprintf(logout, "Error at line no %d: Unrecognized character %s\n\n", line_count, yytext);
            // error_count++;
            //
            SymbolInfo * info = new SymbolInfo(yytext, "unrecognized");
            yylval.symbolInfo = (YYSTYPE)info;
            return UNREC_CHAR;
        }

    <<EOF>>     {
                // fprintf(logout, "Total Lines : %d\n", line_count);
                // fprintf(logout, "Total Errors : %d\n", error_count);
                yyterminate();
                return 0;
            }

%%

