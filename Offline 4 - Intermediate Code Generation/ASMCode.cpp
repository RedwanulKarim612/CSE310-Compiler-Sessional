#include<bits/stdc++.h>
#include "1805111_SymbolTable.cpp"

using namespace std;

class ASMCode{
    string initialSegment = ".MODEL SMALL\n.STACK 100H\n";
    string dataSegment = "\n.DATA\n";
    string procedure = "";

    vector<string> prevLine, curLine;
    map<string, string> emptyLabels;
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
    void split(string str){
        curLine.clear();
        string tmp = "";
        for(int i=0;i<str.size()-1;i++){
            if(str[i]==';') break;
            else if(str[i]==' ' || str[i]==',' || str[i]=='\t'){
                if(tmp!="") curLine.push_back(tmp);
                tmp.clear();
            }
            else tmp+=str[i];
        }
        curLine.push_back(tmp);
    }
    void optimize(FILE * codeFile){
        FILE * optimizedCodeFile = fopen("optimizedCode.asm", "w");
        char * tmp = NULL;
        size_t len = 0;
        
        while(getline(&tmp, &len, codeFile)!=-1){
            string line = tmp;
            split(line);
            // for(int i=0;i<curLine.size();i++)
            //     cout << curLine[i] << " ";
            // cout << endl;
            if(curLine[0]=="MOV" && prevLine[0]=="MOV" ){
                if(curLine[1]==prevLine[2] && curLine[2]==prevLine[1])
                    line = "; peephole optimization " + line;
                else if(curLine[1]==prevLine[1] && curLine[2]==prevLine[2])
                    line = "; peephole optimization " + line;
            }
            if(curLine[0]=="MOV" && curLine[1]==curLine[2])
                line = "; peephole optimization " + line;
            if((curLine[0]=="ADD" || curLine[0]=="SUB") && curLine[2]=="0")
                line = "; peephole optimization " + line;
            if((curLine[0]=="IDIV" || curLine[0]=="IMUL") && curLine[1]=="1")
                line = "; peephole optimization " + line;
            fprintf(optimizedCodeFile, "%s", line.c_str());
            prevLine.clear();
            for(int i=0;i<curLine.size();i++){
                prevLine.push_back(curLine[i]);
            }
            curLine.clear();
        }
        fclose(optimizedCodeFile);
    }
};

