#include<bits/stdc++.h>
#include "ScopeTable.cpp"


using namespace std;

class SymbolTable{
    ScopeTable * curScopeTable;
    stack<ScopeTable *> scopeTables;
    int totalBuckets;
public:

    SymbolTable(int totalBuckets){
        curScopeTable = new ScopeTable(totalBuckets);
        scopeTables.push(curScopeTable);
        this->totalBuckets = totalBuckets;
    }
    void printCurrentScopeTable(){
        if(!this->scopeTables.empty())scopeTables.top()->print();
    }

    void print(){
        if(!this->scopeTables.empty()){
        ScopeTable * cur = curScopeTable;
            while(cur){
                cur->print();
                cur = cur->getParentScope();
                cout << endl;
            }
        }
    }

    void enterScope(){
        if(this->scopeTables.empty()){
            curScopeTable = new ScopeTable(this->totalBuckets);
            this->scopeTables.push(curScopeTable);
        }
        else{
            ScopeTable * newScopeTable= new ScopeTable(curScopeTable);
            curScopeTable = newScopeTable;
            scopeTables.push(newScopeTable);
        }
    }

    void exitScope(){
        if(!this->scopeTables.empty()){
            ScopeTable * removed = curScopeTable;
            cout << "ScopeTable with id " << removed->getScopeId() << " removed\n\n";
            scopeTables.pop();
            if(!this->scopeTables.empty()){
                curScopeTable = this->scopeTables.top();
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
        if(this->scopeTables.empty()){
            curScopeTable = new ScopeTable(this->totalBuckets);
            this->scopeTables.push(curScopeTable);
        }
        return curScopeTable->insert(newSymbol);
    }

    bool remove(string name){
        return curScopeTable->deleteSymbol(name);
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

};