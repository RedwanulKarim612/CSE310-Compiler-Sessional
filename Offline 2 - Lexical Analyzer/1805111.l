%option noyywrap

%{
#include<bits/stdc++.h>
#include "SymbolTable.cpp"
using namespace std;

int line_count = 1;
int error_count = 0;
SymbolTable symbolTable(11);

FILE *logout;
FILE *tokenout;

%}

WHITESPACE [ \t\f\r\v]+ 
LETTER [a-zA-Z]
DIGIT [0-9]
NEWLINE [\n]
INCOP ("++"|"--")
RELOP (">"|"<="|">"|">="|"=="|"!=")
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
FLOAT_LITERAL {DIGIT}*"."{DIGIT}+([E]{DIGIT}+)?
CHARACTER_LITERAL [']({DIGIT}|{LETTER}|"\t"|"\n"|"\\"|"\'"|"\a"|"\f"|"\r"|"\b"|"\v"|"\0")[']
INVALID_FLOAT {FLOAT_LITERAL}{FLOAT_LITERAL}+
INVALID_INDENTIFIER {DIGIT}+{LETTER}+


%%

{NEWLINE}   {line_count++;}

"if"	    {
                fprintf(tokenout,"<IF> ");
                fprintf(logout,"Line no %d: TOKEN <IF> Lexeme %s found\n",line_count,yytext);
		    }
		
"else"	    {
                fprintf(tokenout,"<ELSE> ");
                fprintf(logout,"Line no %d: TOKEN <ELSE> Lexeme %s found\n",line_count,yytext);
            }

"for"       {
                fprintf(tokenout,"<FOR> ");
                fprintf(logout,"Line no %d: TOKEN <FOR> Lexeme %s found\n",line_count,yytext);
            }

"while"     {
                fprintf(tokenout,"<WHILE> ");
                fprintf(logout,"Line no %d: TOKEN <WHILE> Lexeme %s found\n",line_count,yytext);
            }

"do"        {
		    	fprintf(tokenout,"<DO> ");
			    fprintf(logout,"Line no %d: TOKEN <DO> Lexeme %s found\n",line_count,yytext);
		    }

"break"     {
                fprintf(tokenout,"<BREAK> ");
                fprintf(logout,"Line no %d: TOKEN <BREAK> Lexeme %s found\n",line_count,yytext);
            }

"int"      {
                fprintf(tokenout,"<INT> ");
                fprintf(logout,"Line no %d: TOKEN <INT> Lexeme %s found\n",line_count,yytext);
            }

"char"      {
                fprintf(tokenout,"<CHAR> ");
                fprintf(logout,"Line no %d: TOKEN <CHAR> Lexeme %s found\n",line_count,yytext);
            }

"float"     {
                fprintf(tokenout,"<FLOAT> ");
                fprintf(logout,"Line no %d: TOKEN <FLOAT> Lexeme %s found\n",line_count,yytext);
            }

"double"    {
                fprintf(tokenout,"<DOUBLE> ");
                fprintf(logout,"Line no %d: TOKEN <DOUBLE> Lexeme %s found\n",line_count,yytext);
            }

"void"      {
                fprintf(tokenout,"<VOID> ");
                fprintf(logout,"Line no %d: TOKEN <VOID> Lexeme %s found\n",line_count,yytext);
            }

"return"    {
                fprintf(tokenout,"<RETURN> ");
                fprintf(logout,"Line no %d: TOKEN <RETURN> Lexeme %s found\n",line_count,yytext);
            }

"switch"    {
                fprintf(tokenout,"<SWITCH> ");
                fprintf(logout,"Line no %d: TOKEN <SWITCH> Lexeme %s found\n",line_count,yytext);
            }

"case"      {
                fprintf(tokenout,"<CASE> ");
                fprintf(logout,"Line no %d: TOKEN <CASE> Lexeme %s found\n",line_count,yytext);
            }

"default"   {
                fprintf(tokenout,"<DEFAULT> ");
                fprintf(logout,"Line no %d: TOKEN <DEFAULT> Lexeme %s found\n",line_count,yytext);
            }

"continue"  {
                fprintf(tokenout,"<CONTINUE> ");
                fprintf(logout,"Line no %d: TOKEN <CONTINUE> Lexeme %s found\n",line_count,yytext);
            }

{COMMA}     {
            	fprintf(tokenout,"<COMMA,%s> ",yytext);
				fprintf(logout,"Line no %d: TOKEN <COMMA> Lexeme %s found\n",line_count,yytext);
            }

{SEMICOLON} {
            	fprintf(tokenout,"<SEMICOLON,%s> ",yytext);
				fprintf(logout,"Line no %d: TOKEN <SEMICOLON> Lexeme %s found\n",line_count,yytext);
            }           

{ASSIGNOP}  {
        	    fprintf(tokenout,"<ASSIGNOP,%s> ",yytext);
				fprintf(logout,"Line no %d: TOKEN <ASSIGNOP> Lexeme %s found\n",line_count,yytext);
			
            }          

{INCOP}     {
                fprintf(tokenout,"<INCOP,%s> ",yytext);
                fprintf(logout,"Line no %d: TOKEN <INCOP> Lexeme %s found\n",line_count,yytext);
            }

{RELOP}     {
                fprintf(tokenout,"<RELOP,%s> ",yytext);
				fprintf(logout,"Line no %d: TOKEN <RELOP> Lexeme %s found\n",line_count,yytext);
            }

{ADDOP}     {
                fprintf(tokenout,"<ADDOP,%s> ",yytext);
                fprintf(logout,"Line no %d: TOKEN <ADDOP> Lexeme %s found\n",line_count,yytext);
            }

{LPAREN}    {
                fprintf(tokenout,"<LPAREN,%s> ",yytext);
                fprintf(logout,"Line no %d: TOKEN <LPAREN> Lexeme %s found\n",line_count,yytext);
            }            


{RPAREN}    {
                fprintf(tokenout,"<RPAREN,%s> ",yytext);
                fprintf(logout,"Line no %d: TOKEN <RPAREN> Lexeme %s found\n",line_count,yytext);
            }            

{LCURL}    {
                fprintf(tokenout,"<LCURL,%s> ",yytext);
                fprintf(logout,"Line no %d: TOKEN <LCURL> Lexeme %s found\n",line_count,yytext);
                symbolTable.enterScope();
            }            

{RCURL}    {
                fprintf(tokenout,"<RCURL,%s> ",yytext);
                fprintf(logout,"Line no %d: TOKEN <RCURL> Lexeme %s found\n",line_count,yytext);
                symbolTable.exitScope();
            }            

{LTHIRD}    {
                fprintf(tokenout,"<LTHIRD,%s> ",yytext);
                fprintf(logout,"Line no %d: TOKEN <LTHIRD> Lexeme %s found\n",line_count,yytext);
            }            

{RTHIRD}    {
                fprintf(tokenout,"<RTHIRD,%s> ",yytext);
                fprintf(logout,"Line no %d: TOKEN <RTHIRD> Lexeme %s found\n",line_count,yytext);
            }            

{FLOAT_LITERAL} {

				fprintf(tokenout,"<CONST_FLOAT,%s> ",yytext);
				fprintf(logout,"Line no %d: TOKEN <CONST_FLOAT> Lexeme %s found\n",line_count,yytext);
            }   

{INTEGER_LITERAL} {

				fprintf(tokenout,"<CONST_INT,%s> ",yytext);
				fprintf(logout,"Line no %d: TOKEN <CONST_INT> Lexeme %s found\n",line_count,yytext);
            }   

{CHARACTER_LITERAL} {
            	fprintf(tokenout,"<CONST_CHAR,%s> ",yytext);
				fprintf(logout,"Line no %d: TOKEN <CONST_CHAR> Lexeme %s found\n",line_count,yytext);
                
            }

{INVALID_FLOAT} {
                fprintf(logout, "Line no %d: Invalid float litearal\n", line_count);
                error_count++;
            }   


{ID}        {
                fprintf(tokenout,"<ID,%s> ",yytext);
				fprintf(logout,"Line no %d: TOKEN <ID> Lexeme %s found\n",line_count,yytext);
            }

{INVALID_INDENTIFIER} {
                fprintf(logout, "Line no %d: Invalid prefix on identifier\n", line_count);
                error_count++;
            }

    <<EOF>>     {
        fprintf(logout, "Total Lines : %d\n", line_count);
        fprintf(logout, "Total Errors : %d\n", error_count);
        return 0;
    }

%%

int main(int argc,char *argv[]){
	
	if(argc!=2){
		printf("Please provide input file name and try again\n");
		return 0;
	}
	
	FILE *fin=fopen(argv[1],"r");
	if(fin==NULL){
		printf("Cannot open specified file\n");
		return 0;
	}
	
	logout= fopen("log.txt","w");
	tokenout= fopen("token.txt","w");

	yyin= fin;
	yylex();
	fclose(yyin);
	fclose(tokenout);
	fclose(logout);
	return 0;
}