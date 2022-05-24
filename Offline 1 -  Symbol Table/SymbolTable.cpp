#include<bits/stdc++.h>
#include "ScopeTable.cpp"


using namespace std;

class SymbolTable{
    ScopeTable * curScopeTable;
    stack<ScopeTable *> scopeTables;
public:

    SymbolTable(int totalBuckets){
        curScopeTable = new ScopeTable(totalBuckets);
        scopeTables.push(curScopeTable);
    }
    void printCurrentScopeTable(){
        scopeTables.top()->print();
    }

    void print(){
        ScopeTable * cur = curScopeTable;
        while(cur){
            cur->print();
            cur = cur->getParentScope();
            cout << endl;
        }
    }

    void enterScope(){
        ScopeTable * newScopeTable= new ScopeTable(curScopeTable);
        curScopeTable = newScopeTable;
        scopeTables.push(newScopeTable);
    }

    void exitScope(){
        ScopeTable * removed = curScopeTable;
        cout << "ScopeTable with id " << removed->getScopeId() << " removed\n\n";
        
        scopeTables.pop();
        delete removed;
        curScopeTable = this->scopeTables.top();
        curScopeTable->childScopeExitted();
        
    }

    bool insert(string name, string type){
        return insert(new SymbolInfo(name, type));
    }

    bool insert(SymbolInfo * newSymbol){
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