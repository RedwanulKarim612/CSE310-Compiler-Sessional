#include<bits/stdc++.h>

using namespace std;

class SymbolInfo{
    string name;
    string type;
    SymbolInfo * nextSymbol;
    bool isFunc;
    bool isFuncDefined;
    bool isArray;
    int arrSize;
    string returnType;
    string dataType;
    vector<string> parameterTypes;

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
        isFuncDefined = false;
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

    bool getIsFunc(){
        return this->isFunc;
    }

    bool getIsFuncDefined(){
        return this->isFuncDefined;
    }

    void setArraySize(int x){
        this->isArray = true;
        this->arrSize = x;
    }

    bool getIsArray(){
        return this->isArray;
    }

    int getArraySize(){
        return arrSize;
    }

    ~SymbolInfo(){          
        delete nextSymbol;
    }

    void setParameters(vector<SymbolInfo*>* params){
        for(int i=0;i<params->size();i++){
            this->parameterTypes.push_back(params->at(i)->getType());
        }
    }

    void setReturnType(string returnType){
        this->returnType = returnType;
    }

    string getReturnType(){
        return this->returnType;
    }

    bool matchParamList(vector<SymbolInfo*>* params){
        if(params->size()!=this->parameterTypes.size()) return false;
        for(int i=0;i<this->parameterTypes.size();i++){
            if(this->parameterTypes[i]!=params->at(i)->getType())
                return false;
        }
        return true;
    }

    bool matchReturnType(string name){
        return name == this->returnType;
    }

    void setDefined(){
        this->isFuncDefined = true;
    }

    string getDataType(){
        return this->dataType;
    }

    void setDataType(string dataType){
        this->dataType = dataType;
    }

};
