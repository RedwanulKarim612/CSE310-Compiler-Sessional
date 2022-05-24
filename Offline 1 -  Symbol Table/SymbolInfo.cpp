#include<bits/stdc++.h>

using namespace std;

class SymbolInfo{
    string name;
    string type;
    SymbolInfo * nextSymbol;

public:

    SymbolInfo(string name, string type){
        this->name = name;
        this->type = type;
        this->nextSymbol = NULL;
    }

    SymbolInfo(SymbolInfo *symbol){
        SymbolInfo(symbol->getName(), symbol->getType());
    }

    void setName(string name){
        this->name = name;
    }

    string getName(){
        return this->name;
    }

    void setType(string type){
        this->type = type;
    }

    string getType(){
        return this->type;
    }

    SymbolInfo * getNextSymbol(){
        return this->nextSymbol;
    }

    void setNextSymbol(SymbolInfo * nextSymbol){
        if(nextSymbol==NULL) this->nextSymbol = NULL;
        else this->nextSymbol = new SymbolInfo(nextSymbol->getName(), nextSymbol->getType());
    }

    ~SymbolInfo(){
        // cout << this->name << " destroyed\n\n";
        delete(nextSymbol);
    }

};
