#include<bits/stdc++.h>
#include "SymbolInfo.cpp"

using namespace std;

class ScopeTable{
    string scopeId;
    int totalBuckets;
    int scopesDeleted;
    ScopeTable * parentScope;
    SymbolInfo ** hashTable;

public:
    ScopeTable(int totalBuckets){
        this->totalBuckets = totalBuckets;
        hashTable = new SymbolInfo * [this->totalBuckets];
        for(int i=0;i<this->totalBuckets;i++)
            this->hashTable[i] = NULL;
        if(this->parentScope!=NULL){
            string id = "";
            id += this->parentScope->getScopeId();
            id += ".";
            id += parentScope->getScopesDeleted();
            id += to_string(parentScope->getScopesDeleted() + 1) ;
            this->scopeId = id;

            cout << "New ScopeTable with id " << this->scopeId << " created\n\n";
        }
        else this->scopeId = "1";
        this->scopesDeleted = 0;

    }

    ScopeTable(ScopeTable * parentScope){
        this->parentScope = parentScope;
        new (this) ScopeTable(this->parentScope->getTotalBuckets());
    }


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

    unsigned long long sdbm(string str){
        unsigned long long hash = 0;
        int c;

        int i = 0;
        while (c=str[i++]){
            hash = c % totalBuckets + (hash << 6) % totalBuckets + (hash << 16)%totalBuckets - hash%totalBuckets;
            hash+=totalBuckets;
            hash=hash%totalBuckets;
            // i++;
        }
        // cout << "HASH   "<<str << " " << hash << "\n\n\n";
        return hash%totalBuckets;
    }

    bool insert(SymbolInfo *symbol){
        if(lookup(symbol->getName())){
            cout << "<" << symbol->getName() << ", " << symbol->getType() << "> already exists in current ScopeTable\n\n";
            return false; 
        }
        int hashIndex = (sdbm(symbol->getName()))%this->totalBuckets;
        SymbolInfo *curSymbol = this->hashTable[hashIndex];
        int cnt = 1;
        if(curSymbol==NULL){
            this->hashTable[hashIndex] = new SymbolInfo(symbol->getName(), symbol->getType());
            cnt = 0;
        }
        else{
            while(curSymbol->getNextSymbol()!=NULL){
                cnt++;
                if(curSymbol->getName()==symbol->getName()){
                    return false;
                }    
                curSymbol = curSymbol->getNextSymbol();
            }

            curSymbol->setNextSymbol(symbol);
        }
        cout << "Inserted in ScopeTable# " << this->scopeId << " at position " << hashIndex << ", " << cnt << "\n\n";
        return true;
    }

    SymbolInfo * lookup(string symbolName){
        int hashIndex = (sdbm(symbolName))%this->totalBuckets;
        SymbolInfo *curSymbol = this->hashTable[hashIndex];
        int cnt = 0;
        while(curSymbol!=NULL){
            if(curSymbol->getName()==symbolName) {
                cout << "Found in ScopeTable# " << this->scopeId << " at position " << hashIndex << ", " << cnt << endl << endl;
                return curSymbol;
            }
            cnt++;
            curSymbol = curSymbol->getNextSymbol();
        }
        // cout << "Not found\n\n";
        return NULL;
    }

    bool deleteSymbol(string symbolName){
        SymbolInfo * symbol = this->lookup(symbolName);
        if(symbol==NULL) {
            cout << symbolName << " not found\n\n";
            return false;
        }
        int hashIndex = (sdbm(symbolName))%this->totalBuckets;
        int cnt = 1;
        if(this->hashTable[hashIndex]->getName() == symbolName){
            cnt = 0; 
            this->hashTable[hashIndex] = this->hashTable[hashIndex]->getNextSymbol();
        }
        else{
            SymbolInfo * curSymbol = this->hashTable[hashIndex];
            while(curSymbol->getNextSymbol()!=NULL){
                if(curSymbol->getNextSymbol()->getName()==symbolName){
                    SymbolInfo * toDelete;
                    toDelete = curSymbol->getNextSymbol();
                    curSymbol->setNextSymbol(toDelete->getNextSymbol());
                    delete(toDelete);
                    break;
                }
                cnt++;
                curSymbol = curSymbol->getNextSymbol();
            }
        }

        cout << "Deleted " << hashIndex << " " << cnt << " from current ScopeTable\n\n";
        return true;
    }

    void childScopeExitted(){
        this->scopesDeleted++;
    }

    void print(){
        cout << "ScopeTable# " << this->scopeId << endl ;
        for(int i=0;i<this->totalBuckets;i++){
            SymbolInfo *curSymbol  = this->hashTable[i];
            cout << i << " -->   ";
            
            while(curSymbol!=NULL){
                cout << "< " << curSymbol->getName() << " : " << curSymbol->getType() << " >   ";
                curSymbol = curSymbol->getNextSymbol();
            }
            cout << "\n";
        }
        cout << "\n";
    }

    ~ ScopeTable(){
        // cout << "destructor scopetable # " << this->scopeId << endl;
        for(int i=0;i<this->totalBuckets;i++){
            delete this->hashTable[i];
        }
        delete [] hashTable;
    }


};

