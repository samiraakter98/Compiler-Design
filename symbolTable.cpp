#include<iostream>
#include <random>
#include <fstream>
#include<cstring>
#include<string>
#include<cmath>
#include<bits/stdc++.h>
using namespace std;
//ofstream logout("log.txt", std::ios_base::out);
class Function_property
{
    int parameter_number=0;
    vector < pair<string,string>> para_list;
    string return_type="";
public:
    Function_property(){};
    Function_property(string return_type, int parameter_number)
    {
        this->return_type=return_type;
        this->parameter_number = parameter_number;
    }
    Function_property(string return_type, int parameter_number, vector < pair<string,string>> para_list)
    {
        this->return_type=return_type;
        this->parameter_number = parameter_number;
        this->para_list = para_list;
    }
    //void set_returnType(string return_type){this->return_type=return_type;}
    //void set_parameter_number( int parameter_number){this->parameter_number = parameter_number;}
    //void set_parameter(string para_type, string para_id){ para_list.push_back(make_pair(para_type,para_id));}
    string get_returnType(){return return_type;}
    int get_parameterNumber(){return parameter_number;}
    vector < pair<string,string>> get_paraList(){return para_list;}

};
class SymbolInfo
{
    string name;
    string type;
    string dataType;
    string array_var;
    string temp;
    string symbol;
    bool check_array=false;
    bool check_function = false;
    bool check_function_declaration=false;
    bool check_function_definition = false;
    Function_property *Function;
public:
    string code="";
    int val=0;
    SymbolInfo(){};
    SymbolInfo(string name, string type)
    {
        this->name=name;
        this->type=type;
    }
    void set_array_var(string var){this->array_var=var;}
    string get_array_var(){return array_var;}
    void set_temp(string temp){this->temp=temp;}
    string get_temp(){return this->temp;}
    void set_symbol(string symbol){this->symbol=symbol;}
    string get_symbol(){return this->symbol;}
    void set_name(string name){this->name = name;}
    void set_type(string type){this->type = type;}
    void set_dataType(string datatype){this->dataType = datatype;}
    void set_arrayOrNot(bool check){check_array = check;}
    void set_functionOrNot(bool check){check_function = check;}
    void set_functionDeclarationOrNot(bool check){check_function_declaration = check;}
    void set_functionDefinedOrNot(bool check){check_function_definition = check;}
    void set_funtionProperties_with_parameter_list(string return_type,int para_number, vector < pair<string,string>> para_List)
    {
        this->Function =new Function_property(return_type, para_number, para_List);
    }
    void set_funtionProperties_without_parameter_list(string return_type,int para_number)
    {
        this->Function =new Function_property(return_type, para_number);
    }
    string get_name(){return name;}
    string get_type(){return type;}
    string get_dataType(){return dataType;}
    bool get_arrayOrNot(){return check_array;}
    bool get_functionOrNot(){return check_function;}
    bool get_functionDeclarationOrNot(){return check_function_declaration;}
    bool get_functionDefinedOrNot(){return check_function_definition;}
    Function_property *get_function(){return Function;}
};


class  ScopeTable
{
    string id ;
    int bucket_size;
    ScopeTable *parentScope;
    int child;
    vector < vector <SymbolInfo*> > hashtable;
public:
    ScopeTable(){}
    ScopeTable(int n)
    {
        this->bucket_size = n;
        child = 0;
        this->id= "";
        hashtable.resize(bucket_size);
        parentScope = new ScopeTable();
    }
    ~ScopeTable()
    {
        for(int i=0; i<hashtable.size();i++)
    {
        for(int j=0; j<hashtable[i].size();j++)
        {
            delete hashtable[i][j];
        }
    }
    delete parentScope;
    }
    int hashFunction(string s, int total_bucket)
    {
        int sum_ascii = 0;
        for(int i=0; i<s.size(); i++)
        {
            sum_ascii = sum_ascii + s[i];
            sum_ascii = sum_ascii % total_bucket;
        }

        return sum_ascii;
    }
    void set_parent(ScopeTable *parent)
    {
        this->parentScope = parent;
    }
    ScopeTable* get_parent()
    {
        return parentScope;
    }
    void set_child()
    {
         child = child+1;
    }
    string get_child()
    {
        return to_string(child);
    }
    void set_id(string id)
    {
        this->id = id;
    }
    string get_id()
    {
         return id;
    }
    int Search(string symbol, int hash_index)
    {
        for(int i = 0; i < hashtable[hash_index].size(); i++)
        {
            if(hashtable[hash_index].at(i)->get_name() == symbol)
                return i;
        }
        return -1;
    }

    bool Insert(string name, string type, string datatype)
    {
        int index = hashFunction(name, bucket_size);
        int check = Search(name, index);
        if(check == -1)
        {
            SymbolInfo *si = new SymbolInfo();
            si->set_name(name);
            si->set_type(type);
            si->set_dataType(datatype);
            hashtable[index].push_back(si);
            int i = Search(name,index);
            //logout<<"Inserted in ScopeTable# "<<id<<" at position "<<index<<", "<<i<<endl<<endl;
            return true;
        }
        else
        {
            return false;
        }
    }
    SymbolInfo* Lookup(string symbol)
    {
        for(int i = 0; i < hashtable.size(); i++)
        {
            for(int j =0; j<hashtable[i].size(); j++)
            {
                if(hashtable[i].at(j)->get_name() == symbol)
                {
                    return hashtable[i].at(j);
                }

            }

        }
        return NULL;
    }
    bool Delete(string symbol)
    {
        int hash_index = hashFunction(symbol, bucket_size);
        int i = Search(symbol, hash_index);
        if(i != -1)
        {
            return true;


        }
        else
        {
            return false;
        }
    }
    void print(ofstream &logout)
    {
        //ofstream logout;
        //logout.open("log.txt",std::ios_base::app);
        logout<<"ScopeTable # "<<id<<endl;
        //cout<<"samira";
        for(int i = 0; i < hashtable.size(); i++)
        {

            if(hashtable[i].size() == 0)
                continue;
            logout<<" "<<i<<" -->";
            for(int j =0; j<hashtable[i].size(); j++)
            {
                string name = hashtable[i].at(j)->get_name();
                string type = hashtable[i].at(j)->get_type();
                logout<<" < "<<name<<" , "<<type<<" >";

            }
            logout<<endl;
        }
        logout<<endl;
    }
};
class SymbolTable
{
    int hash_table_size;
    ScopeTable *scopeTab;

public:
    SymbolTable(int n)
    {
        this->hash_table_size = n;
        scopeTab = new ScopeTable(n);
        scopeTab->set_parent(NULL);
        scopeTab->set_id("1");
    }
    ~SymbolTable()
    {
        delete scopeTab;
    }
    void Enter_Scope()
    {
        ScopeTable *new_scope = new ScopeTable(hash_table_size);
        new_scope->set_parent(scopeTab);
        if(new_scope->get_parent() == NULL)
        {

            string id = scopeTab->get_id();
            int to_int_id = stoi(id);
            to_int_id++;
            new_scope->set_id(to_string(to_int_id));

        }
        else
        {
            scopeTab->set_child();
            string id = scopeTab->get_id() + "."+ scopeTab->get_child();
            new_scope->set_id(id);
        }
        scopeTab = new_scope ;
    }
    string get_id()
    {
         return scopeTab->get_id(); 
    }
    void Exit_scope()
    {
        scopeTab = scopeTab->get_parent();
    }
    bool Insert(string name, string type,string datatype)
    {
        bool check = scopeTab->Insert(name,type,datatype);
        if(check)
            {
                //print_all();
            }
        else
            {
                //logout<<symbol<<" already exists in current ScopeTable\n"<<endl;
        }
        return check;
    }
    bool Remove(string symbol)
    {
        bool check = scopeTab->Delete(symbol);
        return check;
    }
    SymbolInfo* Lookup(string symbol)
    {
        ScopeTable *temp = new ScopeTable();
        temp = scopeTab;
        SymbolInfo *info = new SymbolInfo();
        while(temp != NULL)
        {
            info = temp->Lookup(symbol);
           if( info != NULL)
           {
               return info;
           }

           temp = temp->get_parent();
        }
        return NULL;
    }
    void print_current(ofstream &logout)
    {
        scopeTab->print(logout);
    }
    void print_all(ofstream &logout)
    {
        ScopeTable *temp = new ScopeTable(hash_table_size);
        temp = scopeTab;
        while(temp!= NULL)
        {
            temp->print(logout);
            temp = temp->get_parent();
        }
    }
};
