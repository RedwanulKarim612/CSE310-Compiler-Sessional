#include<bits/stdc++.h>
#include "1805111_ScopeTable.cpp"


using namespace std;

class SymbolTable{
    ScopeTable * curScopeTable;
    int totalBuckets;
public:
    SymbolTable(int totalBuckets){
        this->curScopeTable = new ScopeTable(totalBuckets,NULL);
        this->totalBuckets = totalBuckets;
    }
    // void printCurrentScopeTable(){
    //     if(curScopeTable)curScopeTable->print();
    // }

    void print(FILE * logout){
        if(curScopeTable){
        ScopeTable * cur = curScopeTable;
            while(cur){
                cur->print(logout);
                cur = cur->getParentScope();
                cout << endl;
            }
        }
        else{
            return ;
        }
    }

    void enterScope(){
        this->curScopeTable = new ScopeTable(this->totalBuckets, curScopeTable);
    }

    void exitScope(){
        ScopeTable * removed = curScopeTable;
        if(curScopeTable){
            curScopeTable = curScopeTable->getParentScope();
            if(curScopeTable){
                curScopeTable->childScopeExitted();
            }
        }

        else{
        }
        
        delete removed;
    }

    bool insert(string name, string type){
        SymbolInfo * symbol = new SymbolInfo(name, type);
        bool f =  this->insert(symbol);
        delete symbol;
        return f;
    }

    bool insert(SymbolInfo * newSymbol){
        // cout << newSymbol->getName() << " " << this->curScopeTable->getScopeId() << endl;
        if(!this->curScopeTable){
            this->curScopeTable = new ScopeTable(this->totalBuckets, curScopeTable);
        }
        return this->curScopeTable->insert(newSymbol);
    }

    bool remove(string name){
        if(curScopeTable)
            return curScopeTable->deleteSymbol(name);
        else {
            return false;
        }
    }

    SymbolInfo * lookup(string name){
        ScopeTable * cur = curScopeTable;
        while(cur!=NULL){
            // cout << cur->getScopeId() << " " << cur->getParentScope()->getScopeId() << endl;
            SymbolInfo * symbol = cur->lookup(name);
            // cout << cur->getScopeId() << " " << cur->getParentScope()->getScopeId() << endl;
            if(symbol!=NULL) {
                return symbol;
            }
            cur = cur->getParentScope();
            // cout << cur->getScopeId() << endl;
        }
        return NULL;
    }

    SymbolInfo * lookupCurrentScopeTable(string name){
        return curScopeTable->lookup(name);
    }

    ~ SymbolTable(){
        this->totalBuckets = -1;
        while(this->curScopeTable){
            ScopeTable *parent = this->curScopeTable->getParentScope();
            delete this->curScopeTable;
            this->curScopeTable = parent;
        }
    }

    bool isGlobalScope(){
        return this->curScopeTable->getScopeId()=="1";
    }

    string getCurrentScopeTableId(){
        return this->curScopeTable->getScopeId();
    }

};

