#include<bits/stdc++.h>
#include "1805111_SymbolInfo.cpp"

using namespace std;

class ScopeTable{
    string scopeId;
    int totalBuckets;
    int scopesDeleted;
    ScopeTable * parentScope;
    SymbolInfo ** hashTable;

public:
    ScopeTable(int totalBuckets, ScopeTable * parentScope){
        this->totalBuckets = totalBuckets;
        hashTable = new SymbolInfo * [this->totalBuckets];
        for(int i=0;i<this->totalBuckets;i++)
            this->hashTable[i] = NULL;
        this->parentScope = parentScope;
        if(this->parentScope!=NULL){
            string id = "";
            id += this->parentScope->getScopeId();
            id += ".";
            id += to_string(parentScope->getScopesDeleted() + 1) ;
            this->scopeId = id;
        }
        else {
            this->scopeId = "1";
        }
        this->scopesDeleted = 0;
    }

    // ScopeTable(ScopeTable * parentScope){
    //     this->parentScope = parentScope;
    //     new (this) ScopeTable(this->parentScope->getTotalBuckets());
    // }


    string getScopeId(){
        return this->scopeId;
    }

    int getTotalBuckets(){
        return this->totalBuckets;
    }

    int getScopesDeleted(){
        return this->scopesDeleted;
    }

    ScopeTable * getParentScope(){
        return this->parentScope;
    }

    uint32_t sdbm(string str){
        uint32_t hash = 0;
        int c;

        int i = 0;
        while (c=str[i++]){
            hash = c  + (hash << 6)  + (hash << 16)- hash;
        }
        str.clear();
        return hash%totalBuckets;
    }

    bool insert(SymbolInfo *symbol){
        if(lookup(symbol->getName())){
            return false; 
        }
        int hashIndex = (sdbm(symbol->getName()))%this->totalBuckets;
        
        int cnt = 1;
        if(this->hashTable[hashIndex]==NULL){
            this->hashTable[hashIndex] = new SymbolInfo(symbol->getName(), symbol->getType());
            this->hashTable[hashIndex]->clone(symbol);
            cnt = 0;
        }
        else{
            SymbolInfo *curSymbol = this->hashTable[hashIndex];
            while(curSymbol->getNextSymbol()!=NULL){
                cnt++;
                if(curSymbol->getName()==symbol->getName()){
                    return false;
                }    
                curSymbol = curSymbol->getNextSymbol();
            }
            // cout << "inserted  " << symbol->getName() << " " << symbol->parameterTypes[0] << endl;

            curSymbol->setNextSymbol(symbol);            
        }
        return true;
    }

    SymbolInfo * lookup(string symbolName){
        int hashIndex = (sdbm(symbolName))%this->totalBuckets;
        SymbolInfo *curSymbol = this->hashTable[hashIndex];
        int cnt = 0;
        while(curSymbol!=NULL){
            if(curSymbol->getName()==symbolName) {
                return curSymbol;
            }
            cnt++;
            curSymbol = curSymbol->getNextSymbol();
        }
        return NULL;
    }

    bool deleteSymbol(string symbolName){
        SymbolInfo * symbol = this->lookup(symbolName);
        if(symbol==NULL) {
            delete symbol;
            return false;
        }
        int hashIndex = (sdbm(symbolName))%this->totalBuckets;
        int cnt = 1;
        if(this->hashTable[hashIndex]->getName() == symbolName){
            cnt = 0; 
            SymbolInfo *newSymbol =  this->hashTable[hashIndex]->getNextSymbol();
            
        }
        else{
            SymbolInfo * curSymbol = this->hashTable[hashIndex];
            while(curSymbol->getNextSymbol()!=NULL){
                if(curSymbol->getNextSymbol()->getName()==symbolName){
                    SymbolInfo * toDelete = curSymbol->getNextSymbol();
                    curSymbol->setNextSymbol(toDelete->getNextSymbol());
                    delete toDelete;
                    break;
                }
                cnt++;
                curSymbol = curSymbol->getNextSymbol();
            }
        }


        return true;
    }

    void childScopeExitted(){
        this->scopesDeleted++;
    }

    void print(FILE *logout){
        fprintf(logout, "ScopeTable # %s\n", scopeId.c_str());
        for(int i=0;i<this->totalBuckets;i++){
            SymbolInfo *curSymbol  = this->hashTable[i];
            if(curSymbol==NULL) continue;
            fprintf(logout, " %d --> ", i);
            while(curSymbol!=NULL){
                fprintf(logout, "<%s : %s> ", curSymbol->getName().c_str(), curSymbol->getType().c_str());
                curSymbol = curSymbol->getNextSymbol();
            }
            fprintf(logout, "\n");
        }
        fprintf(logout, "\n");
    }

    ~ ScopeTable(){
        for(int i=0;i<this->totalBuckets;i++){
            SymbolInfo *cur = this->hashTable[i];
            delete cur;
        }
        delete [] hashTable;
    }
};

