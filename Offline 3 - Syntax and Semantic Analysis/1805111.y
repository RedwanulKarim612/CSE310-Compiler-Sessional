%{
#include <bits/stdc++.h>
#include <stdio.h>
#include <cstring>
#include <stdlib.h>
#include "1805111_SymbolTable.cpp"

#define YYDEBUG 1

void yyerror(const char *s){
	printf("%s\n",s);
}

SymbolTable table(31);
FILE* inputFile;
FILE* logOut;
FILE* errorOut;
extern FILE* yyin;
extern int line_count;

int yylex(void);
int yyparse(void);

%}

%define parse.error verbose

%union{ 
 SymbolInfo* symbolInfo;
}


%token BREAK CASE CONTINUE DEFAULT RETURN SWITCH VOID CHAR DOUBLE FLOAT INT DO WHILE FOR IF ELSE
%token INCOP DECOP ASSIGNOP NOT LPAREN RPAREN LCURL RCURL LTHIRD RTHIRD NEWLINE
%token COMMA SEMICOLON PRINTLN
%token <symbolInfo> ID CONST_INT CONST_FLOAT CONST_CHAR ADDOP MULOP RELOP LOGICOP

%type <symbolInfo> start program unit var_declaration variable type_specifier declaration_list
%type <symbolInfo> expression_statement func_declaration parameter_list func_definition
%type <symbolInfo> compound_statement statements unary_expression factor statement arguments
%type <symbolInfo> expression logic_expression simple_expression rel_expression term argument_list

%start program

%%
start   :   program     {
                        fprintf(logOut,"Line %d: start  :  program\n\n%s\n\n", line_count, $$->getName().c_str());
                }

program :   program unit{
                        $$ = new SymbolInfo($1->getName() + $2->getName(), "PROGRAM");
                        fprintf(logOut,"Line %d: program  :  program unit\n\n%s\n\n", line_count, $$->getName().c_str());
                }
        |   unit{
                        $$ = new SymbolInfo($1->getName(), "PROGRAM");
                        fprintf(logOut,"Line %d: program  :  unit\n\n%s\n\n", line_count, $$->getName().c_str());
                }
        ;

unit    :   var_declaration{
                        $$ = new SymbolInfo($1->getName(), "UNIT");
                        fprintf(logOut,"Line %d: unit  :  var_declaration\n\n%s\n\n", line_count, $$->getName().c_str());
                }
        |   func_declaration{
                        $$ = new SymbolInfo($1->getName(), "UNIT");
                        fprintf(logOut,"Line %d: unit  :  func_declaration\n\n%s\n\n", line_count, $$->getName());
                }
        |   func_definition{
                        $$ = new SymbolInfo($1->getName(), "UNIT");
                        fprintf(logOut,"Line %d: unit  :  func_definition\n\n%s\n\n", line_count, $$->getName());
                }
        |   unit NEWLINE{
                        $$ = new SymbolInfo($1->getName()+"\n\r", "UNIT");
                        fprintf(logOut,"Line %d: unit  :  var_declaration\n\n%s\n\n", line_count, $$->getName().c_str());
                        
                }
        ;

func_declaration    :   type_specifier ID LPAREN parameter_list RPAREN SEMICOLON
                    |   type_specifier ID LPAREN RPAREN SEMICOLON
                    ;


func_definition     :   type_specifier ID LPAREN parameter_list RPAREN compound_statement
                    |   type_specifier ID LPAREN RPAREN compound_statement
                    ;

parameter_list      :   parameter_list COMMA type_specifier ID
                    |   parameter_list COMMA type_specifier
                    |   type_specifier ID
                    |   type_specifier
                    ;

compound_statement   :   LCURL statements RCURL
                    |   LCURL RCURL 
                    ;

var_declaration     : type_specifier declaration_list SEMICOLON {
                                string variables = $2->getName();
                                // variable type cannot be void
                                if($1->getType()=="VOID") {
                                        fprintf(errorOut, "Void variables\n");
                                        
                                }
                                else{
                                        string temp = "";
                                        bool lthird = false;
                                        for(int i=0;i<variables.size();i++){
                
                                                if(variables[i]==',' || variables[i]=='['){
                                                        if(temp=="") continue;
                                                        SymbolInfo * newSymbol = new SymbolInfo(temp, $1->getName());
                                                     
                                                        if(variables[i]=='[') {
                                                                string arrSize = "";
                                                                for(int j=i+1;j<variables.size();j++){
                                                                        if(variables[j]==']') {
                                                                                i = j+1;
                                                                                break;
                                                                        }
                                                                        arrSize+=variables[j];
                                                                }

                                                                newSymbol->setArraySize(stoi(arrSize));
                                                                
                                                        }
                                                        // variables cannot be declared multiple times

                                                        if(!table.insert(newSymbol)) 
                                                                fprintf(errorOut, "duplicate variables\n");
                                                        temp = "";
                                                }
                                                else temp+=variables[i];
                                        }
                                        if(temp!="")table.insert(temp, $1->getName());
                                        string name = $1->getName() + " " + $2->getName() + ";";
                                        $$ = new SymbolInfo(name, "VAR_DECLARATION");
                                        fprintf(logOut, "var_declaration : type_specifier declaration_list SEMICOLON\n\n%s\n\n",$$->getName().c_str());
                                }
                        }
                    ;

type_specifier      : INT {
                                $$ = new SymbolInfo("int","INT");
                                fprintf(logOut,"Line %d: type_specifier  :  INT\n\n%s\n\n", line_count, $$->getName().c_str());
                        }
                    | FLOAT{
                                $$ = new SymbolInfo("float","FLOAT");
                                fprintf(logOut,"Line %d: type_specifier  :  FLOAT\n\n%s\n\n", line_count, $$->getName().c_str());
                        }
                    | VOID  {
                                $$ = new SymbolInfo("void","VOID");
                                fprintf(logOut,"Line %d: type_specifier  :  VOID\n\n%s\n\n", line_count, $$->getName().c_str());
                        }
                    ;

declaration_list    :   declaration_list COMMA ID{
                                string temp = $1->getName() + "," + $3->getName();
                                $$ = new SymbolInfo(temp, $1->getType());
                                fprintf(logOut, "Line %d: declaration_list : declaration_list COMMA ID\n\n%s\n\n",line_count, $$->getName().c_str());

                        }
                    |   declaration_list COMMA ID LTHIRD CONST_INT RTHIRD{
                                string temp = $1->getName() + "," + $3->getName() + "[" + $5->getName() + "]";
                                $$ = new SymbolInfo(temp, $1->getType());
                                fprintf(logOut, "Line %d: declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD\n\n%s\n\n",line_count, $$->getName().c_str());
                                
                        }
                    |   ID{
                                $$ = $1;
                                fprintf(logOut, "Line %d: declaration_list : ID\n\n%s\n\n",line_count, $$->getName().c_str());
                        }
                    |   ID LTHIRD CONST_INT RTHIRD{
                                string temp = $1->getName() + "[" + $3->getName() + "]";
                                $$ = new SymbolInfo(temp, "ID");
                                fprintf(logOut, "Line %d: declaration_list : ID LTHIRD CONST_INT RTHIRD\n\n%s\n\n",line_count, $$->getName().c_str());
                        }
                    ;

statements          :   statement
                    |   statements statement
                    ;

statement           :   var_declaration
                    |   expression_statement
                    |   compound_statement
                    |   FOR LPAREN expression_statement expression_statement expression RPAREN statement
                    |   IF LPAREN expression RPAREN statement
                    |   IF LPAREN expression RPAREN statement ELSE statement
                    |   WHILE LPAREN expression RPAREN statement
                    |   PRINTLN LPAREN ID RPAREN SEMICOLON
                    |   RETURN expression SEMICOLON
                    ;

expression_statement:   SEMICOLON
                    |   expression SEMICOLON
                    ;
                
variable            :   ID{
                                //undeclared variable
                                if(!table.lookup($1->getName())){
                                        fprintf(errorOut, "Error at line %d: Undeclared variable %s\n\n", line_count, $1->getName().c_str());
                                }      
                                $$ = new SymbolInfo($1->getName(), "VARIABLE");
                                fprintf(logOut, "Line %d: variable : ID\n\n%s\n\n",line_count, $$->getName().c_str());
                        }
                    |   ID LTHIRD expression RTHIRD{
                                SymbolInfo * symbol = table.lookup($1->getName());
                                //undeclared variable
                                if(symbol){
                                        fprintf(errorOut, "Error at line %d: Undeclared variable %s\n\n", line_count, $1->getName().c_str());
                                }
                                //not an array
                                else if(!symbol->getIsArray()){
                                        fprintf(errorOut, "Error at line %d: %s not an array\n\n", line_count, $1->getName().c_str());
                                }
                                //implement index not integer
                                $$ = new SymbolInfo($1->getName()+"["+$$->getName()+"]", "VARIABLE");
                                fprintf(logOut, "Line %d: variable : ID LTHIRD expression RTHIRD\n\n%s\n\n",line_count, $$->getName().c_str());

                        }
                    ;

expression          :   logic_expression
                    |   variable ASSIGNOP logic_expression
                    ;

logic_expression    :   rel_expression
                    |   rel_expression LOGICOP rel_expression
                    ;

rel_expression      :   simple_expression
                    |   simple_expression RELOP simple_expression
                    ;

simple_expression   :   term
                    |   simple_expression ADDOP term
                    ;

term                :   unary_expression
                    |   term MULOP unary_expression     
                    ;

unary_expression    :   ADDOP unary_expression
                    |   NOT unary_expression
                    |   factor
                    ;

factor              :   variable    
                    |   ID LPAREN argument_list RPAREN
                    |   LPAREN expression RPAREN
                    |   CONST_INT
                    |   CONST_FLOAT
                    |   variable INCOP
                    |   variable DECOP
                    ;

argument_list       :   arguments 
                    |
                    ;

arguments           :   arguments COMMA logic_expression
                    |   logic_expression
                    ;


%%

int main()
{
        cout << "Running::\n";
	if((inputFile=fopen("input.txt","r"))==NULL)
	{
		printf("Cannot Open Input File.\n");
		exit(1);
	}

	logOut = fopen("1805111_log.txt","w");
	errorOut = fopen("1805111_error.txt","w");
	
	yyin=inputFile;
	yyparse();

        table.print(logOut);
	

	fclose(logOut);
	fclose(errorOut);
	
	return 0;
}