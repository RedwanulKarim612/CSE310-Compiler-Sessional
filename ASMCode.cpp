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
        string tmp = "PRINTLN PROC\n";
        tmp+="PUSH AX\n";
        tmp+="PUSH DX\n";
        tmp+="MOV AH, 2\n";
        tmp+="MOV DL, 0Dh\n";
        tmp+="INT 21h\n";
        tmp+="MOV DL, 0Ah\n";
        tmp+="INT 21h\n";
        tmp+="POP DX\n";
        tmp+="POP AX\n";
        tmp+="RET\n";
        tmp+="PRINTLN ENDP\n";
        return tmp;
    }
};

