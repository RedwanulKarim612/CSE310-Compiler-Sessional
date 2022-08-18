#include<bits/stdc++.h>
#include "1805111_SymbolTable.cpp"

using namespace std;

class ASMCode{
    string initialSegment = ".MODEL SMALL\n.STACK 100H\n";
    string dataSegment = "\n.DATA\n";
    string procedure = "";
public:
    
    string getDataSegment(){
        return this->dataSegment;
    }

    void addVariable(SymbolInfo* symbol){
        string tmp=symbol->getName();
        if(symbol->getIsArray()){
            tmp +=" DW " + to_string(symbol->getArraySize()) + " DUP(0)\n";
        }
        else tmp+=" DW 0\n";
        dataSegment+=tmp;
    }

    string getInitCode(){
        return initialSegment + dataSegment;
    }

    string printlnFunc(){
        FILE * printlnFile = fopen("println.txt", "r");
        char c;
        string tmp = "";
        while(( c=fgetc(printlnFile))!=EOF){
            tmp+=c;
        }
        return tmp;
    }

    void optimize(FILE * codeFile){
        FILE * optimizedCodeFile = fopen("optimizedCode.asm", "w");

    }
};

