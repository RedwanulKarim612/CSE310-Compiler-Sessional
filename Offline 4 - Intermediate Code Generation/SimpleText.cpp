#include<bits/stdc++.h>

using namespace std;

class SimpleText{
    string text;
public:
    SimpleText(){
        this->text = "";
    }

    SimpleText(string text){
        this->text = text;
    }

    string getText(){
        return this->text;
    }

    void setText(string text){
        this->text = text;
    }

    void appendText(string str){
        this->text+=str;
    }

};