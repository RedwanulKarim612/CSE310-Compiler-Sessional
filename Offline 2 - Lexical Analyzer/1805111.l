%option noyywrap


%x SINGLE_LINE_COMMENT_STATE
%x MULTILINE_COMMENT_STATE
%x STRING_SCANNING_STATE

%{
#include<bits/stdc++.h>
#include "SymbolTable.cpp"
using namespace std;

int line_count = 1;
int error_count = 0;
int comment_line_count = 0;
int string_line_count = 0;
SymbolTable symbolTable(11);
char * comment = "";
char * curStr = "";

FILE *logout;
FILE *tokenout;

void printToFileKeyWords(char * tokenName){
    fprintf(tokenout,"<%s> ", tokenName);
    fprintf(logout,"Line no %d: TOKEN <%s> Lexeme %s found\n\n",line_count,tokenName, yytext);
}

void printToFile(char *tokenName){
    fprintf(tokenout,"<%s, %s> ", tokenName, yytext);
    fprintf(logout,"Line no %d: TOKEN <%s> Lexeme %s found\n\n",line_count,tokenName, yytext);
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
CHARACTER_LITERAL ['](.|"\\t"|"\\n"|"\\"|"\\'"|"\\a"|"\\f"|"\\r"|"\\b"|"\\v|\\0")[']
INVALID_FLOAT {DIGIT}+"."({DIGIT}*".")+
INVALID_INDENTIFIER {DIGIT}+{LETTER}+
MULTI_CHARACTER ['](.)(.)+[']
EMPTY_CHARACTER [']("")['] 
UNFINISHED_CHARACTER ['](.|"\\t"|"\\n"|"\\"|"\\a"|"\\f"|"\\r"|"\\b"|"\\v|\\0")



%%
{WHITESPACE} {}

{NEWLINE}   {line_count++;}

"if"	    {
                printToFileKeyWords("IF");
		    }
		
"else"	    {
                printToFileKeyWords("ELSE");
            }

"for"       {
                printToFileKeyWords("FOR");
            }

"while"     {
                printToFileKeyWords("WHILE");
            }

"do"        {
                printToFileKeyWords("DO");
            }

"break"     {
                printToFileKeyWords("BREAK");
            }

"int"      {
                printToFileKeyWords("INT");
            }

"char"      {
                printToFileKeyWords("CHAR");
            }

"float"     {
                printToFileKeyWords("FLOAT");
            }

"double"    {
                printToFileKeyWords("DOUBLE");
            }

"void"      {
                printToFileKeyWords("VOID");
            }

"return"    {
                printToFileKeyWords("RETURN");
            }

"switch"    {
                printToFileKeyWords("SWITCH");
            }

"case"      {
                printToFileKeyWords("CASE");
            }
            
"default"   {
                printToFileKeyWords("DEFAULT");
            }
            

"continue"  {
                printToFileKeyWords("CONTINUE");
            }

["]         {
                BEGIN STRING_SCANNING_STATE;
                curStr = (char *)(malloc(3000));
                strcat(curStr, yytext);
                string_line_count = 0;
            } 


<STRING_SCANNING_STATE>(.*)["] {
                strcat(curStr, yytext);
                string ans = getTokenAttribute(curStr);
                fprintf(logout,"Line no %d: TOKEN <STRING> Lexeme %s found --> <STRING, %s>\n\n",line_count,curStr,ans.c_str());
                line_count+=string_line_count;
                BEGIN INITIAL;
            }     

<STRING_SCANNING_STATE><<EOF>> {
                line_count+=string_line_count;
                fprintf(logout,"Line no %d: Unfinished string found\n\n",line_count);
                error_count++;
                BEGIN INITIAL;
            }

<STRING_SCANNING_STATE>(.*)("\\"{NEWLINE})+ {
                strcat(curStr, yytext);
                string_line_count++;
            }

<STRING_SCANNING_STATE>{NEWLINE} {
                line_count+=string_line_count+1;
                fprintf(logout,"Line no %d: Unfinished string found\n\n",line_count);
                error_count++;
                BEGIN INITIAL;
            }


"//"        {
                BEGIN SINGLE_LINE_COMMENT_STATE;
                comment_line_count = 0;
                comment = (char *)malloc(3000);
                strcat(comment, yytext);
            }

<SINGLE_LINE_COMMENT_STATE>(.*)("\\"{NEWLINE})* {
                strcat(comment, yytext);
                comment_line_count++;
            }
<SINGLE_LINE_COMMENT_STATE>{NEWLINE} {
                fprintf(logout, "Line no %d: TOKEN <COMMENT> Lexeme %s found\n\n", line_count, comment);
                line_count+=comment_line_count;
                comment_line_count=0;
                BEGIN INITIAL;
            }
<SINGLE_LINE_COMMENT_STATE><<EOF>> {
                line_count+=comment_line_count;
                fprintf(logout, "Line no %d: TOKEN <COMMENT> Lexeme %s found\n\n", line_count, comment);
                BEGIN INITIAL;
            } 

"/*"       {    
                BEGIN MULTILINE_COMMENT_STATE;
                comment_line_count = 0;
                comment = (char *)malloc(3000);
                strcat(comment, yytext);
            }

<MULTILINE_COMMENT_STATE><<EOF>> {
                fprintf(logout, "Line no %d: Unfinished comment found\n\n", line_count);
                error_count++;
                line_count+=comment_line_count;
                BEGIN INITIAL;
            }

<MULTILINE_COMMENT_STATE>(.*)"*/" {
                strcat(comment, yytext);
                fprintf(logout, "Line no %d: TOKEN <COMMENT> Lexeme %s found\n\n", line_count, comment);
                line_count+=comment_line_count;
                comment_line_count=0;
                BEGIN INITIAL;
            }      

<MULTILINE_COMMENT_STATE>(.*) {
                strcat(comment, yytext);
            }

<MULTILINE_COMMENT_STATE>{NEWLINE} {
                strcat(comment, yytext);
                comment_line_count++;
            }



{COMMA}     {
                printToFile("COMMA");
            }

{SEMICOLON} {
                printToFile("SEMICOLON");
            }           

{ASSIGNOP}  {
                printToFile("ASSIGNOP");
            }          

{INCOP}     {
                printToFile("INCOP");
            }

{RELOP}     {
                printToFile("RELOP");
            }

{ADDOP}     {
                printToFile("ADDOP");
            }

{MULOP}     {
                printToFile("MULOP");
            }

{LPAREN}    {
                printToFile("LPAREN");
            }

{RPAREN}    {
                printToFile("RPAREN");
            }            

{LCURL}    {
                printToFile("LCURL");
            }            

{RCURL}    {
                printToFile("RCURL");
            }            

{LTHIRD}    {
                printToFile("LTHIRD");
            }            

{RTHIRD}    {
                printToFile("RTHIRD");
            }            

{FLOAT_LITERAL} {
                printToFile("CONST_FLOAT");
                symbolTable.insert("float", yytext);
            }   

{INTEGER_LITERAL} {
                printToFile("CONST_INT");
                symbolTable.insert("int", yytext);
            }   

{CHARACTER_LITERAL} {
                char *str = yytext;
                string ans = getTokenAttribute(str);
                fprintf(logout,"Line no %d: TOKEN <CONST_CHAR> Lexeme %s found --> <CONST_CHAR, %s>\n\n",line_count,str,ans.c_str());
                symbolTable.print();
            }

{INVALID_FLOAT} {
                fprintf(logout, "Line no %d: Invalid float litearal\n", line_count);
                error_count++;
            }   


{ID}        {
                printToFile("ID");
            }

{INVALID_INDENTIFIER} {
                fprintf(logout, "Line no %d: Invalid prefix on identifier\n", line_count);
                error_count++;
            }

{MULTI_CHARACTER}   {
                fprintf(logout, "Line no %d: Multi character constant error\n", line_count);
                error_count++;
            }

{EMPTY_CHARACTER}   {
                fprintf(logout, "Line no %d: Empty character constant error\n", line_count);
                error_count++;
            
            }

{UNFINISHED_CHARACTER} {
                fprintf(logout, "Line no %d: Unfinished character constant error\n", line_count);
                error_count++;
        
        }



    <<EOF>>     {
            
                fprintf(logout, "Total Lines : %d\n", line_count);
                fprintf(logout, "Total Errors : %d\n", error_count);
                yyterminate();
                return 0;
            }   
    [.]     {
                fprintf(logout, "Line no %d: Stray %s\n\n", line_count, yytext);
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
