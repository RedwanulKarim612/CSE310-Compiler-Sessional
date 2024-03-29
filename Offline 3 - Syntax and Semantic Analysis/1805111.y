%{
#include <bits/stdc++.h>
#include <stdio.h>
#include <cstring>
#include <stdlib.h>
#include "1805111_SymbolTable.cpp"
#include "SimpleText.cpp"
#define YYDEBUG 1
#define error "ERROR"

SymbolTable table(31);
FILE* inputFile;
FILE* logOut;
FILE* errorOut;
extern FILE* yyin;
extern int line_count;
extern int error_count;

int yylex(void);
int yyparse(void);

vector<SymbolInfo*> parameterBuffer;
string curReturnType = "";

string toStringDeclarationList(vector<SymbolInfo*>* symbols){
        string ans = "";
        for(int i=0;i<symbols->size();i++){
                ans+=symbols->at(i)->getName();
                if(symbols->at(i)->getIsArray()){
                        ans+="[" + to_string(symbols->at(i)->getArraySize()) + "]";
                }
                if(i!=symbols->size()-1) ans +=",";
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
                ans += symbols->at(i)->getDataType();
                if(symbols->at(i)->getName()!=""){
                        ans+=" ";
                        ans += symbols->at(i)->getName();
                }
                if(i!=symbols->size()-1) ans+=",";
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

string toStringArguments(vector<SymbolInfo*>* symbols){
        string ans = "";
        for(int i=0;i<symbols->size();i++){
                ans += symbols->at(i)->getName();
                if(i!=symbols->size()-1)
                        ans+=",";
        }
        return ans;
}


void printError(string errorMsg){
        fprintf(errorOut, "Error at line %d: %s\n\n", line_count, errorMsg.c_str());
        fprintf(logOut, "Error at line %d: %s\n\n", line_count, errorMsg.c_str());
        error_count++;
}

string decideDataType(SymbolInfo* op1, SymbolInfo* op2){
        if(op1->getDataType()=="float" || op2->getDataType()=="float") {
                op1->setDataType("float");
                op2->setDataType("float");
                return "float";
        }
        if(op1->getDataType()=="void" || op2->getDataType()=="void"){
                printError("Void function used in expression");
                return "int";
        }
        return op1->getDataType();
}

void storeIntoBuffer(vector<SymbolInfo*>* params){
        parameterBuffer.clear();
        for(int i=0;i<params->size();i++){
                params->at(i)->setType("ID");
                parameterBuffer.push_back(params->at(i));
                // cout << parameterBuffer[i]->getName() << endl;
        }
}

void loadFromBuffer(){
        if(!parameterBuffer.empty()){
                // cout << "load from buffer";
                for(int i=0;i<parameterBuffer.size();i++){
                        // cout << parameterBuffer[i]->getName() << endl;
                       table.insert(parameterBuffer[i]);
                }
        }
        parameterBuffer.clear();       
}


void yyerror(const char *s){
        printError("syntax error");
}

bool multpipleParameterDeclaration(vector<SymbolInfo*>* parameterList, string name){
        if(name=="") return false;
        for(int i=0;i<parameterList->size();i++){
                if(parameterList->at(i)->getName()==name){
                        return true;
                }
        }
        return false;
}

%}

%union{ 
        SymbolInfo* symbolInfo;
        SimpleText* text;
        vector <SymbolInfo* >* multipleSymbols;  
}

%token BREAK CASE CONTINUE DEFAULT RETURN SWITCH VOID CHAR DOUBLE FLOAT INT DO WHILE FOR IF ELSE
%token INCOP DECOP ASSIGNOP NOT LPAREN RPAREN LCURL RCURL LTHIRD RTHIRD NEWLINE COMMA SEMICOLON PRINTLN 
%token <symbolInfo> ID CONST_INT CONST_FLOAT CONST_CHAR ADDOP MULOP RELOP LOGICOP UNREC_CHAR

%type <symbolInfo> start variable type_specifier expression_statement unary_expression factor 
%type <symbolInfo> expression logic_expression simple_expression rel_expression term 
%type <text> statement statements compound_statement func_definition unit program 
%type <multipleSymbols> declaration_list var_declaration parameter_list func_declaration argument_list arguments 

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%%
start   :   program     {
                        fprintf(logOut,"Line %d: start : program\n\n", line_count);
                }

program :   program unit{
                        $$ = new SimpleText($1->getText() + $2->getText());
                        fprintf(logOut,"Line %d: program : program unit\n\n%s\n\n", line_count, $$->getText().c_str());
                }
        |   unit{
                        $$ = new SimpleText($1->getText());
                        fprintf(logOut,"Line %d: program : unit\n\n%s\n\n", line_count, $$->getText().c_str());
                }
        ;

unit    :   var_declaration{
                        $$ = new SimpleText(toStringVarDeclaration($1));
                        fprintf(logOut,"Line %d: unit : var_declaration\n\n%s\n\n", line_count, $$->getText().c_str());
                }
        |   func_declaration{
                        $$ = new SimpleText(toStringFuncDeclaration($1));
                        fprintf(logOut,"Line %d: unit : func_declaration\n\n%s\n\n", line_count, $$->getText().c_str());
                }
        |   func_definition{
                        $$ = new SimpleText($1->getText());
                        fprintf(logOut,"Line %d: unit : func_definition\n\n%s\n\n", line_count, $$->getText().c_str());
                }      
        ;

func_declaration    :   type_specifier ID LPAREN parameter_list RPAREN SEMICOLON{
                                fprintf(logOut,"Line %d: func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON\n\n", line_count);

                                if(!table.isGlobalScope()){
                                        printError("illegal scoping of function " + $2->getName());
                                }
                                $$ = new vector<SymbolInfo*>();
                                $$->push_back($1);
                                $$->push_back($2);
                                if(table.lookup($2->getName())){
                                        printError("Multiple declaration of function " + $2->getName());
                                }
                                map<string,int> params;
                                for(int i=0;i<$4->size();i++){
                                        // cout << $4->at(i)->getName() << " dd " << $4->at(i)->getType() << endl;
                                        $$->push_back($4->at(i));
                                        string curName = $4->at(i)->getName();
                                        if(params[curName]!=0 && curName!="") 
                                                printError("Multiple declaration of " + curName +" in parameter");
                                        params[curName]++;
                                }
                                SymbolInfo* newFunction = new SymbolInfo($2->getName(), "ID");
                                newFunction->setParameters($4);
                                newFunction->setReturnType($1->getName());
                                table.insert(newFunction);
                                table.enterScope();
                                table.exitScope();
                                fprintf(logOut,"%s\n\n", toStringFuncDeclaration($$).c_str());
                        }
                    |   type_specifier ID LPAREN RPAREN SEMICOLON{
                                fprintf(logOut,"Line %d: func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON\n\n", line_count);
                                if(!table.isGlobalScope()){
                                        printError("illegal scoping of function " + $2->getName());
                                }
                                if(table.lookup($2->getName())){
                                        printError("Multiple declaration of function " + $2->getName());
                                }
                                $$ = new vector<SymbolInfo*>();
                                $$->push_back($1);
                                $$->push_back($2);
                                SymbolInfo* newFunction = new SymbolInfo($2->getName(), "ID");
                                newFunction->setReturnType($1->getName());
                                table.insert(newFunction);
                                table.enterScope();
                                table.exitScope();
                                fprintf(logOut,"%s\n\n", toStringFuncDeclaration($$).c_str());
                        }
                    ;


func_definition     :   type_specifier ID LPAREN parameter_list RPAREN {
                                if(!table.isGlobalScope()){
                                        printError("illegal scoping of function " + $2->getName());
                                }
                                curReturnType=$1->getName();
                                storeIntoBuffer($4);      
                                SymbolInfo * func = table.lookup($2->getName());
                                if(func){
                                        if(func->getIsFunc()){

                                                if(func->getIsFuncDefined()){
                                                        // error :: redefinition of function
                                                        printError("Redefinition of function");
                                                }
                                                else {
                                                        // cout << func->getIsFuncDefined();
                                                        func->setDefined();    
                                                }
                                                if(!func->matchReturnType($1->getName())){
                                                        // error :: return type mismatch
                                                        // cout << $2->getName() << " " << $1->getName() << " " << func->getReturnType() << endl;
                                                        printError("Return type mismatch with function declaration in function " + $2->getName());
                                                }
                                                if(func->getNumberOfParameters()!=$4->size()){
                                                        // error :: wrong number of parameters
                                                        printError("Total number of arguments mismatch with declaration in function " + $2->getName());
                                                }
                                                else{
                                                        for(int i=0;i<$4->size();i++){
                                                                if($4->at(i)->getDataType()!=func->getithParameter(i)){
                                                                        printError(to_string(i+1) + "th parameter's name not given in function definition of " + $2->getName());
                                                                        break;
                                                                }
                                                        }
                                                        
                                                }
                                        }
                                        else{
                                                printError("Multiple declaration of "+ $2->getName());
                                                //error :: not a function
                                        }
                                }
                                else{
                                        SymbolInfo* newFunction = new SymbolInfo($2->getName(), $2->getType());
                                        newFunction->setParameters($4);
                                        newFunction->setReturnType($1->getName());
                                        newFunction->setDefined();
                                        table.insert(newFunction);    
                                }
                                map<string,int> params;

                        } compound_statement {

                                $$ = new SimpleText();
                                $$->appendText($1->getName() + " " + $2->getName());
                                $$->appendText("(" + toStringParameterList($4) +")");
                                $$->appendText($7->getText()+"\n"); 
                                curReturnType = "";
                                fprintf(logOut,"Line %d: func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement\n\n%s\n\n", line_count,$$->getText().c_str());
                        }
                    |   type_specifier ID LPAREN RPAREN {
                                if(!table.isGlobalScope()){
                                        printError("illegal scoping of function " + $2->getName());
                                }
                                curReturnType=$1->getName();
                                SymbolInfo * func = table.lookup($2->getName());
                                if(func){
                                        if(func->getIsFunc()){
                                                if(func->getIsFuncDefined()){
                                                        // error :: redefinition of function
                                                        printError("Redefinition of function");
                                                }
                                                else {
                                                        func->setDefined();    
                                                }
                                                if(!func->matchReturnType($1->getName())){
                                                        // error :: function does not match signature
                                                        printError("Return type mismatch with function declaration in function " + $2->getName());
                                                }
                                                if(func->getNumberOfParameters()!=0){
                                                        printError("Total number of arguments mismatch with declaration in function " + $2->getName());
                                                }
                                                
                                        }
                                        else{
                                                printError("Multiple declaration of "+ $2->getName());

                                                //error :: not a function
                                        }
                                }
                                else{
                                        SymbolInfo* newFunction = new SymbolInfo($2->getName(), $2->getType());
                                        newFunction->setReturnType($1->getName());
                                        newFunction->setDefined();
                                        table.insert(newFunction);
                                }
                                }  compound_statement {
                                        $$ = new SimpleText();
                                        $$->appendText($1->getName() + " " + $2->getName());
                                        $$->appendText("()");
                                        $$->appendText($6->getText()+"\n"); 
                                        curReturnType="";
                                        fprintf(logOut,"Line %d: func_definition : type_specifier ID LPAREN RPAREN compound_statement\n\n%s\n\n",line_count, $$->getText().c_str());
                                }
                    ;

parameter_list      :   parameter_list COMMA type_specifier ID{
                                $$ = new vector<SymbolInfo*>($1->begin(),$1->end());

                                if(multpipleParameterDeclaration($1,$4->getName())){
                                        printError("Multiple declaration of " + $4->getName() +" in parameter");
                                }
                                SymbolInfo* s = new SymbolInfo($4->getName(), "ID");
                                s->setDataType($3->getName());
                                $$->push_back(s);
                                
                                fprintf(logOut,"Line %d: parameter_list : parameter_list COMMA type_specifier ID\n\n%s\n\n",line_count, toStringParameterList($$).c_str());
                        }
                    |   parameter_list COMMA type_specifier{
                                $$ = new vector<SymbolInfo*>($1->begin(),$1->end());
                                SymbolInfo* s = new SymbolInfo("", "ID");
                                s->setDataType($3->getName());
                                $$->push_back(s);
                                fprintf(logOut,"Line %d: parameter_list : parameter_list COMMA type_specifier\n\n%s\n\n", line_count, toStringParameterList($$).c_str());
                        }
                    |   type_specifier ID{
                                $$ = new vector<SymbolInfo*>();
                                SymbolInfo* s = new SymbolInfo($2->getName(), "ID");
                                s->setDataType($1->getName());
                                $$->push_back(s);
                                fprintf(logOut,"Line %d: parameter_list : type_specifier ID\n\n%s\n\n", line_count, toStringParameterList($$).c_str());
                        }
                    |   type_specifier{
                                $$ = new vector<SymbolInfo*>();
                                SymbolInfo* s = new SymbolInfo("", "ID");
                                s->setDataType($1->getName());
                                $$->push_back(s);
                                fprintf(logOut,"Line %d: parameter_list : type_specifier\n\n%s\n\n", line_count, toStringParameterList($$).c_str());
                        }
                    |   parameter_list error {
                                $$ = new vector<SymbolInfo*>($1->begin(), $1->end());
                                yyclearin;
                                yyerrok;
                        }
                    ;

compound_statement   :   LCURL {table.enterScope();loadFromBuffer();} statements RCURL  {
                                $$ = new SimpleText("{\n" + $3->getText() + "}\n");
                                fprintf(logOut,"Line %d: compound_statement : LCURL statements RCURL\n\n%s\n\n", line_count, $$->getText().c_str());
                                table.print(logOut);
                                table.exitScope();
                        }
                    |   LCURL RCURL {table.enterScope();loadFromBuffer();}{
                                $$ = new SimpleText("{}\n");
                                fprintf(logOut,"Line %d: compound_statement : LCURL statements RCURL\n\n%s\n\n", line_count, $$->getText().c_str());
                                table.print(logOut);
                                table.exitScope();
                        }
                    ;

var_declaration     : type_specifier declaration_list SEMICOLON {
                                $$ = new vector<SymbolInfo*>();
                                $$->push_back($1);
                                // variable type cannot be void
                                fprintf(logOut, "Line %d: var_declaration : type_specifier declaration_list SEMICOLON\n\n", line_count);

                                if($1->getName()=="void") {
                                        printError("Variable type cannot be void");
                                }
                                
                                for(int i=0;i<$2->size();i++){
                                        $$->push_back($2->at(i));
                                        if(!table.lookupCurrentScopeTable($2->at(i)->getName())){
                                               
                                                $2->at(i)->setDataType($1->getName());
                                                table.insert($2->at(i));
                                                SymbolInfo* s = table.lookup($2->at(i)->getName());
                                                s->setDataType($1->getName());
                                                // cout << "var_dec " << s->getName() << "  " << s->getDataType() << endl;
                                        }
                                }
                        
                                fprintf(logOut, "%s %s;\n\n", $1->getName().c_str(),toStringDeclarationList($2).c_str());
                        }
                         
                    ;

type_specifier      : INT {
                                $$ = new SymbolInfo("int","INT");
                                fprintf(logOut,"Line %d: type_specifier : INT\n\n%s\n\n", line_count, $$->getName().c_str());
                        }
                    | FLOAT{
                                $$ = new SymbolInfo("float","FLOAT");
                                fprintf(logOut,"Line %d: type_specifier : FLOAT\n\n%s\n\n", line_count, $$->getName().c_str());
                        }
                    | VOID  {
                                $$ = new SymbolInfo("void","VOID");
                                fprintf(logOut,"Line %d: type_specifier : VOID\n\n%s\n\n", line_count, $$->getName().c_str());
                        }
                    ;

declaration_list    :   declaration_list COMMA ID{
                                $$ = new vector<SymbolInfo*>($1->begin(), $1->end());
                                $$->push_back($3);
                                if(table.lookupCurrentScopeTable($3->getName())){
                                        printError("Multiple declaration of " + $3->getName());
                                }
                                fprintf(logOut, "Line %d: declaration_list : declaration_list COMMA ID\n\n%s\n\n",line_count,toStringDeclarationList($$).c_str());
                        }
                    |   declaration_list COMMA ID LTHIRD CONST_INT RTHIRD{
                                $$ = new vector<SymbolInfo*>($1->begin(), $1->end());
                                SymbolInfo* arrSymbol = new SymbolInfo($3->getName(), $3->getType());
                                arrSymbol->setArraySize(stoi($5->getName()));
                                $$->push_back(arrSymbol);
                                if(table.lookupCurrentScopeTable($3->getName())){
                                        printError("Multiple declaration of " + $3->getName());
                                }
                                fprintf(logOut, "Line %d: declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD\n\n%s\n\n",line_count, toStringDeclarationList($$).c_str());
                                
                        }
                    |   ID{
                                $$ = new vector<SymbolInfo*>();
                                $$->push_back($1);
                                if(table.lookupCurrentScopeTable($1->getName())){
                                        printError("Multiple declaration of " + $1->getName());
                                }
                                fprintf(logOut, "Line %d: declaration_list : ID\n\n%s\n\n",line_count, toStringDeclarationList($$).c_str());
                        }
                    |   ID LTHIRD CONST_INT RTHIRD{
                                $$ = new vector<SymbolInfo*>();
                                SymbolInfo* arrSymbol = new SymbolInfo($1->getName(), $1->getType());
                                arrSymbol->setArraySize(stoi($3->getName()));
                                $$->push_back(arrSymbol);
                                if(table.lookupCurrentScopeTable($1->getName())){
                                        printError("Multiple declaration of " + $1->getName());
                                }
                                fprintf(logOut, "Line %d: declaration_list : ID LTHIRD CONST_INT RTHIRD\n\n%s\n\n",line_count, toStringDeclarationList($$).c_str());
                        }
                    |   declaration_list error {
                                $$ = new vector<SymbolInfo*>($1->begin(), $1->end());
                                yyclearin;
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
                    |   statements error{
                                $$ = new SimpleText($1->getText());
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
                    |   FOR LPAREN expression_statement expression_statement expression RPAREN statement {
                                $$ = new SimpleText("for(" + $3->getName().substr(0, $3->getName().size()-1) + $4->getName().substr(0, $4->getName().size()-1) + $5->getName() + ")" + $7->getText());
                                fprintf(logOut, "Line %d: statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement\n\n%s\n\n",line_count, $$->getText().c_str());
                        }
                    |   IF LPAREN expression RPAREN statement %prec LOWER_THAN_ELSE{
                                $$ = new SimpleText("if (" + $3->getName() + ")" + $5->getText());
                                fprintf(logOut, "Line %d: statement : IF LPAREN expression RPAREN statement\n\n%s\n\n",line_count, $$->getText().c_str());
                        }
                    |   IF LPAREN expression RPAREN statement ELSE statement {
                                $$ = new SimpleText("if (" + $3->getName() + ")" + $5->getText() + "else\n" + $7->getText());
                                fprintf(logOut, "Line %d: statement : IF LPAREN expression RPAREN statement ELSE statement\n\n%s\n\n",line_count, $$->getText().c_str());
                        }
                    |   WHILE LPAREN expression RPAREN statement{
                                $$ = new SimpleText("while (" + $3->getName() + ")" + $5->getText());
                                fprintf(logOut, "Line %d: statement : WHILE LPAREN expression RPAREN statement\n\n%s\n\n",line_count, $$->getText().c_str());
                        }
                    |   PRINTLN LPAREN ID RPAREN SEMICOLON{
                                $$ = new SimpleText("printf(" + $3->getName() + ");\n" );
                                fprintf(logOut, "Line %d: statement : PRINTLN LPAREN ID RPAREN SEMICOLON\n\n",line_count, $$->getText().c_str());
                                if(!table.lookup($3->getName())) printError("Undeclared variable " + $3->getName());
                                fprintf(logOut,"%s\n\n",$$->getText().c_str());

                        }
                    |   RETURN expression SEMICOLON{
                                if(curReturnType=="void"){
                                        // cout << "return type " << curReturnType << " " << $2->getDataType() << endl; 
                                        printError("Type mismatch, wrong return type");
                                }
                                else if(curReturnType=="int" && $2->getDataType()=="float"){                               
                                        printError("Type mismatch, wrong return type");
                                }
                                else if(curReturnType=="float" && $2->getDataType()=="int"){
                                        $2->setDataType("float");
                                }
                                curReturnType = "";
                                $$ = new SimpleText("return " + $2->getName() +";\n" );
                                fprintf(logOut, "Line %d: statement : RETURN expression SEMICOLON\n\n%s\n\n",line_count, $$->getText().c_str());
                        }
                    /* |   error statement{
                                $$ = new SimpleText($2->getText());
                        }     */
                    ;

expression_statement:   SEMICOLON{
                                $$ = new SymbolInfo(";\n", "expression_statement");
                                fprintf(logOut, "Line %d: expression_statement : SEMICOLON\n\n%s\n\n",line_count, $$->getName().c_str());

                        }
                    |   expression SEMICOLON {
                                $$ = new SymbolInfo($1->getName() + ";\n", "expression_statement");
                                fprintf(logOut, "Line %d: expression_statement : expression SEMICOLON\n\n%s\n\n",line_count, $$->getName().c_str());
                        }
                    
                    |   UNREC_CHAR{
                                $$ = new SymbolInfo();
                                printError("Unrecognized character " + $1->getName());
                                
                        }    
                    ;
                
variable            :   ID{
                                //error :: undeclared variable
                                SymbolInfo * symbol = table.lookup($1->getName());
                                fprintf(logOut, "Line %d: variable : ID\n\n",line_count);

                                if(!symbol){
                                        printError("Undeclared variable " + $1->getName());
                                }      
                                else if(symbol->getIsArray()){
                                        printError("Type mismatch, " + symbol->getName() + " is an array");
                                }
                                $$ = new SymbolInfo($1->getName(), $1->getType());
                                if(symbol) $$->setDataType(symbol->getDataType());
                                fprintf(logOut, "%s\n\n", $$->getName().c_str());
                        }
                    |   ID LTHIRD expression RTHIRD{
                                SymbolInfo * symbol = table.lookup($1->getName());
                                fprintf(logOut, "Line %d: variable : ID LTHIRD expression RTHIRD\n\n",line_count);

                                if(!symbol){
                                //error :: undeclared variable
                                        printError("Undeclared variable " + $1->getName());
                                }
                                else if(!symbol->getIsArray()){
                                //error :: not an array
                                        // cout << symbol->getName() << " " << symbol->getDataType() << endl;
                                        printError($1->getName() + " not an array");
                                }
                                else if($3->getDataType()!="int"){
                                //error :: index not integer
                                        printError("Expression inside third brackets not an integer");
                                }
                                $$ = new SymbolInfo($1->getName()+"["+$3->getName()+"]", symbol->getType());
                                $$->setDataType(symbol->getDataType());

                                fprintf(logOut, "%s\n\n", $$->getName().c_str());
                        }
                    ;

expression          :   logic_expression{
                                $$ = new SymbolInfo($1->getName(), "expression");
                                $$->setDataType($1->getDataType());
                                fprintf(logOut, "Line %d: expression : logic expression\n\n%s\n\n",line_count, $$->getName().c_str());

                        }
                    |   variable ASSIGNOP logic_expression {
                                // perform type check
                                $$ = new SymbolInfo($1->getName() + "=" + $3->getName(), "expression");
                                fprintf(logOut, "Line %d: expression : variable ASSIGNOP logic_expression\n\n",line_count);

                                $$->setDataType($1->getDataType());
                                if($1->getDataType()=="int" && $3->getDataType()=="float"){
                                        printError("Type Mismatch");
                                }
                                if($3->getDataType()=="void"){
                                        printError("Void function used in expression");
                                }
                                // cout << $1->getName() << " " << $3->getDataType() << endl;
                                fprintf(logOut, "%s\n\n", $$->getName().c_str());
                        }
                    ;

logic_expression    :   rel_expression {
                                $$ = new SymbolInfo($1->getName(), "logic_expression");
                                $$->setDataType($1->getDataType());
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
                                $$->setDataType($1->getDataType());
                                fprintf(logOut, "Line %d: rel_expression : simple_expression\n\n%s\n\n",line_count, $$->getName().c_str());

                        }
                    |   simple_expression RELOP simple_expression {
                                // cout << "RELOP\n";
                                $$ = new SymbolInfo($1->getName() + $2->getName() + $3->getName(), "rel_expression");
                                $$->setDataType("int");
                                fprintf(logOut, "Line %d: rel_expression : simple_expression RELOP simple_expression\n\n%s\n\n", line_count, $$->getName().c_str());

                        }
                    ;

simple_expression   :   term {
                                $$ = new SymbolInfo($1->getName(), "simple_expression");
                                $$->setDataType($1->getDataType());
                                fprintf(logOut, "Line %d: simple_expression : term\n\n%s\n\n",line_count, $$->getName().c_str());

                        }
                    |   simple_expression ADDOP term{
                                //check types
                                $$ = new SymbolInfo($1->getName() + $2->getName() + $3->getName(), "simple_expression");
                                $$->setDataType(decideDataType($1,$3));
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
                                fprintf(logOut, "Line %d: term : term MULOP unary_expression\n\n",line_count);

                                if($2->getName()=="%") $$->setDataType("int");
                                else $$->setDataType(decideDataType($1,$3));
                                // cout << $2->getName() << " " << $2->getDataType() << " " << $3->getDataType() << endl;
                                if(($1->getDataType()=="float" || $3->getDataType()=="float") && $2->getName()=="%"){
                                        printError("Non-Integer operand on modulus operator");
                                }
                                try{
                                        int uex = stof($3->getName());
                                        if(uex==0 && $2->getName()=="\/"){ 
                                                printError("Division by Zero");
                                        }

                                        if(uex==0 && $2->getName()=="%"){ 
                                                printError("Modulus by Zero");
                                        }
                                }
                                catch(invalid_argument){

                                }
                                fprintf(logOut, "%s\n\n", $$->getName().c_str());
                        }      
                    ;

unary_expression    :   ADDOP unary_expression{
                                $$ = new SymbolInfo($1->getName() + $2->getName(), "unary_expression");
                                $$->setDataType($2->getDataType());
                                fprintf(logOut, "Line %d: unary_expression : ADDOP unary_expression\n\n%s\n\n",line_count, $$->getName().c_str());
                      
                        }
                    |   NOT unary_expression {
                                $$ = new SymbolInfo("!" + $2->getName(), "unary_expression");
                                $$->setDataType("int");
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
                                fprintf(logOut, "Line %d: factor : ID LPAREN argument_list RPAREN\n\n",line_count);

                                if(!func){
                                        // error :: function not declared
                                        printError("Undeclared function " + $1->getName());
                                }
                                else if(!func->getIsFunc()){
                                        printError("not a function");
                                }
                                else if($3->size()!=func->getNumberOfParameters()){
                                        printError("Total number of arguments mismatch in function " + $1->getName());
                                }
                                else {
                                        for(int i=0;i<$3->size();i++){
                                                if($3->at(i)->getDataType()!=func->getithParameter(i) && func->getithParameter(i)!="float"){
                                                        printError(to_string(i+1) + "th argument mismatch in function " + $1->getName());
                                                        break;
                                                }
                                        }
                                }
                                $$ = new SymbolInfo($1->getName()+"("+toStringArguments($3)+")", "factor");
                                if(func)$$->setDataType(func->getReturnType());
                                fprintf(logOut, "%s\n\n", $$->getName().c_str());
                               
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
                                fprintf(logOut, "Line %d: factor : CONST_FLOAT\n\n%s\n\n",line_count, $$->getName().c_str());
                        }
                    |   variable INCOP {
                                $$ = new SymbolInfo($1->getName()+"++", "factor");
                                $$->setDataType($1->getDataType());
                                fprintf(logOut, "Line %d: factor : variable INCOP\n\n%s\n\n",line_count, $$->getName().c_str());
                                
                        }
                    |   variable DECOP {
                                $$ = new SymbolInfo($1->getName()+"--", "factor");
                                $$->setDataType($1->getDataType());
                                fprintf(logOut, "Line %d: factor : variable DECOP\n\n%s\n\n",line_count, $$->getName().c_str());
                                
                        }
                    
                    ;

argument_list       :   arguments {
                                $$ = new vector<SymbolInfo*>($1->begin(), $1->end());
                                fprintf(logOut, "Line %d: argument_list : arguments\n\n%s\n\n", line_count, toStringArguments($$).c_str());
                        }
                    |   {
                        $$ = new vector<SymbolInfo*>();
                        fprintf(logOut, "Line %d: argument_list : \n\n%s\n\n", line_count, toStringArguments($$).c_str());
                        }
                    ;

arguments           :   arguments COMMA logic_expression {
                                $$ = new vector<SymbolInfo*>($1->begin(), $1->end());
                                $$->push_back($3);
                                fprintf(logOut, "Line %d: arguments : arguments COMMA logic_expression\n\n%s\n\n", line_count, toStringArguments($$).c_str());
                        }
                    |   logic_expression {
                                $$ = new vector<SymbolInfo*>();
                                $$->push_back($1);
                                fprintf(logOut, "Line %d: arguments : logic_expression\n\n%s\n\n", line_count, toStringArguments($$).c_str());
                        }
                    ;


%%

int main(int argc,char *argv[])
{
	if((inputFile=fopen(argv[1],"r"))==NULL)
	{
		printf("Cannot Open Input File.\n");
		exit(1);
	}

	logOut = fopen("1805111_log.txt","w");
	errorOut = fopen("1805111_error.txt","w");
	
	yyin=inputFile;
	yyparse();

        table.print(logOut);

	fprintf(logOut,"Total lines: %d\n",line_count);
	fprintf(logOut,"Total errors: %d\n",error_count);

	fclose(logOut);
	fclose(errorOut);
	
	return 0;
}