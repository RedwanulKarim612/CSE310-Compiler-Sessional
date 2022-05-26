#include<bits/stdc++.h>
#include "ScopeTable.cpp"


using namespace std;

class SymbolTable{
    ScopeTable * curScopeTable;
    int totalBuckets;
public:

    SymbolTable(int totalBuckets){
        curScopeTable = new ScopeTable(totalBuckets,NULL);
        this->totalBuckets = totalBuckets;
    }
    void printCurrentScopeTable(){
        if(curScopeTable)curScopeTable->print();
        else cout << "No current scope\n\n";
    }

    void print(){
        if(curScopeTable){
        ScopeTable * cur = curScopeTable;
            while(cur){
                cur->print();
                cur = cur->getParentScope();
                cout << endl;
            }
        }
        else{
            cout << "No current scope\n\n";
        }
    }

    void enterScope(){
        ScopeTable * newScopeTable= new ScopeTable(totalBuckets, curScopeTable);
        curScopeTable = newScopeTable;
        
    }

    void exitScope(){
        if(curScopeTable){
            ScopeTable * removed = curScopeTable;
            curScopeTable = curScopeTable->getParentScope();
            cout << "ScopeTable with id " << removed->getScopeId() << " removed\n\n";
            if(curScopeTable){
                curScopeTable->childScopeExitted();
            }
            delete removed;
        }

        else{
            cout << "No current scope\n\n";
        }
        
    }

    bool insert(string name, string type){
        return insert(new SymbolInfo(name, type));
    }

    bool insert(SymbolInfo * newSymbol){
        if(this->curScopeTable==nullptr){
            this->curScopeTable = new ScopeTable(this->totalBuckets, curScopeTable);
        }
        return this->curScopeTable->insert(newSymbol);
    }

    bool remove(string name){
        if(curScopeTable)
            return curScopeTable->deleteSymbol(name);
        else {
            cout << "No current scope\n";
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
        cout << "Not Found\n\n";
        return NULL;
    }

    ~ SymbolTable(){
        delete curScopeTable;
    }

};