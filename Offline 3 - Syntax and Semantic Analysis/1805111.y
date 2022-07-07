%{
#include <bits/stdc++.h>
#include <stdio.h>
#include <cstring>
#include <stdlib.h>
#include "1805111_SymbolTable.cpp"
#include "SimpleText.cpp"

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

string toStringDeclarationList(vector<SymbolInfo*>* symbols){
        string ans = "";
        for(int i=0;i<symbols
->size();i++){
                ans+=symbols
        ->at(i)->getName();
                if(symbols
        ->at(i)->getIsArray()){
                        ans+="[" + to_string(symbols
                ->at(i)->getArraySize()) + "]";
                }
                if(i!=symbols
        ->size()-1) ans +=",";
        }
        return ans;
}

string toStringVarDeclaration(vector<SymbolInfo*>* symbols){
        string ans = "";
        ans+=symbols->at(0)->getName()+" ";

        for(int i=1;i<symbols->size();i++){
                ans+=symbols->at(i)->getName();
                if(symbols->at(i)->getIsArray()){
                        ans+="[" + to_string(symbols->at(i)->getArraySize()) + "]";
                }
                if(i!=symbols->size()-1) ans +=",";
        }
        ans+=";\n";
        return ans;
}

string toStringParameterList(vector<SymbolInfo*>* symbols){
        string ans = "";
        for(int i=0;i<symbols->size();i++){
                ans += symbols->at(i)->getType();
                if(symbols->at(i)->getName()!=""){
                        ans+=" ";
                        ans += symbols->at(i)->getName();
                }
                if(i!=symbols->size()-1) ans+=", ";
        }
        return ans;
}

string toStringFuncDeclaration(vector<SymbolInfo*>* symbols){
        string ans = "";
        ans+=symbols->at(0)->getName() + " ";
        ans+=symbols->at(1)->getName() + "(";
        if(symbols->size()>2){
                vector<SymbolInfo*>* parameters = new vector<SymbolInfo*> (symbols->begin()+2, symbols->end());
                ans+=toStringParameterList(parameters);
        }
        ans+=");\n";
        return ans;
}

%}

%define parse.error verbose

%union{ 
        SymbolInfo* symbolInfo;
        SimpleText* text;
        vector <SymbolInfo* >* multipleSymbols;  
}


%token BREAK CASE CONTINUE DEFAULT RETURN SWITCH VOID CHAR DOUBLE FLOAT INT DO WHILE FOR IF ELSE
%token INCOP DECOP ASSIGNOP NOT LPAREN RPAREN LCURL RCURL LTHIRD RTHIRD NEWLINE
%token COMMA SEMICOLON PRINTLN

%token <symbolInfo> ID CONST_INT CONST_FLOAT CONST_CHAR ADDOP MULOP RELOP LOGICOP

%type <symbolInfo> start variable type_specifier 
%type <symbolInfo> expression_statement 
%type <symbolInfo> unary_expression factor arguments 
%type <symbolInfo> expression logic_expression simple_expression rel_expression term argument_list
%type <text> statement statements compound_statement func_definition unit program
%type <multipleSymbols> declaration_list var_declaration parameter_list func_declaration 

%%
start   :   program     {
                        fprintf(logOut,"Line %d: start  :  program\n\n%s\n\n", line_count, $$->getName().c_str());
                }

program :   program unit{
                        $$ = new SimpleText($1->getText() + $2->getText());
                        fprintf(logOut,"Line %d: program  :  program unit\n\n%s\n\n", line_count, $$->getText().c_str());
                }
        |   unit{
                        $$ = new SimpleText($1->getText());
                        fprintf(logOut,"Line %d: program  :  unit\n\n%s\n\n", line_count, $$->getText().c_str());
                }
        ;

unit    :   var_declaration{
                        $$ = new SimpleText(toStringVarDeclaration($1));
                        fprintf(logOut,"Line %d: unit  :  var_declaration\n\n%s\n\n", line_count, $$->getText().c_str());
                }
        |   func_declaration{
                        $$ = new SimpleText(toStringFuncDeclaration($1));
                        fprintf(logOut,"Line %d: unit  :  func_declaration\n\n%s\n\n", line_count, $$->getText().c_str());
                }
        |   func_definition{
                        $$ = new SimpleText($1->getText());
                        fprintf(logOut,"Line %d: unit  :  func_definition\n\n%s\n\n", line_count, $$->getText().c_str());
                }       
        ;

func_declaration    :   type_specifier ID LPAREN parameter_list RPAREN SEMICOLON{
                                $$ = new vector<SymbolInfo*>();
                                $$->push_back($1);
                                $$->push_back($2);
                                if(table.lookup($2->getName())){
                                        fprintf(errorOut, "Error at line %d: Multiple declaration of %s\n\n", line_count, $2->getName().c_str());
                                }
                                map<string,int> params;
                                for(int i=0;i<$4->size();i++){
                                        // cout << $4->at(i)->getName() << " dd " << $4->at(i)->getType() << endl;
                                        $$->push_back($4->at(i));
                                        string curName = $4->at(i)->getName();
                                        if(params[curName]!=0 && curName!="") 
                                                fprintf(errorOut, "Error at line %d: Multiple declaration of %s in parameter\n\n", line_count, curName.c_str());
                                        params[curName]++;
                                }
                                SymbolInfo* newFunction = new SymbolInfo($2->getName(), "ID");
                                newFunction->setParameters($4);
                                newFunction->setReturnType($1->getName());
                                table.insert(newFunction);
                                fprintf(logOut,"Line %d: func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON\n\n%s\n\n", line_count, toStringFuncDeclaration($$).c_str());
                        }
                    |   type_specifier ID LPAREN RPAREN SEMICOLON{
                                $$ = new vector<SymbolInfo*>();
                                $$->push_back($1);
                                $$->push_back($2);
                                SymbolInfo* newFunction = new SymbolInfo($2->getName(), "ID");
                                newFunction->setReturnType($1->getName());
                                table.insert(newFunction);
                                fprintf(logOut,"Line %d: func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON\n\n%s\n\n", line_count, toStringFuncDeclaration($$).c_str());
                                
                        }
                    ;


func_definition     :   type_specifier ID LPAREN parameter_list RPAREN compound_statement {
                                $$ = new SimpleText();
                                SymbolInfo * func = table.lookup($2->getName());
                                if(!func){
                                        if(func->getIsFunc()){
                                                if(func->getIsFuncDefined()){
                                                        // error :: redefinition of function

                                                }
                                                else if(!func->matchParamList($4) || !func->matchReturnType($1->getName())){
                                                        // error :: function does not match signature
                                                }
                                                else {
                                                        func->setDefined();          
                                                        $$->appendText($1->getName() + " " + $2->getName());
                                                        $$->appendText("(" + toStringParameterList($4) +")");
                                                        $$->appendText($6->getText()); 
                                                }
                                        }
                                        else{
                                                //error :: not a function
                                        }
                                }
                                else{
                                        func->setDefined();          
                                        $$->appendText($1->getName() + " " + $2->getName());
                                        $$->appendText("(" + toStringParameterList($4) +")");
                                        $$->appendText($6->getText()); 
                                }
                                fprintf(logOut,"Line %d: func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement \n\n%s\n\n", line_count, $$->getText().c_str());
                        }
                    |   type_specifier ID LPAREN RPAREN compound_statement {
                                $$ = new SimpleText();
                                SymbolInfo * func = table.lookup($2->getName());
                                if(!func){
                                        if(func->getIsFunc()){
                                                if(func->getIsFuncDefined()){
                                                        // error :: redefinition of function

                                                }
                                                else if(!func->matchParamList(new vector<SymbolInfo*>) || !func->matchReturnType($1->getName())){
                                                        // error :: function does not match signature
                                                }
                                                else {
                                                        func->setDefined();          
                                                        $$->appendText($1->getName() + " " + $2->getName());
                                                        $$->appendText("()");
                                                        $$->appendText($5->getText()); 
                                                }
                                        }
                                        else{
                                                //error :: not a function
                                        }
                                }
                                else{
                                        func->setDefined();          
                                        $$->appendText($1->getName() + " " + $2->getName());
                                        $$->appendText("()");
                                        $$->appendText($5->getText()); 
                                }
                                fprintf(logOut,"Line %d: func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement \n\n%s\n\n", line_count, $$->getText().c_str());
                        }
                    ;

parameter_list      :   parameter_list COMMA type_specifier ID{
                                $$ = new vector<SymbolInfo*>($1->begin(),$1->end());
                                $$->push_back(new SymbolInfo($4->getName(), $3->getName()));
                                fprintf(logOut,"Line %d: parameter_list  :  parameter_list COMMA type_specifier ID\n\n%s\n\n", line_count, toStringParameterList($$).c_str());
                        }
                    |   parameter_list COMMA type_specifier{
                                $$ = new vector<SymbolInfo*>($1->begin(),$1->end());
                                $$->push_back(new SymbolInfo("", $3->getName()));
                                fprintf(logOut,"Line %d: parameter_list  :  parameter_list COMMA type_specifier\n\n%s\n\n", line_count, toStringParameterList($$).c_str());
                        }
                    |   type_specifier ID{
                                $$ = new vector<SymbolInfo*>();
                                $$->push_back(new SymbolInfo($2->getName(),$1->getName()));
                                fprintf(logOut,"Line %d: parameter_list  :  type_specifier ID\n\n%s\n\n", line_count, toStringParameterList($$).c_str());
                        }
                    |   type_specifier{
                                $$ = new vector<SymbolInfo*>();
                                $$->push_back(new SymbolInfo("", $1->getName()));
                                fprintf(logOut,"Line %d: parameter_list  :  type_specifier\n\n%s\n\n", line_count, toStringParameterList($$).c_str());

                        }
                    ;

compound_statement   :   LCURL statements RCURL {
                                $$ = new SimpleText("{\n" + $2->getText() + "}\n");
                                fprintf(logOut,"Line %d: compound_statement  :  LCURL statements RCURL\n\n%s\n\n", line_count, $$->getText().c_str());
                        }
                    |   LCURL RCURL {
                                $$ = new SimpleText("{}\n");
                                fprintf(logOut,"Line %d: compound_statement  :  LCURL statements RCURL\n\n%s\n\n", line_count, $$->getText().c_str());
                        
                    }
                    ;

var_declaration     : type_specifier declaration_list SEMICOLON {
                                $$ = new vector<SymbolInfo*>();
                                $$->push_back($1);
                                // variable type cannot be void
                                if($1->getType()=="VOID") {
                                        fprintf(errorOut, "Void variables\n");
                                        
                                }
                                else{
                                        for(int i=0;i<$2->size();i++){
                                                $$->push_back($2->at(i));
                                                if(table.lookup($2->at(i)->getName())){
                                                        fprintf(errorOut, "Error at line %d: Multiple declaration of %s\n\n", line_count, $2->at(i)->getName().c_str());
                                                }
                                                else{
                                                        $2->at(i)->setDataType($1->getName());
                                                        table.insert($2->at(i));
                                                        SymbolInfo* s = table.lookup($2->at(i)->getName());
                                                        s->setDataType($1->getName());
                                                        // cout << "var_dec " << s->getName() << "  " << s->getDataType() << endl;
                                                }
                                        }
                                }
                                fprintf(logOut, "Line %d: var_declaration : type_specifier declaration_list SEMICOLON\n\n%s %s;\n\n", line_count, $1->getName().c_str(),toStringDeclarationList($2).c_str());
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
                                $$ = new vector<SymbolInfo*>($1->begin(), $1->end());
                                $$->push_back($3);
                                fprintf(logOut, "Line %d: declaration_list : declaration_list COMMA ID\n\n%s\n\n",line_count,toStringDeclarationList($$).c_str());
                        }
                    |   declaration_list COMMA ID LTHIRD CONST_INT RTHIRD{
                                $$ = new vector<SymbolInfo*>($1->begin(), $1->end());
                                SymbolInfo* arrSymbol = new SymbolInfo($3->getName(), $3->getType());
                                arrSymbol->setArraySize(stoi($5->getName()));
                                $$->push_back(arrSymbol);
                                fprintf(logOut, "Line %d: declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD\n\n%s\n\n",line_count, toStringDeclarationList($$).c_str());
                                
                        }
                    |   ID{
                                $$ = new vector<SymbolInfo*>();
                                $$->push_back($1);
                                fprintf(logOut, "Line %d: declaration_list : ID\n\n%s\n\n",line_count, toStringDeclarationList($$).c_str());
                        }
                    |   ID LTHIRD CONST_INT RTHIRD{
                                $$ = new vector<SymbolInfo*>();
                                SymbolInfo* arrSymbol = new SymbolInfo($1->getName(), $1->getType());
                                arrSymbol->setArraySize(stoi($3->getName()));
                                $$->push_back(arrSymbol);
                                fprintf(logOut, "Line %d: declaration_list : ID LTHIRD CONST_INT RTHIRD\n\n%s\n\n",line_count, toStringDeclarationList($$).c_str());
                        }
                    ;

statements          :   statement {
                                $$ = new SimpleText($1->getText());
                                fprintf(logOut, "Line %d: statements : statement\n\n%s\n\n",line_count, $$->getText().c_str());
                        }
                    |   statements statement{
                                $$ = new SimpleText($1->getText() + $2->getText());
                                fprintf(logOut, "Line %d: statements : statements statement\n\n%s\n\n",line_count, $$->getText().c_str());

                        }
                    ;

statement           :   var_declaration{
                                $$ = new SimpleText(toStringVarDeclaration($1));
                                fprintf(logOut, "Line %d: statement : var_declaration\n\n%s\n\n",line_count, $$->getText().c_str());
                        }
                    |   expression_statement {
                                $$ = new SimpleText($1->getName());
                                fprintf(logOut, "Line %d: statement : expression_statement\n\n%s\n\n",line_count, $$->getText().c_str());

                        }
                    |   compound_statement{
                                $$ = new SimpleText($1->getText());
                                fprintf(logOut, "Line %d: statement : compound_statement\n\n%s\n\n",line_count, $$->getText().c_str());
                        }
                    |   FOR LPAREN expression_statement expression_statement expression RPAREN statement
                    |   IF LPAREN expression RPAREN statement
                    |   IF LPAREN expression RPAREN statement ELSE statement
                    |   WHILE LPAREN expression RPAREN statement
                    |   PRINTLN LPAREN ID RPAREN SEMICOLON
                    |   RETURN expression SEMICOLON
                    ;

expression_statement:   SEMICOLON{
                                $$ = new SymbolInfo(";", "expression_statement");
                                fprintf(logOut, "Line %d: expression_statement : SEMICOLON\n\n%s\n\n",line_count, $$->getName().c_str());

                        }
                    |   expression SEMICOLON {
                                $$ = new SymbolInfo($1->getName() + ";\n", "expression_statement");
                                fprintf(logOut, "Line %d: expression_statement : expression SEMICOLON\n\n%s\n\n",line_count, $$->getName().c_str());
                        }
                    ;
                
variable            :   ID{
                                //undeclared variable
                                SymbolInfo * symbol = table.lookup($1->getName());
                                if(!symbol){
                                        fprintf(errorOut, "Error at line %d: Undeclared variable %s\n\n", line_count, $1->getName().c_str());
                                }      
                                $$ = new SymbolInfo($1->getName(), symbol->getType());
                                $$->setDataType(symbol->getDataType());
                                // cout << "variable dt " << symbol->getName() << " d" << symbol->getDataType() << endl;

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
                                $$ = new SymbolInfo($1->getName()+"["+$3->getName()+"]", symbol->getType());
                                $$->setDataType(symbol->getDataType());

                                fprintf(logOut, "Line %d: variable : ID LTHIRD expression RTHIRD\n\n%s\n\n",line_count, $$->getName().c_str());

                        }
                    ;

expression          :   logic_expression{
                                $$ = new SymbolInfo($1->getName(), "expression");
                                $$->setDataType($1->getDataType());
                                fprintf(logOut, "Line %d: expression : logic_expression\n\n%s\n\n",line_count, $$->getName().c_str());

                        }
                    |   variable ASSIGNOP logic_expression {
                                // perform type check
                                $$ = new SymbolInfo($1->getName() + "=" + $3->getName(), "expression");
                                $$->setDataType($1->getDataType());
                                fprintf(logOut, "Line %d: expression : variable ASSIGNOP logic_expression \n\n%s\n\n",line_count, $$->getName().c_str());
                        }
                    ;

logic_expression    :   rel_expression {
                                $$ = new SymbolInfo($1->getName(), "logic_expression");
                                $$->setDataType("int");
                                fprintf(logOut, "Line %d: logic_expression : rel_expression\n\n%s\n\n",line_count, $$->getName().c_str());

                        }
                    |   rel_expression LOGICOP rel_expression{
                                $$ = new SymbolInfo($1->getName() + $2->getName() + $3->getName(), "logic_expression");
                                $$->setDataType("int");
                                fprintf(logOut, "Line %d: logic_expression : rel_expression LOGICOP rel_expression\n\n%s\n\n",line_count, $$->getName().c_str());
                        }
                    ;

rel_expression      :   simple_expression{
                                $$ = new SymbolInfo($1->getName(), "rel_expression");
                                $$->setDataType("int");
                                fprintf(logOut, "Line %d: rel_expression : simple_expression\n\n%s\n\n",line_count, $$->getName().c_str());

                        }
                    |   simple_expression RELOP simple_expression
                    ;

simple_expression   :   term {
                                $$ = new SymbolInfo($1->getName(), "simple_expression");
                                $$->setDataType($1->getDataType());
                                fprintf(logOut, "Line %d: simple_expression : term\n\n%s\n\n",line_count, $$->getName().c_str());

                        }
                    |   simple_expression ADDOP term{
                                //check types
                                $$ = new SymbolInfo($1->getName() + $2->getName() + $3->getName(), "simple_expression");
                                $$->setDataType($1->getDataType());
                                fprintf(logOut, "Line %d: simple_expression : simple_expression ADDOP term\n\n%s\n\n",line_count, $$->getName().c_str());
                                
                        }
                    ;

term                :   unary_expression{
                                $$ = new SymbolInfo($1->getName(), "term");
                                $$->setDataType($1->getDataType());
                                fprintf(logOut, "Line %d: term : unary_expression\n\n%s\n\n",line_count, $$->getName().c_str());

                        }
                    |   term MULOP unary_expression   {
                                $$ = new SymbolInfo($1->getName() + $2->getName() + $3->getName(), "term");
                                $$->setDataType($1->getDataType());
                                // cout << $2->getName() << " " << $2->getDataType() << " " << $3->getDataType() << endl;
                                if(($1->getDataType()=="float" || $3->getDataType()=="float") && $2->getName()=="%"){
                                        fprintf(errorOut,"Error at line %d: Non-Integer operand on modulus operator\n\n", line_count);
                                }

                                // if(stof($3->getName())==0 && $2->getName()=="\/"){ 
                                //         fprintf(errorOut,"Error at line %d: Division by zero\n\n", line_count);
                                // }

                                // if(stof($3->getName())==0 && $2->getName()=="\/"){ 
                                //         fprintf(errorOut,"Error at line %d: Modulus by zero\n\n", line_count);
                                // }
                                
                                fprintf(logOut, "Line %d: term : term MULOP unary_expression\n\n%s\n\n",line_count, $$->getName().c_str());
                                
                        }    
                    ;

unary_expression    :   ADDOP unary_expression{
                                $$ = new SymbolInfo($1->getName() + $2->getName(), "unary_expression");
                                $$->setDataType($2->getDataType());
                                fprintf(logOut, "Line %d: unary_expression : NOT unary_expression\n\n%s\n\n",line_count, $$->getName().c_str());
                      
                        }
                    |   NOT unary_expression {
                                $$ = new SymbolInfo("!" + $2->getName(), "unary_expression");
                                $$->setDataType($2->getDataType());
                                fprintf(logOut, "Line %d: unary_expression : NOT unary_expression\n\n%s\n\n",line_count, $$->getName().c_str());
                        }
                    |   factor  {
                                $$ = new SymbolInfo($1->getName(), "unary_expression");
                                $$->setDataType($1->getDataType());
                                fprintf(logOut, "Line %d: unary_expression : factor\n\n%s\n\n",line_count, $$->getName().c_str());

                        }
                    ;

factor              :   variable  {
                                // cout << $1->getName() << " factor dt " << $1->getDataType() << endl;
                                $$ = new SymbolInfo($1->getName(), "factor");
                                $$->setDataType($1->getDataType());
                                fprintf(logOut, "Line %d: factor : variable\n\n%s\n\n",line_count, $$->getName().c_str());
                        }  
                    |   ID LPAREN argument_list RPAREN {
                                SymbolInfo * func = table.lookup($1->getName());
                                if(!func){
                                        // error :: function not declared
                                        fprintf(errorOut, "Error at line %d: Undeclared function %s\n\n", line_count, $1->getName().c_str());
                                
                                }
                                else if(!func->getIsFunc()){
                                        fprintf(errorOut, "Error at line %d: Undeclared function %s\n\n", line_count, $1->getName().c_str());
                                }
                                $$ = new SymbolInfo($1->getName(), "factor");
                                $$->setDataType($1->getReturnType());
                                fprintf(logOut, "Line %d: factor : ID LPAREN argument_list RPAREN\n\n%s\n\n",line_count, $$->getName().c_str());
                               
                        }  
                    |   LPAREN expression RPAREN {
                                $$ = new SymbolInfo("(" + $2->getName() + ")", "factor");
                                $$->setDataType($2->getDataType());
                                fprintf(logOut, "Line %d: factor : LPAREN expression RPAREN\n\n%s\n\n",line_count, $$->getName().c_str());

                        }
                    |   CONST_INT {
                                $$ = new SymbolInfo($1->getName(), "factor");
                                $$->setDataType("int");
                                fprintf(logOut, "Line %d: factor : CONST_INT\n\n%s\n\n",line_count, $$->getName().c_str());
                        }
                    |   CONST_FLOAT{
                                $$ = new SymbolInfo($1->getName(), "factor");
                                $$->setDataType("float");
                                fprintf(logOut, "Line %d: factor : CONST_INT\n\n%s\n\n",line_count, $$->getName().c_str());
                        }
                    |   variable INCOP{
                                $$ = new SymbolInfo($1->getName()+"++", "factor");
                                $$->setDataType($1->getDataType());
                                fprintf(logOut, "Line %d: factor : variable INCOP\n\n%s\n\n",line_count, $$->getName().c_str());
                                
                        }
                    |   variable DECOP{
                                $$ = new SymbolInfo($1->getName()+"++", "factor");
                                $$->setDataType($1->getDataType());
                                fprintf(logOut, "Line %d: factor : variable DECOP\n\n%s\n\n",line_count, $$->getName().c_str());
                                
                        }
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