#include<bits/stdc++.h>

using namespace std;

class SymbolInfo{
    string name;
    string type;
    SymbolInfo * nextSymbol;
    bool isFunc;
    bool isArray;
    int arrSize;
    string returnType;


public:
    SymbolInfo(){

    }

    SymbolInfo(string name, string type){
        this->name = name;
        this->type = type;
        this->nextSymbol = NULL;
        isFunc = false;
        isArray = false;
        arrSize = -1;
        returnType = "";
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

    void setArraySize(int x){
        this->isArray = true;
        this->arrSize = x;
    }

    bool getIsArray(){
        return this->isArray;
    }

    ~SymbolInfo(){          
        delete nextSymbol;
    }

};
