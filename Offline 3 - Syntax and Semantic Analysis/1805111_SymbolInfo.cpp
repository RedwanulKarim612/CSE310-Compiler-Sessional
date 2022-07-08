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
        if(nextSymbol==NULL) {
            // cout << nextSymbol->name << "  is null\n";
            this->nextSymbol = NULL;
        }
        else {
            this->nextSymbol = new SymbolInfo();
            this->nextSymbol = nextSymbol;
            for(int i=0;i<nextSymbol->parameterTypes.size();i++)
                this->nextSymbol->parameterTypes[i] = nextSymbol->parameterTypes[i];
            // this->nextSymbol->dataType = nextSymbol->dataType;
            // this->nextSymbol->isFunc = nextSymbol->isFunc;
            // this->nextSymbol->isFuncDefined = nextSymbol->isFuncDefined;
            // this->nextSymbol->isArray = nextSymbol->isArray;
            // this->nextSymbol->arrSize = nextSymbol->arrSize;
            // this->nextSymbol->returnType = nextSymbol->returnType;
            // for(int i=0;i<nextSymbol->parameterTypes.size();i++){
            //     this->nextSymbol->parameterTypes[i] = nextSymbol->parameterTypes[i];
            // }
            // cout << "next symbol " <<nextSymbol->name << " " << this->nextSymbol->parameterTypes[0] << endl;
        }
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
            this->parameterTypes.push_back(params->at(i)->getDataType());

            // cout << this->name << " setting parametes " << parameterTypes.back() << endl;
        }
        
    }

    int getNumberOfParameters(){
        return this->parameterTypes.size();
    }

    string getithParameter(int i){
        return this->parameterTypes[i];
    }

    void setReturnType(string returnType){
        this->isFunc = true;
        this->returnType = returnType;
    }

    string getReturnType(){
        return this->returnType;
    }

    bool matchParamList(vector<SymbolInfo*>* params){
        // cout << "pp\n" ;
        // for(int i=0;i<this->parameterTypes.size();i++){
        //     cout << parameterTypes[i] << endl;
        // }

        if(params->size()!=this->parameterTypes.size()) return false;
        for(int i=0;i<this->parameterTypes.size();i++){
            if(this->parameterTypes[i]!=params->at(i)->getDataType())
                return false;
        }
        return true;
    }

    bool matchReturnType(string name){
        return name == this->returnType;
    }

    void setIsFunc(){
        this->isFunc = true;
    }

    void setDefined(){
        this->isFunc = true;
        this->isFuncDefined = true;
    }

    bool getDefined(){
        return this->isFuncDefined;
    }

    string getDataType(){
        return this->dataType;
    }

    void setDataType(string dataType){
        this->dataType = dataType;
    }

    void clone(SymbolInfo* symbol){
        this->name = symbol->name;
        this->type = symbol->type;
        this->dataType = symbol->dataType;
        this->isFunc = symbol->isFunc;
        this->isFuncDefined = symbol->isFuncDefined;
        this->returnType = symbol->returnType;
        this->isArray = symbol->isArray;
        this->arrSize = symbol->arrSize;
        for(int i=0;i<symbol->parameterTypes.size();i++)
            this->parameterTypes.push_back(symbol->parameterTypes[i]);
    }

};
