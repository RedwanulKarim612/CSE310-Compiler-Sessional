#include<bits/stdc++.h>
#include "SymbolTable.cpp"
using namespace std;

int main(){

    SymbolTable * symbolTable;
    
    ifstream file ;
    file.open("input_2.txt", ios::in);

    int n;
    file >> n;
    symbolTable = new SymbolTable(n);

    char ch;
    while(file >> ch){

        if(ch=='I'){
            string name, type;
            file >> name >> type;
            cout << ch << " " << name << " " << type << "\n\n";
            symbolTable->insert(name, type);
        }
        

        else if(ch=='S'){
            cout << ch << "\n\n";
            symbolTable->enterScope();
        }
        else if(ch=='E'){

            cout << ch << "\n\n";
            symbolTable->exitScope();
        }
        else if(ch=='L'){
            string name;
            file >> name;

            cout << ch << " " << name << "\n\n";
            symbolTable->lookup(name);
        }
        else if(ch == 'D'){
            string name;
            file >> name;

            cout << ch << " " << name << "\n\n";
            symbolTable->remove(name);
        }
        else if(ch=='P'){
            char f;
            file >> f;
            cout << ch << " " << f << "\n\n";
            if(f=='C') {symbolTable->printCurrentScopeTable();}
            else if(f=='A') {symbolTable->print();}
        }
    }
    return 0;
}