%{

#include<iostream>
#include<stdio.h>
#include<stdlib.h>
#include<bits/stdc++.h>
#include "1705028.cpp"
using namespace std;


//#define YYSTYPE SymbolInfo*
//#define YYSTYPE var1*
std::ofstream logout("log.txt", std::ios_base::out);
std::ofstream error("error.txt", std::ios_base::out);
int yyparse(void);
int yylex(void);
extern FILE *yyin;
extern int line_count;
extern char *yytext; 
extern vector <SymbolInfo*> vec;
SymbolTable table(30);
vector <SymbolInfo*> ids;

string datatype ="";
int parameterList_count=0;
int argument_count =0;
bool check_in_the_function=false;

extern string id;
vector < pair<string,string>> para_list;
vector <int> argument_error_number;

int errors=0;
int syntax_errors=0;
SymbolInfo *statement_string= new SymbolInfo();
//For Syntax error
int parameter_id_count=0;

//--------------------------assembly code generation-----------------
int labelCount=0;
int tempCount=0;

//FOR VARIBLE DECLARATION IN DATA SECTION
int var_number=-1;
string variable=".DATA\n";
vector < pair<string,string>> var_match;

///////------------FOR IF ELSE STATEMENT----------------
string var_ifElse1="";
string var_ifElse2="";
string labeltrack1;
string labeltrack2;
///////-----------FOR FUNCTION----------------
bool check_func=true;
string func_id;
string var_func1="";
bool check_temp_ret=true;
bool check_main=false;

///////-----------FOR FUNCTION CALLING------------
vector < pair<string,int> > func_var_track;
vector < vector<string> > asm_para_list;

///////-----------FOR FOR LOOP------------

int func_number;
void yyerror(char *s)
{
	error<<"Error at line "<<line_count<<": Syntax error"<<"\n"<<endl ;
	errors++;
}
string newLabel()//FOR LABEL
{
	string lb;
	lb="L"+to_string(labelCount);
	labelCount++;
	return lb;
}

string newTemp()//FOR VARIABLE
{
	string t;
	t="t"+to_string(tempCount);
	tempCount++;
	return t;
}

string print_func()
{
	string print = "PRINT PROC\n";
	print+="\t push bx\n";
	print+="\t push cx\n";
	print+="\t push dx\n";
	print+="\t mov cx, 0\n";
	print+="get_digit:\n";
	print+="\t cmp ax, 0\n";
	print+="\t je exit1\n";
	print+="\t mov bx,10\n";
	print+="\t mov dx, 0\n";///////find reason!!!!!!!
	print+="\t div bx\n";
	print+="\t push dx\n";
	print+="\t inc cx\n";
	print+="\t jmp get_digit\n";
	print+="exit1:\n";
	print+="print_digit:\n";
	print+="\t cmp cx,0\n";
	print+="\t je exit2\n";
	print+="\t pop dx\n";
	print+="\t add dx,30h\n";
	print+="\t mov ah,02\n";
	print+="\t int 21h\n";
	print+="\t dec cx\n";
	print+="\t jmp print_digit\n";
	print+="exit2:\n";
	
	///FOR PRINTING IN NEXT LINE
	print+="\t mov ah, 02\n";
        print+="\t mov dl, 0dh\n";
        print+="\t int 21h\n";
        print+="\t mov dl, 0ah\n";
        print+="\t int 21h\n";
        
	print+="\t pop dx\n";
	print+="\t pop cx\n";
	print+="\t pop bx\n";
	print+="\t ret \n";
	print+="PRINT endp\n";

	return print;
}
string optimized_code(string s)
{
	std::stringstream ss(s);
	std::string str="";
	std::string str1="";
	if (s!= "")
	{
	    
	    std::string to="";
	    while(std::getline(ss,to,'\n'))
	    {
	    	int j=0;
	    	int pos = to.find(';');
	    	
	    	 if(pos!=-1)
	    	 {
	    	 	string blah =to.substr(0, pos);
	    	 	str1+=blah+"\n";
	    	 }
	    	 else
	    		str1+=to+"\n";
	    	 
	    }
	    std::stringstream temp2(str1);
	    std::string to2="";
	    int i=1;
	    bool check_mov=false;
	    string prev1;
    	    string prev2;
    	    string pres1;
    	    string pres2;
    	    int flag=0;
    	    bool check_ret=false;
    	    while(std::getline(temp2,to2,'\n'))
    	    {
    	    	
    	 	 bool check_add_or_not=true;
    	 	 std::regex words_regex("[^\t\\s,]+");
		 auto words_begin = std::sregex_iterator(to2.begin(), to2.end(), words_regex);
		 auto words_end = std::sregex_iterator();
		 check_mov=false;
		 check_ret=false;
		 int j=0;
		  for (std::sregex_iterator k = words_begin; k != words_end; ++k)
		  {
		  	if(check_mov)
		  	{
		  		if(j==1) pres1=(*k).str();
		  		else pres2=(*k).str();
		  	}
		  	if((*k).str() == "mov")
		  	{
		  		check_mov=true;
		  	}
		  	if((*k).str() == "ret")
		  	{
		  		check_ret=true;
		  	}
		  	j++;
		  }
		   if(check_mov)
		   {
		   	
		   	if(pres1 == prev2 && pres2 == prev1 && i-flag == 1)
		   	{
		   		check_add_or_not=false;
		   		cout<<prev1<<" "<<prev2<<endl;
		   		cout<<pres1<<" "<<pres2<<endl<<endl;
		   		
		   	}
		   	flag=i;
		   	prev1=pres1;
		   	prev2=pres2;
		   	
		   }
		   if(check_add_or_not){	str+=to2+"\n";  }
		   //////-----eliminating unreachable instruction-------------
		   if(check_ret)
		   {
		   	 bool check_endp=false;
		   	 while(std::getline(temp2,to2,'\n'))
		   	 {
		   	 	int pos = to2.find(' ');
		   	 	if(pos!=-1)
		   	 	{
		   	 		string token =to2.substr(pos+1, to2.size());
		   	 		if(token == "endp") check_endp = true;
		   	 	}
		   	 	if(check_endp) 
		   	 	{
		   	 		str+=to2+"\n"; 
		   	 		break;
		   	 	}
		   	 }
		   }
    	 	 i++;
    	    }
    	    
    	    
	    
	}
	return str;
	

}
void var(string id)
{

	variable+="\t"+id+to_string(var_number)+" dw ?\n";
	
}
void var_array(string id, string n)
{
	variable+="\t"+id+to_string(var_number)+" dw "+n+" dup(?)\n";
}

%}
%union{ SymbolInfo* si;
	double dval;
	int ival;	
	}
%start start
%token DO DOUBLE CHAR BREAK SWITCH CASE DEFAULT CONTINUE  
%token INT SEMICOLON COMMA FLOAT VOID LPAREN RPAREN LTHIRD RTHIRD 
%token INCOP DECOP RETURN  LCURL  RCURL NOT ASSIGNOP
%token FOR IF ELSE WHILE PRINTLN
%token <si> ID CONST_INT CONST_FLOAT
%token <si> ADDOP MULOP RELOP LOGICOP 
%type <si> program start
%type <si> unit 
%type <si> func_declaration 
%type <si> func_definition
%type <si> parameter_list  
%type <si> compound_statement
%type <si> var_declaration
%type <si> type_specifier
%type <si> declaration_list
%type <si> statement 
%type <si> statements
%type <si> expression_statement
%type <si> variable 
%type <si> expression
%type <si> logic_expression 
%type <si> rel_expression	
%type <si> simple_expression 
%type <si> term 
%type <si> unary_expression 
%type <si> factor 	
%type <si> arguments
%type <si> argument_list 
%type <si> DUMMY_STATE //FOR ASSEMBLY CODE
//%left 
//%right

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE


%%

start : program
	{
	
		logout<<"Line "<<(line_count-1)<<": start : program\n\n";
		//logout<<$1->get_name()<<endl<<endl;
		table.print_all(logout);
		logout<<"Total lines: "<<line_count-1<<endl;
		logout<<"Total errors: "<<errors<<endl;
		error<<"Total errors: "<<errors<<endl;
		ofstream fout;
		fout.open("code.asm");
		ofstream fout2;
		fout2.open("optimized_code.asm");
		if(errors ==0)
		{
			
			fout<<".MODEL samll\n.STACK 100h\n";
			fout2<<".MODEL samll\n.STACK 100h\n";
			fout << variable;
			fout2 << variable;
			fout<<print_func();
			fout2<<print_func();
			$1->code+="MAIN endp\nend MAIN\n";
			$$=$1;
			fout<<$$->code;
			fout2<<optimized_code($$->code);	
		}
		
		
		
	}
	;

program : program unit {	logout<<"Line "<<line_count<<": program : program unit\n\n";
				$$->set_name($1->get_name()+"\n"+$2->get_name());
				logout<<$$->get_name()<<endl<<endl;
				//$$->code+=$1->code;
				$$->code+=$2->code;
			}
	| unit 	{	logout<<"Line "<<line_count<<": program : unit\n\n";
				$$->set_name($1->get_name());
				logout<<$1->get_name()<<endl<<endl;
				$$->code=$1->code;
			}
	;
	
unit : var_declaration
      {	logout<<"Line "<<line_count<<": unit : var_declaration\n\n";
		$$->set_name($1->get_name());
		logout<<$1->get_name()<<endl<<endl;
		$$->code=$1->code;
	}
      | func_declaration
      {		logout<<"Line "<<line_count<<": unit : func_declaration\n\n";
			$$->set_name($1->get_name());
			logout<<$$->get_name()<<endl<<endl;
			$$->code=$1->code;
      }
      | func_definition
      {		logout<<"Line "<<line_count<<": unit : func_definition\n\n";
			$$->set_name($1->get_name());
			$$->code=$1->code;
			logout<<$$->get_name()<<endl<<endl;
			
      }
     ;
     
func_declaration : type_specifier ID LPAREN parameter_list  RPAREN SEMICOLON
		  {
		  	bool check = table.Insert($2->get_name(),$2->get_type(), $2->get_dataType());
		  	if(check == false)
			 {	
			 	error<<"Error at line "<<line_count<<": Multiple declaration of "<<$2->get_name()<<"\n"<<endl ;
			 	logout<<"Error at line "<<line_count<<": Multiple declaration of "<<$2->get_name()<<"\n"<<endl ;
			 	errors++;
			 }
			 else
			 {
			 	SymbolInfo *temp = new  SymbolInfo();
	    			temp = table.Lookup($2->get_name());
	    			temp->set_dataType($2->get_dataType());
	    			temp->set_functionDeclarationOrNot(true);
	    			temp->set_functionOrNot(true);
	    			vector < pair<string,string>> parameter_list;
	    			for(int i=0; i < ids.size(); i++)
				{
					parameter_list.push_back(make_pair(ids[i]->get_dataType(), ids[i]->get_name()));
				}
				
	    			temp->set_funtionProperties_with_parameter_list($2->get_dataType(),parameterList_count,parameter_list);
	    			parameter_list.clear();
	    			parameterList_count=0;
	    			
	    			
			 }
		  	table.Enter_Scope();
		  	for(int i=0; i < ids.size(); i++)
			{
				table.Insert(ids[i]->get_name(),ids[i]->get_type(),ids[i]->get_dataType());
			}
	       	ids.clear();	
		  	table.Exit_scope();
			logout<<"Line "<<line_count<<": func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON\n\n";	
			$$= new SymbolInfo($1->get_name()+" "+$2->get_name()+"("+$4->get_name()+")"+";","");
			logout<<$$->get_name()<<endl<<endl;
		 }
		 | type_specifier ID LPAREN RPAREN SEMICOLON
		{
			bool check = table.Insert($2->get_name(),$2->get_type(), $2->get_dataType());
			if(check == false)
			 {	
			 	error<<"Error at line "<<line_count<<": Multiple declaration of "<<$2->get_name()<<"\n"<<endl ;
			 	logout<<"Error at line "<<line_count<<": Multiple declaration of "<<$2->get_name()<<"\n"<<endl ;
			 	errors++;
			 }
			 else
			 {
			 	SymbolInfo *temp = new  SymbolInfo();
	    			temp = table.Lookup($2->get_name());
	    			temp->set_dataType($2->get_dataType());
	    			temp->set_functionOrNot(true);
	    			temp->set_functionDeclarationOrNot(true);
	    			temp->set_funtionProperties_without_parameter_list($2->get_dataType(),parameterList_count);
	    			parameterList_count=0;
			 }
			table.Enter_Scope();
			table.Exit_scope();
			logout<<"Line "<<line_count<<": func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON\n\n";	
			$$= new SymbolInfo($1->get_name()+" "+$2->get_name()+"()"+";","");
			logout<<$$->get_name()<<endl<<endl;
		}	
		;
func_definition : type_specifier ID  LPAREN parameter_list RPAREN  DUMMY_STATE compound_statement
		 {
		 	
		 	table.print_all(logout);
		 	table.Exit_scope();
		 	
			logout<<"Line "<<line_count<<": func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement\n\n";	
			$$= new SymbolInfo($1->get_name()+" "+$2->get_name()+"("+$4->get_name()+")"+$7->get_name(),"");
			logout<<$$->get_name()<<endl<<endl;
			
			$$->code=var_func1;///////////--------------ASSEMBLY CODE---------------
			$$->code+="\t push bx\n";
			$$->code+="\t push cx\n";
			$$->code+="\t push dx\n";
			$$->code+=$7->code;
			
			$$->code+=func_id+" endp\n";
			
		}	
		| type_specifier ID  LPAREN  RPAREN DUMMY_STATE compound_statement
		{	
			
		 	table.print_all(logout);
		 	table.Exit_scope();
		 	
		 	SymbolInfo *temp1 = new  SymbolInfo();
    			temp1 = table.Lookup($2->get_name());
    			if(temp1 != NULL)
    			{
    				temp1->set_functionOrNot(true);
    				temp1->set_dataType($2->get_dataType());
    				temp1->set_funtionProperties_without_parameter_list($2->get_dataType(),parameterList_count);
    			}

			logout<<"Line "<<line_count<<": func_definition : type_specifier ID LPAREN RPAREN compound_statement\n\n";	
			$$= new SymbolInfo($1->get_name()+" "+$2->get_name()+"()"+$6->get_name(),"");
			logout<<$$->get_name()<<endl<<endl;
			
			
			if($2->get_name()== "main")///////////--------------ASSEMBLY CODE---------------
    			{
    				//ASSEMBLY CODE
	    			$$->code="MAIN PROC\n";
	    			$$->code+=";INITIALIZATION\n";
	    			$$->code+="\tmov ax,@data\n";
    				$$->code+="\tmov ds, ax \n";
    				$$->code+=$6->code;
    			}
    			else
    			{
    				$$->code=var_func1;
    				$$->code+="\t push bx\n";
				$$->code+="\t push cx\n";
				$$->code+="\t push dx\n";
				$$->code+=$6->code;
				$$->code+="\t pop dx\n";
				$$->code+="\t pop cx\n";
				$$->code+="\t pop bx\n";
	    			$$->code+=func_id+" endp\n";
    			}
	    		
		}
			
 		;	
DUMMY_STATE: {	
		check_in_the_function=true;
		SymbolInfo *temp= new SymbolInfo();
		
		temp = vec.back();
		func_id=temp->get_name();
		bool check = table.Insert(temp->get_name(),temp->get_type(), temp->get_dataType());
		if(check == false) //false means id exits in the symbol table
		 {	
		 	SymbolInfo *check = new  SymbolInfo();
	    		check = table.Lookup(temp->get_name());
		 	if(check->get_functionDeclarationOrNot() == true && check->get_functionDefinedOrNot() ==false)
		 	{
		 		Function_property *func = new Function_property();
		 		func = check->get_function();
		 		check->set_functionDefinedOrNot(true);
		 		if(temp->get_dataType() != check->get_dataType())
		 		{
		 			error<<"Error at line "<<line_count<<": Return type mismatch with function declaration in function "<<temp->get_name()<<"\n"<<endl ;
		 			logout<<"Error at line "<<line_count<<": Return type mismatch with function declaration in function "<<temp->get_name()<<"\n"<<endl ;
		 			errors++;
		 			check_func=false;
		 		}
		 		if(func->get_parameterNumber() != parameterList_count)
		 		{
		 			error<<func->get_parameterNumber()<<" "<<parameterList_count<<endl;
		 			error<<"Error at line "<<line_count<<": Total number of arguments mismatch with declaration in function "<<temp->get_name()<<"\n"<<endl ;
		 			logout<<"Error at line "<<line_count<<": Total number of arguments mismatch with declaration in function "<<temp->get_name()<<"\n"<<endl ;
		 			errors++;
		 			check_func=false;
		 		}
		 		if(func->get_parameterNumber() !=0)
		 		{
		 			vector < pair<string,string>> para_list;
		 			para_list = func->get_paraList();
		 			
	 				for(int i=0; i < ids.size(); i++)
					{
						if(ids[i]->get_dataType() != para_list[i].first)
						{
							error<<"Error at line "<<line_count<<": "<<i+1<<"th argument mismatch in function definition "<<temp->get_name()<<"\n"<<endl ;
				 			logout<<"Error at line "<<line_count<<": "<<i+1<<"th argument mismatch in function definition "<<temp->get_name()<<"\n"<<endl ;
				 			errors++;
				 			check_func=false;
						}
					}
	 			
		 		}
		 		
		 	}
		 	else
		 	{
		 		error<<"Error at line "<<line_count<<": Multiple declaration of "<<temp->get_name()<<"\n"<<endl ;
		 		logout<<"Error at line "<<line_count<<": Multiple declaration of "<<temp->get_name()<<"\n"<<endl ;
		 		errors++;
		 		check_func=false;
		 		
		 	}
		 	
		 	
		 }
		 else
		 {
		 	if(parameterList_count != 0)
		 	{
		 		SymbolInfo *temp1 = new  SymbolInfo();
	    			temp1 = table.Lookup(temp->get_name());
	    			temp1->set_functionOrNot(true);
	    			vector < pair<string,string>> parameter_list;
	    			for(int i=0; i < ids.size(); i++)
				{
					parameter_list.push_back(make_pair(ids[i]->get_dataType(), ids[i]->get_name()));
				}
	    			temp1->set_funtionProperties_with_parameter_list(temp->get_dataType(),parameterList_count,parameter_list);
	    			parameter_list.clear();
	    			
		 	}
		 	
		 }
			
       	parameterList_count=0;
	     }
  	    ;
TEMP_STATE : {	table.Enter_Scope();
		
		if(check_in_the_function == true)//----------CHECK ERROR HERE.BETWEEN FUNC{} AND {} 
		{
			var_number++;
			for(int i=0; i < ids.size(); i++)
			{
				table.Insert(ids[i]->get_name(),ids[i]->get_type(),ids[i]->get_dataType());
				
			}
			if(check_func)
			{
				if(func_id !="main" )
				{
					var_func1=func_id+" PROC\n";
					for(int i=0; i < ids.size(); i++)
					{
						 var(ids[i]->get_name());
						 //asm_para_list[var_number].push_back(ids[i]->get_name()+to_string(var_number));
						
					}	
				}
				if(check_func)
				{
					func_var_track.push_back(make_pair(func_id,var_number));
				}
				if(func_id == "main")
				{
					check_main=true;
				}
						
				
				
			}
	       	ids.clear();
	       	check_func=true;
	       	check_in_the_function=false;
	       	
		}
		
		
	     }
  	    ;
parameter_list  : parameter_list COMMA type_specifier ID
		{
			
			for(int i=0; i < ids.size(); i++)
			{
				if(ids[i]->get_name() == $4->get_name())
				{
					error<<"Error at line "<<line_count<<": Multiple declaration of "<<$4->get_name()<<" in parameter\n"<<endl ;
			 		logout<<"Error at line "<<line_count<<": Multiple declaration of "<<$4->get_name()<<" in parameter\n"<<endl ;
			 		errors++;
			 	}
			}
			parameterList_count++;
			ids.push_back($4);
			vec.pop_back();
 			logout<<"Line "<<line_count<<": parameter_list : parameter_list COMMA type_specifier ID\n\n";
			$$=new SymbolInfo($1->get_name()+","+$3->get_name()+" "+$4->get_name(),"");
			logout<<$$->get_name()<<endl<<endl;
		}
		| parameter_list COMMA type_specifier
		{
 			logout<<"Line "<<line_count<<": parameter_list : parameter_list COMMA type_specifier\n\n";
			$$=new SymbolInfo($1->get_name()+","+$3->get_name(),"");
			logout<<$$->get_name()<<endl<<endl;
		}
 		| type_specifier ID 
 		{
 			ids.push_back($2);
			vec.pop_back();
			parameterList_count++;
 			logout<<"Line "<<line_count<<": parameter_list : type_specifier ID\n\n";
			$$=new SymbolInfo($1->get_name()+" "+$2->get_name(),"");
			logout<<$$->get_name()<<endl<<endl;
		}
		
		| type_specifier 
		{
			
			logout<<"Line "<<line_count<<": parameter_list : type_specifier \n\n";
			$$=$1;
			logout<<$$->get_name()<<endl<<endl;
		}
		
		|parameter_list error 
		{
			
			yyclearin;
		}
 		;
compound_statement :  LCURL TEMP_STATE  statements  RCURL
		    {
		    	
			logout<<"Line "<<line_count<<": compound_statement : LCURL statements RCURL\n\n";	
			$$= new SymbolInfo("{\n"+$3->get_name()+"\n}"+"\n","");
			logout<<$$->get_name()<<endl<<endl;
			$$->code=$3->code;
			
			
			
		    }
 		    | LCURL TEMP_STATE RCURL
 		    {
 		    	
			logout<<"Line "<<line_count<<": compound_statement : LCURL statements RCURL\n\n";	
			$$= new SymbolInfo("{}\n","");
			logout<<$$->get_name()<<endl<<endl;
		    }
 		    ;			    
var_declaration : type_specifier declaration_list SEMICOLON
		{
			logout<<"Line "<<line_count<<": var_declaration : type_specifier declaration_list SEMICOLON\n\n";
			if(datatype == "void")
			{
				error<<"Error at line "<<line_count<<": Variable type cannot be void\n"<<endl ;
			 	logout<<"Error at line "<<line_count<<": Variable type cannot be void\n"<<endl ;
			 	errors++;
			}	
			$$= new SymbolInfo($1->get_name()+" "+$2->get_name()+";\n",$1->get_name());
			logout<<$$->get_name()<<endl<<endl;
		}
		| type_specifier error 
		   {
		   	error<<"Error at line "<<line_count<<": Syntax error "<<"\n"<<endl ;
		 	logout<<"Error at line "<<line_count<<": Syntax error "<<"\n"<<endl ;
		 	errors++;
		 	yyclearin;
		 	
		   }
 		;
		 
type_specifier	: INT	
		{
			logout<<"Line "<<line_count<<": type_specifier : INT\n\n";
			$$=new SymbolInfo(yytext,"");
			datatype = yytext;
			logout<<yytext<<endl<<endl;
		}
		|
	        FLOAT
	        {
			logout<<"Line "<<line_count<<": type_specifier : FLOAT\n\n";
			$$=new SymbolInfo(yytext,"");
			datatype = yytext;
			logout<<yytext<<endl<<endl;		
	        }
	        | 
	        VOID
	        {
	        	logout<<"Line "<<line_count<<": type_specifier : VOID\n\n";
			$$=new SymbolInfo(yytext,"");
			datatype = yytext;
			logout<<yytext<<endl<<endl;
 		}
 		;
 		
declaration_list : declaration_list COMMA ID
		   {     $$=new SymbolInfo($1->get_name()+","+$3->get_name(),"");	
			 bool check = table.Insert($3->get_name(),$3->get_type(), datatype);
			 if(check == false)
			 {	
			 	error<<"Error at line "<<line_count<<": Multiple declaration of "<<$3->get_name()<<"\n"<<endl ;
			 	logout<<"Error at line "<<line_count<<": Multiple declaration of "<<$3->get_name()<<"\n"<<endl ;
			 	errors++;
			 }
			 else
			 {
				 var($3->get_name());
			}
		   	 logout<<"Line "<<line_count<<": declaration_list : declaration_list COMMA ID\n"<<endl ;	
			 logout<<$$->get_name()<<endl<<endl;	
		   }
		   | declaration_list COMMA ID LTHIRD CONST_INT RTHIRD
		   {    
		   	$$=new SymbolInfo($1->get_name()+","+$3->get_name()+"["+$5->get_name()+"]","");
		   	bool check = table.Insert($3->get_name(),$3->get_type(), datatype);
			if(check == false)
			 {	
			 	error<<"Error at line "<<line_count<<": Multiple declaration of "<<$3->get_name()<<"\n"<<endl ;
			 	logout<<"Error at line "<<line_count<<": Multiple declaration of "<<$3->get_name()<<"\n"<<endl ;
			 	errors++;
			 }
			 else
			 {
			 	SymbolInfo *temp = new  SymbolInfo();
	    			temp = table.Lookup($3->get_name());
	    			temp->set_dataType(datatype);
	    			temp->set_arrayOrNot(true);
	    					 
				var_array($3->get_name(),$5->get_name());
			 }
		   	logout<<"Line "<<line_count<<": declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD\n\n";
			logout<<$$->get_name()<<endl<<endl;
		   }
		   
		   |ID 
		   {    
		   	$$=$1;
		   	if(datatype != "void")
		   	{
		   		bool check = table.Insert($1->get_name(),$1->get_type(), datatype);
				 if(check == false)
				 {	
				 	error<<"Error at line "<<line_count<<": Multiple declaration of "<<$1->get_name()<<"\n"<<endl ;
				 	logout<<"Error at line "<<line_count<<": Multiple declaration of "<<$1->get_name()<<"\n"<<endl ;
				 	errors++;
				 }
				 else
			   	{
					 var($1->get_name());
				 }
		   	}
		   	
		   	logout<<"Line "<<line_count<<": declaration_list : ID\n\n";
			logout<<$1->get_name()<<endl<<endl;
		   }
		   | ID LTHIRD CONST_INT RTHIRD
		   {  
		   	$$=new SymbolInfo($1->get_name()+"["+$3->get_name()+"]","");
			bool check = table.Insert($1->get_name(),$1->get_type(), datatype);  
		   	if(check == false)
			 {	
			 	error<<"Error at line "<<line_count<<": Multiple declaration of "<<$1->get_name()<<"\n"<<endl ;
			 	logout<<"Error at line "<<line_count<<": Multiple declaration of "<<$1->get_name()<<"\n"<<endl ;
			 	errors++;
			 }
			 else
			 {
			 	SymbolInfo *temp = new  SymbolInfo();
	    			temp = table.Lookup($1->get_name());
	    			temp->set_dataType(datatype);
	    			temp->set_arrayOrNot(true);
	    			
	    			var_array($1->get_name(),$3->get_name());
			 }
		   	logout<<"Line "<<line_count<<": declaration_list : ID LTHIRD CONST_INT RTHIRD\n\n";
			logout<<$$->get_name()<<endl<<endl;
		   }
		   |declaration_list   error 
		   {
		   	
		 	$$=$1;
		 	
		   }
		  
 		  ;
statements : statement
	    {
			logout<<"Line "<<line_count<<": statements : statement\n\n";	
			$$=$1;
			logout<<$$->get_name()<<endl<<endl;
	    }	
	   | statements statement
	   {
			logout<<"Line "<<line_count<<": statements : statements statement\n\n";	
			$$->set_name($1->get_name()+"\n"+$2->get_name());
			statement_string->set_name($1->get_name());
			//cout<<statement_string->get_name()<<endl;
			logout<<$$->get_name()<<endl<<endl;
			$$->code+=$2->code;
			
	    }	
	    
	    ;
	   
statement : var_declaration
	  {
			logout<<"Line "<<line_count<<": statement : var_declaration\n\n";	
			$$= $1;
			logout<<$$->get_name()<<endl<<endl;
	  }
	  | expression_statement
	  {
			logout<<"Line "<<line_count<<": statement : expression_statement\n\n";	
			$$= $1;
			
			logout<<$$->get_name()<<endl<<endl;
	  }
	  | compound_statement
	  {		
	  		table.print_all(logout);
	  		table.Exit_scope();
			logout<<"Line "<<line_count<<": statement : compound_statement\n\n";	
			$$= $1;
			logout<<$$->get_name()<<endl<<endl;
	  }	
	   | FOR LPAREN expression_statement expression_statement expression RPAREN statement
	  {
			logout<<"Line "<<line_count<<": statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement\n\n";	
			$$= new SymbolInfo("for("+$3->get_name()+$4->get_name()+$5->get_name()+")"+$7->get_name(),"");
			//////////////////----------------ASSEMBLY CODE HERE---------------- 
			$$->code=$3->code;
			string label1=newLabel();
			string label2=newLabel();
			$$->code+=label1+":\n";
			$$->code+=$4->code;
			$$->code+="\tcmp "+$4->get_symbol()+", 0\n";
			$$->code+="\tje "+label2+"\n";
			$$->code+=$7->code;
			$$->code+=$5->code;
			$$->code+="\tjmp "+label1+"\n";
			$$->code+=label2+":\n";
			logout<<$$->get_name()<<endl<<endl;
	  }
	  | IF LPAREN  expression TEMP1_STATE RPAREN statement  %prec LOWER_THAN_ELSE 
	  {
			logout<<"Line "<<line_count<<": statement : IF LPAREN expression RPAREN statement\n\n";	
			$$= new SymbolInfo("if ("+$3->get_name()+")"+$6->get_name(),"");
			//////////////////----------------ASSEMBLY CODE HERE--------------------
			$$->code=$3->code;
			$$->code+=var_ifElse2;
			$$->code+=$6->code;
			$$->code+=labeltrack1+":\n";
			var_ifElse1="";
			logout<<$$->get_name()<<endl<<endl;
	  }
	  | IF LPAREN expression TEMP1_STATE RPAREN   statement   ELSE statement
	  {
			logout<<"Line "<<line_count<<": statement : IF LPAREN expression RPAREN statement ELSE statement\n\n";	
			$$= new SymbolInfo("if ("+$3->get_name()+")"+$6->get_name()+"\n"+"else"+"\n"+$8->get_name(),"");
			//////////////////------------ASSEMBLY CODE HERE-----------------------
			$$->code=$3->code;
			$$->code+=var_ifElse2;
			$$->code+=$6->code;
			$$->code+="\tjmp "+labeltrack2+"\n";
			
			$$->code+=labeltrack1+":\n";
			$$->code+=$8->code;
			
			
			$$->code+=labeltrack2+":\n";
			cout<<$$->code;
			var_ifElse1="";
			logout<<$$->get_name()<<endl<<endl;
	  }
	  | WHILE LPAREN expression RPAREN statement
	  {
			logout<<"Line "<<line_count<<": statement : WHILE LPAREN expression RPAREN statement\n\n";	
			$$= new SymbolInfo("while ("+$3->get_name()+")"+$5->get_name(),"");
			//////////////////---------------ASSEMBLY CODE HERE---------------------
			string label1=newLabel();
			string label2=newLabel();
			$$->code=label1+":\n";
			$$->code+=$3->code;
			$$->code+="\tmov ax,"+$3->get_symbol()+"\n";
			$$->code+="\tcmp ax,0\n";
			$$->code+="\tje "+label2+"\n";
			$$->code+=$5->code;
			$$->code+="\tjmp "+label1+"\n";
			$$->code+=label2+":\n";
		logout<<$$->get_name()<<endl<<endl;
	  }
	  | PRINTLN LPAREN ID RPAREN SEMICOLON
	  {
			logout<<"Line "<<line_count<<": statement : PRINTLN LPAREN ID RPAREN SEMICOLON\n\n";
			$$= new SymbolInfo("printf("+$3->get_name()+")"+";\n","");
			SymbolInfo *temp = new  SymbolInfo();
	    		temp = table.Lookup($3->get_name());
	    		if(temp == NULL)
	  		{
	  			error<<"Error at line "<<line_count<<": Undeclared variable "<<$3->get_name()<<"\n\n";
	  			logout<<"Error at line "<<line_count<<": Undeclared variable "<<$3->get_name()<<"\n\n";
	  			errors++;
	  		}	
			else
			{
				//////////////////---------------ASSEMBLY CODE HERE---------------
				$$->code+="\tmov ax,"+$3->get_name()+to_string(var_number)+"\n";
				$$->code+="\tcall print\n";
			}
			logout<<$$->get_name()<<endl<<endl;
	  }	
	  | RETURN expression SEMICOLON
	  {
			logout<<"Line "<<line_count<<": statement : RETURN expression SEMICOLON\n\n";	
			$$= new SymbolInfo("return "+$2->get_name()+";"+"\n","");
			//////////////////-----------------ASSEMBLY CODE HERE-----------------
			if(!check_main)
			{
				$$->code=$2->code;
				if(check_temp_ret)
				{
					variable+="\tret_var dw ?\n";
					check_temp_ret=false;
				}
				$$->code+="\tmov ax,"+$2->get_symbol()+"\n";
				$$->code+="\tmov ret_var,ax\n";
				$$->code+="\tpop dx\n";
				$$->code+="\tpop cx\n";
				$$->code+="\tpop bx\n";
				$$->code+="\tret\n";
			}
			
			logout<<$$->get_name()<<endl<<endl;
	  }	
	  | func_definition
	  {
	  		logout<<"Line "<<line_count<<": statement : func_definition\n\n";	
	  		error<<"Error at line "<<line_count<<": Invalid function scoping\n\n";
	  		logout<<"Error at line "<<line_count<<": Invalid function scoping\n\n";
	  		errors++;
			$$= $1;
			logout<<$$->get_name()<<endl<<endl;
	  }
	  | func_declaration
	  {
	  		logout<<"Line "<<line_count<<": statement : func_declaration\n\n";	
	  		error<<"Error at line "<<line_count<<": Invalid function scoping\n\n";	
	  		logout<<"Error at line "<<line_count<<": Invalid function scoping\n\n";	
	  		errors++;
			$$= $1;
			logout<<$$->get_name()<<endl<<endl;
	  }
	  
	  ;
TEMP1_STATE:
	{
		var_ifElse1+="\tcmp ax,0\n";
		string label=newLabel();
		var_ifElse1+="\tje "+label+"\n";
		var_ifElse2 = var_ifElse1;
		labeltrack1=label;
		
		string label1=newLabel();
		labeltrack2=label1;
		
	}
	;
expression_statement 	: SEMICOLON
			{
				logout<<"Line "<<line_count<<": expression_statement : SEMICOLON\n\n";	
				$$= new SymbolInfo(";","");
				logout<<$$->get_name()<<endl<<endl;
	  		}				
			| expression SEMICOLON 
			{
				logout<<"Line "<<line_count<<": expression_statement : expression SEMICOLON\n\n";	
				$$= $1;
				logout<<$$->get_name()<<endl<<endl;
				$$->code=$1->code;
				
				
	  		}
	  		| error  expression_statement
	  		{

	  		}
	  		
			;

 variable : ID 	
	   {		logout<<"Line "<<line_count<<": variable : ID\n\n";
			$$=$1;
			SymbolInfo *temp = new  SymbolInfo();
	    		temp = table.Lookup($1->get_name());	
	    		bool check=true;
	    		if(temp == NULL)
	  		{
	  			
	  			error<<"Error at line "<<line_count<<": Undeclared variable "<<$1->get_name()<<"\n\n";
	  			logout<<"Error at line "<<line_count<<": Undeclared variable "<<$1->get_name()<<"\n\n";
	  			errors++;
	  			check=false;
	  			$$->set_dataType("none");
	  		}
	  		else
	  		{
	  			if(temp->get_arrayOrNot() == true)
	  			{
	  			error<<"Error at line "<<line_count<<": Type mismatch, "<<$1->get_name()<<" is an array\n\n";
	  			logout<<"Error at line "<<line_count<<": Type mismatch, "<<$1->get_name()<<" is an array\n\n";
	  			errors++;
	  			check=false;
	  			}
	  			$$->set_dataType(temp->get_dataType());
	  		}
	  		if(check)
	  		{
	  			$$->set_symbol($1->get_name()+to_string(var_number));
	  		}
			logout<<$$->get_name()<<endl<<endl;
	  }	
	 | ID LTHIRD expression RTHIRD 
	  { 		
	  		logout<<"Line "<<line_count<<": variable : ID LTHIRD expression RTHIRD\n\n";
	  		SymbolInfo *temp = new  SymbolInfo();
	    		temp = table.Lookup($1->get_name());
	    		int check=true;
	    		if(temp == NULL)
	  		{
	  			error<<"Error at line "<<line_count<<": Undeclared variable "<<$1->get_name()<<"\n\n";
	  			logout<<"Error at line "<<line_count<<": Undeclared variable "<<$1->get_name()<<"\n\n";
	  			errors++;
	  			$$->set_dataType("none");
	  			check=false;
	  		}
	  		else
	  		{
	  			if(temp->get_arrayOrNot() == false)
	  			{
		  			error<<"Error at line "<<line_count<<": "<<$1->get_name()<<" is not an array\n\n";
		  			logout<<"Error at line "<<line_count<<": "<<$1->get_name()<<" is not an array\n\n";
		  			errors++;
		  			check=false;
	  			}
	  			//cout<<line_count<<" "<<$1->get_name()<<" "<<$1->get_dataType()<<endl;
	  			//$$->set_dataType($1->get_dataType());
	  		}
	  		if($3->get_dataType() != "int")
	  		{
	  			error<<"Error at line "<<line_count<<": Expression inside third brackets not an integer\n\n";
	  			logout<<"Error at line "<<line_count<<": Expression inside third brackets not an integer\n\n";
	  			errors++;
	  			check=false;
	  			
	  		}
	  		$$=new SymbolInfo($1->get_name()+"["+$3->get_name()+"]","");
	  		$$->set_arrayOrNot(true);
	  		if(temp != NULL)
	  			$$->set_dataType(temp->get_dataType());
	  		///--------------ASSEMBLY--------
	  		if(check)
	  		{
	  			$$->code+="\tmov di,"+$3->get_name()+"\n";
	  			$$->code+="\tadd di,di\n";
	  			//string temp=newTemp();
	  			//variable+="\t"+temp+" dw ?\n";
	  			//$$->code+="\tmov ax,"+$1->get_name()+to_string(var_number)+"[di]\n";
	  			//$$->code+="\tmov "+temp+",ax	; new temp "+temp+"\n";
	  			//$$->set_symbol(temp);
	  			$$->set_symbol($1->get_name()+to_string(var_number)+"[di]");
	  			$$->set_array_var($1->get_name());

	  		}
			logout<<$$->get_name()<<endl<<endl;
	  }
	 ;
 expression : logic_expression
 	    {		logout<<"Line "<<line_count<<": expression : logic_expression\n\n";
			$$=$1;
			var_ifElse1="\t mov ax,"+$1->get_symbol()+"\n";
			logout<<$1->get_name()<<endl<<endl;
	    }	
 	    |  variable ASSIGNOP logic_expression 
	    {		
	    		logout<<"Line "<<line_count<<": expression : variable ASSIGNOP logic_expression\n\n";
	    		$$=new SymbolInfo($1->get_name()+"="+$3->get_name(),"");
    			if($1->get_dataType() != $3->get_dataType() && $3->get_dataType() != "void" && $1->get_dataType() != "" && $3->get_dataType() != "")
    			{
    				if($1->get_dataType() != "none")
    				{
    					if($1->get_dataType() =="float" && $3->get_dataType() == "int")
    					{}
    					else
    					{
    						error<<"Error at line "<<line_count<<": Type Mismatch\n\n";
	  					logout<<"Error at line "<<line_count<<": Type Mismatch\n\n";
	  					errors++;
    					}
    					
    				}
	    			
	  		}
			if($1->get_dataType() == "void" || $3->get_dataType() == "void")
			{
				error<<"Error at line "<<line_count<<": Void function used in expression\n\n";
			  	logout<<"Error at line "<<line_count<<": Void function used in expression\n\n";
			  	errors++;
			  	if($1->get_dataType() == "void" && $3->get_dataType() != "void")
			  		$$->set_dataType($3->get_dataType());
			  	else if($3->get_dataType() == "void" && $1->get_dataType() != "void")
			  		$$->set_dataType($1->get_dataType());
			  	else
			  		$$->set_dataType("none");
			}
			if($1->get_dataType() == "int" || $1->get_dataType() == "float" && $3->get_dataType() =="int" || $3->get_dataType() =="float")
			
			{
				if($1->get_arrayOrNot() && !($3->get_arrayOrNot()))///////ASSEMBLY CODE---------------
				{
				
					$$->code=$1->code;
					$$->code+=$3->code;
					$$->code+="\tmov ax,"+$3->get_symbol()+"\n";
					$$->code+="\tmov "+$1->get_array_var()+to_string(var_number)+"[di],ax\n";
					$$->val=$3->val;
				}
				else if($1->get_arrayOrNot() && $3->get_arrayOrNot())
				{
					string temp1=newTemp();
					variable+="\t"+temp1+" dw ?\n";
					$$->code=$3->code;
					$$->code+="\tmov ax,"+$3->get_symbol()+"\n";
					$$->code+="\tmov "+temp1+",ax	; new temp "+temp1+"\n";
					$$->code+=$1->code;
					$$->code+="\tmov ax,"+temp1+"\n";
					$$->code+="\tmov "+$1->get_symbol()+",ax\n";
					$$->val=$3->val;
				}
				else///////ASSEMBLY CODE---------------
				{
					$$->code=$1->code;
					$$->code+=$3->code;
					$$->code+="\tmov ax,"+$3->get_symbol()+"\n";
					$$->code+="\tmov "+$1->get_name()+to_string(var_number)+",ax\n";
					$$->val=$3->val;
				}
				
				
			}
			logout<<$$->get_name()<<endl<<endl;
	    }	
	   	
	   ;			
logic_expression : rel_expression 
		  {	logout<<"Line "<<line_count<<": logic_expression : rel_expression\n\n";
			$$=$1;
			
			logout<<$1->get_name()<<endl<<endl;
		  }
		  | rel_expression LOGICOP rel_expression 
		 {	logout<<"Line "<<line_count<<": logic_expression : rel_expression LOGICOP rel_expression\n\n";
			$$=new SymbolInfo($1->get_name()+$2->get_name()+$3->get_name(),"");
			bool check=true;
			if($3->get_dataType() == "void" || $1->get_dataType() == "void")
			{
				error<<"Error at line "<<line_count<<": Void function used in expression\n\n";
			  	logout<<"Error at line "<<line_count<<": Void function used in expression\n\n";
			  	errors++;
			  	if($1->get_dataType() == "void" && $3->get_dataType() != "void")
			  		$$->set_dataType($3->get_dataType());
			  	else if($3->get_dataType() == "void" && $1->get_dataType() != "void")
			  		$$->set_dataType($1->get_dataType());
			  	else
			  		$$->set_dataType("none");
			  	check=false;
			}
			else 
				$$->set_dataType("int");
			if(check)//////////-----------ASSEMBLY CODE----------
			{
				$$->code=$1->code;
				$$->code+=$3->code;
				
				string temp=newTemp();
				string label1=newLabel();
				string label2=newLabel();
				if($2->get_name()=="&&")
				{
					$$->code+="\tcmp " + $1->get_symbol()+",0 \n";
					$$->code+="\tje "+label1+"\n";
					$$->code+="\tcmp " + $3->get_symbol()+",0 \n";
					$$->code+="\tje "+label1+"\n";
					$$->code+="\tmov "+temp +", 1;	new temp "+temp+"\n";
					$$->code+="\tjmp "+label2+"\n";
				}
				else if($2->get_name()=="||")
				{
					$$->code+="\tcmp " + $1->get_symbol()+",0 \n";
					$$->code+="\tcmp " + $3->get_symbol()+",0 \n";
					$$->code+="\tje "+label1+"\n";
					$$->code+="\tmov "+temp +", 1	;new temp "+temp+"\n";
					$$->code+="\tjmp "+label2+"\n";
				}
				$$->code+=label1+":\n";
				$$->code+="\tmov "+temp+", 0\n";
				$$->code+=label2+":\n";
				$$->set_symbol(temp);
				variable+="\t"+temp+" dw ?\n";
			}
			logout<<$$->get_name()<<endl<<endl;
		 } 	
		
		 ;	
rel_expression	: simple_expression 
		 {	logout<<"Line "<<line_count<<": rel_expression : simple_expression\n\n";
			$$=$1;
			
			logout<<$1->get_name()<<endl<<endl;
		 }
		 | simple_expression RELOP simple_expression
		 {	logout<<"Line "<<line_count<<": rel_expression : simple_expression RELOP simple_expression\n\n";
			$$=new SymbolInfo($1->get_name()+$2->get_name()+$3->get_name(),"");
			bool check=true;
			if($3->get_dataType() == "void" || $1->get_dataType() == "void")
			{
				error<<"Error at line "<<line_count<<": Void function used in expression\n\n";
			  	logout<<"Error at line "<<line_count<<": Void function used in expression\n\n";
			  	errors++;
			  	if($1->get_dataType() == "void" && $3->get_dataType() != "void")
			  		$$->set_dataType($3->get_dataType());
			  	else if($3->get_dataType() == "void" && $1->get_dataType() != "void")
			  		$$->set_dataType($1->get_dataType());
			  	else
			  		$$->set_dataType("none");
			  	check = false;
			}
			else 
				$$->set_dataType("int");
			if(check)////ASSEMBLY--------------------
			{
				$$=$1;
				$$->code+=$3->code;
				$$->code+="\tmov ax, " + $1->get_symbol()+"\n";
				$$->code+="\tcmp ax, " + $3->get_symbol()+"\n";
				string temp=newTemp();
				string label1=newLabel();
				string label2=newLabel();
				if($2->get_name()=="<"){
					$$->code+="\tjl " + label1+"\n";
					
						
				}
				else if($2->get_name()=="<="){
					$$->code+="\tjle " + label1+"\n";
					
				}
				else if($2->get_name()==">"){
					$$->code+="\tjg " + label1+"\n";
					
				}
				else if($2->get_name()==">="){
					$$->code+="\tjge " + label1+"\n";
					
				}
				else if($2->get_name()=="=="){
					$$->code+="\tje " + label1+"\n";
					
				}
				else{
					$$->code+="\tjne " + label1+"\n";
					
				}
				$$->code+="\tmov "+temp +", 0;	new temp "+temp+"\n";
				$$->code+="\tjmp "+label2 +"\n";
				$$->code+=label1+":\n\tmov "+string(temp)+",1\n";
				$$->code+=label2+":\n";
				$$->set_symbol(temp);
				variable+="\t"+temp+" dw ?\n";
			}
			logout<<$$->get_name()<<endl<<endl;
		}
		
		;
				
simple_expression : term 
		   {	logout<<"Line "<<line_count<<": simple_expression : term\n\n";
			$$=$1;
			logout<<$$->get_name()<<endl<<endl;
		   }
		   | simple_expression ADDOP term 
		   {	logout<<"Line "<<line_count<<": simple_expression : simple_expression ADDOP term\n\n";
			$$=new SymbolInfo($1->get_name()+$2->get_name()+$3->get_name(),"");
			bool check=true;
			if($3->get_dataType() == "void" || $1->get_dataType() == "void")
			{
				error<<"Error at line "<<line_count<<": Void function used in expression\n\n";
			  	logout<<"Error at line "<<line_count<<": Void function used in expression\n\n";
			  	errors++;
			  	if($1->get_dataType() == "void" && $3->get_dataType() != "void")
			  		$$->set_dataType($3->get_dataType());
			  	else if($3->get_dataType() == "void" && $1->get_dataType() != "void")
			  		$$->set_dataType($1->get_dataType());
			  	else
			  		$$->set_dataType("none");
			  	check=false;
			}
			if(check)
			{
				$$->code=$1->code;
				$$->code+=$3->code;
				$$->code+="\tmov ax,"+$1->get_symbol()+"\n";
				$$->code+="\tadd ax, "+$3->get_symbol()+"\n";
				string temp=newTemp();
				variable+="\t"+temp+" dw ?\n";
				$$->code+="\tmov "+temp+",ax	;new temp "+temp+"\n";
				$$->set_symbol(temp);
				if($1->get_dataType() == "float" || $3->get_dataType() =="float")
				{
					$$->set_dataType("float");
					
				}
				else 
				{
					$$->set_dataType("int");
				}
				
				$$->val = $1->val + $3->val;	
				
				
			}
			logout<<$$->get_name()<<endl<<endl;
		   }  
		  ;
					
term :	unary_expression
	{	logout<<"Line "<<line_count<<": term : unary_expression\n\n";
		$$=$1;
		logout<<$1->get_name()<<endl<<endl;
	}
	|  term MULOP unary_expression
	{	logout<<"Line "<<line_count<<": term : term MULOP unary_expression\n\n";
		$$=new SymbolInfo($1->get_name()+$2->get_name()+$3->get_name(),"");
		bool check = true;
		if($2->get_name() == "%")
		{
			if($1->get_dataType() == "float" || $3->get_dataType() == "float")
			{
				error<<"Error at line "<<line_count<<": Non-Integer operand on modulus operator\n\n";
		  		logout<<"Error at line "<<line_count<<": Non-Integer operand on modulus operator\n\n";
		  		errors++;
		  		check = false;
			}
			if($3->get_name() == "0")
			{
				error<<"Error at line "<<line_count<<": Modulus by Zero\n\n";
		  		logout<<"Error at line "<<line_count<<": Modulus by Zero\n\n";
		  		errors++;
		  		check = false;
			}
			$$->set_dataType("int");
			if(check)//ASSEMBLY CODE-----------
			{
				$$->code+=$1->code;
				$$->code+=$3->code;
				$$->code+="\txor dx,dx\n";
				$$->code+="\tmov ax,"+$1->get_symbol()+"\n";
				$$->code+="\tmov bx,"+$3->get_symbol()+"\n";
				$$->code+="\tdiv bx\n";
				string temp=newTemp();
				variable+="\t"+temp+" dw ?\n";
				$$->code+="\tmov "+temp+",dx	;new temp "+temp+"\n";
				$$->set_symbol(temp);
				
				
			}
			
		}
		if($2->get_name() == "/")
		{
			if($3->get_name() == "0")
			{
				error<<"Error at line "<<line_count<<": Divide by Zero\n\n";
		  		logout<<"Error at line "<<line_count<<": Divide by Zero\n\n";
		  		errors++;
		  		check = false;
			}
			if(check)//ASSEMBLY CODE--------------
			{
				$$->code+=$1->code;
				$$->code+=$3->code;
				$$->code+="\tmov ax,"+$1->get_symbol()+"\n";
				$$->code+="\tmov bx,"+$3->get_symbol()+"\n";
				$$->code+="\tdiv bx\n";
				string temp=newTemp();
				variable+="\t"+temp+" dw ?\n";
				$$->code+="\tmov "+temp+",ax	;new temp "+temp+"\n";
				$$->set_symbol(temp);
				
				
			}
		}
		if($2->get_name() == "/" || $2->get_name() == "*")
		{
			if($1->get_dataType() == "float" || $3->get_dataType() =="float")
			{
				$$->set_dataType("float");
			}
			else 
			{
				$$->set_dataType("int");
			}
			if( $2->get_name() == "*")
			{
				if(check)//ASSEMBLY CODE----------------
				{
					$$->code+=$1->code;
					$$->code+=$3->code;
					$$->code+="\tmov ax,"+$1->get_symbol()+"\n";
					$$->code+="\tmov bx,"+$3->get_symbol()+"\n";
					$$->code+="\tmul bx\n";
					string temp=newTemp();
					variable+="\t"+temp+" dw ?\n";
					$$->code+="\tmov "+temp+",ax	;new temp "+temp+"\n";
					$$->set_symbol(temp);
					
				}
			}
		}
		if($3->get_dataType() == "void" || $1->get_dataType() == "void")
		{
			error<<"Error at line "<<line_count<<": Void function used in expression\n\n";
		  	logout<<"Error at line "<<line_count<<": Void function used in expression\n\n";
		  	errors++;
		  	if($1->get_dataType() == "void" && $3->get_dataType() != "void")
		  		$$->set_dataType($3->get_dataType());
		  	else if($3->get_dataType() == "void" && $1->get_dataType() != "void")
		  		$$->set_dataType($1->get_dataType());
		  	else
		  		$$->set_dataType("none");
		  	check = false;
		}
		logout<<$$->get_name()<<endl<<endl;
		
	}
	 
     ;

unary_expression :ADDOP unary_expression  
		  {	logout<<"Line "<<line_count<<": unary_expression : ADDOP unary_expression\n\n";
			$$=new SymbolInfo($1->get_name()+$2->get_name(),"");
			$$->set_dataType($2->get_dataType());
			if($2->get_dataType() == "void")
			{
				error<<"Error at line "<<line_count<<": Void function used in expression\n\n";
			  	logout<<"Error at line "<<line_count<<": Void function used in expression\n\n";
			  	errors++;
			}
			logout<<$$->get_name()<<endl<<endl;
		  }
		  | NOT unary_expression 
		  {	logout<<"Line "<<line_count<<": unary_expression : NOT unary_expression\n\n";
			$$=new SymbolInfo("!"+$2->get_name(),"");
			$$->set_dataType($2->get_dataType());
			if($2->get_dataType() == "void")
			{
				error<<"Error at line "<<line_count<<": Void function used in expression\n\n";
			  	logout<<"Error at line "<<line_count<<": Void function used in expression\n\n";
			  	errors++;
			}
			logout<<$$->get_name()<<endl<<endl;
		  }
		  | factor 
		  {	logout<<"Line "<<line_count<<": unary_expression : factor\n\n";
			$$=$1;
			logout<<$$->get_name()<<endl<<endl;
		  }
		 ;
EXTRA_STATE : 
	    {
	    	SymbolInfo *temp = new SymbolInfo();
		temp = table.Lookup(id);
		if(temp != NULL)
		{
			Function_property * func = new Function_property();
			func = temp->get_function();
			if(func != NULL)
			{
				para_list = func->get_paraList();
			}	
		}
		for(int i=0; i<func_var_track.size(); i++)
		{
			if(func_var_track[i].first == id)
			{
				func_number=func_var_track[i].second;
				//cout<<func_var_track[i].first<<endl;
				break;
			}
		}

	    }
	    ;	
factor	: variable 
	{	logout<<"Line "<<line_count<<": factor : variable\n\n";
		$$=$1;
		$$->val=$1->val;
		logout<<$$->get_name()<<endl<<endl;
	}
	| ID LPAREN EXTRA_STATE argument_list RPAREN
	{	logout<<"Line "<<line_count<<": factor : ID LPAREN argument_list RPAREN\n\n";
		SymbolInfo *temp = new SymbolInfo();
		temp = table.Lookup($1->get_name());
		$$=new SymbolInfo($1->get_name()+"("+$4->get_name()+")","");
		bool check=true;
		if(temp != NULL && temp->get_functionOrNot()==true)
		{
			$$->set_dataType(temp->get_dataType());
			Function_property * func = new Function_property();
			func = temp->get_function();
			
			if(func != NULL)
			{
				//cout<<temp->get_dataType()<<" "<<temp->get_name()<<endl;
				if(func->get_parameterNumber() != argument_count)
				{
					error<<"Error at line "<<line_count<<": Total number of arguments mismatch in function "<<$1->get_name()<<"\n\n";
		  			logout<<"Error at line "<<line_count<<": Total number of arguments mismatch in function "<<$1->get_name()<<"\n\n";
		  			errors++;
		  			check=false;
				}
				else if(para_list.size() != 0 )
				{
					if( argument_error_number.size()!=0)
					{
						string temp="";
						error<<"Error at line "<<line_count<<": ";
						logout<<"Error at line "<<line_count<<": ";
						for(int i=0; i<argument_error_number.size(); i++)
						{
							error<<argument_error_number[i]<<"th ";
							logout<<argument_error_number[i]<<"th ";
						}
						error<<"argument mismatch in function "<<$1->get_name()<<"\n\n";
		  				logout<<"argument mismatch in function"<<$1->get_name()<<"\n\n";
		  				errors++;
		  				check=false;
					}
				}
			}
			
		}
		else
		{
			error<<"Error at line "<<line_count<<": Undefined function "<<$1->get_name()<<"\n\n";
	  		logout<<"Error at line "<<line_count<<": Undefined function "<<$1->get_name()<<"\n\n";
	  		errors++;
	  		check=false;
		}
		if(check)
		{
			$$->code=$4->code;
			$$->code+="\tcall "+$1->get_name()+"\n";
			string temp=newTemp();
			variable+="\t"+temp+" dw ?\n";
			$$->code+="\tmov ax,ret_var\n";
			$$->code+="\tmov "+temp+",ax	;new temp"+temp+"\n";
			$$->set_symbol(temp);
		}
		argument_count=0;
		argument_error_number.clear();
		logout<<$$->get_name()<<endl<<endl;
	}
	| LPAREN expression RPAREN
	{	logout<<"Line "<<line_count<<": factor : LPAREN expression RPAREN\n\n";
		$$=new SymbolInfo("("+$2->get_name()+")","");
		$$->set_dataType($2->get_dataType());
		$$->set_symbol($2->get_symbol());
		$$->code=$2->code;
		logout<<$$->get_name()<<endl<<endl;
	}
	| CONST_INT 
	{	logout<<"Line "<<line_count<<": factor : CONST_INT\n\n";
		$$=new SymbolInfo(yytext,"int");
		$$->set_dataType("int");
		$$->set_symbol(yytext); ///------------------ASSEMBLY SYMBOL TRACK--------------------
		$$->val=atoi(yytext);
		logout<<yytext<<endl<<endl;
	}
	| CONST_FLOAT
	{	logout<<"Line "<<line_count<<": factor : CONST_FLOAT\n\n";
		$$=new SymbolInfo(yytext,"float");
		$$->set_dataType("float");
		$$->set_symbol(yytext);///-----------------ASSEMBLY SYMBOL TRACK------------------
		$$->val=atoi(yytext);
		logout<<yytext<<endl<<endl;
	}
	| variable INCOP 
	{	logout<<"Line "<<line_count<<": factor : variable INCOP\n\n";
		$$=new SymbolInfo($1->get_name()+"++","");
		$$->set_dataType($1->get_dataType());
		
		$$->code=$1->code;///------------ASSEMBLY code------------------
		string temp=newTemp();
		variable+="\t"+temp+" dw ?\n";
		$$->code+="\tmov ax,"+$1->get_symbol()+"\n";
		$$->code+="\tmov "+temp+",ax	;new temp "+temp+"\n";
		$$->code+="\tinc "+$1->get_symbol()+"\n";
		$$->set_symbol(temp);
		logout<<$$->get_name()<<endl<<endl;
	}	
	| variable DECOP
	{	logout<<"Line "<<line_count<<": factor : variable DECOP\n\n";
		$$=new SymbolInfo($1->get_name()+"--","");
		$$->set_dataType($1->get_dataType());
		
		$$->code=$1->code;///------------ASSEMBLY code------------------
		
		string temp=newTemp();
		variable+="\t"+temp+" dw ?\n";
		$$->code+="\tmov ax,"+$1->get_symbol()+"\n";
		$$->code+="\tmov "+temp+",ax	;new temp "+temp+"\n";
		$$->code+="\tdec "+$1->get_symbol()+"\n";
		$$->set_symbol(temp);
		logout<<$$->get_name()<<endl<<endl;
	}
	;

argument_list : arguments
		{	logout<<"Line "<<line_count<<": argument_list : arguments\n\n";
			$$=$1;
			logout<<$$->get_name()<<endl<<endl;
		}
		|
		{	$$=new SymbolInfo("","");
			logout<<"Line "<<line_count<<": argument_list : \n\n";
		}
		;

	;	
	
arguments : arguments COMMA logic_expression
	   {		logout<<"Line "<<line_count<<": arguments : arguments COMMA logic_expression\n\n";
			$$=new SymbolInfo($1->get_name()+","+$3->get_name(),"");
			bool check=true;
			if(para_list.size() != 0 && argument_count <para_list.size() )
			{
				if(para_list[argument_count].first =="int" && $3->get_dataType() !="int")
				{
					argument_error_number.push_back(argument_count+1);
					check=false;
					
				}
			}
			if(check)
			{
				$$->code=$1->code;
				$$->code+=$3->code;
				$$->code+="\tmov ax,"+$3->get_symbol()+"\n";
				$$->code+="\tmov "+para_list[argument_count].second+to_string(func_number)+",ax\n"; 
				$$->set_symbol($1->get_symbol());
			}
			argument_count++;
			logout<<$$->get_name()<<endl<<endl;
	   }
	   | logic_expression
	   {		logout<<"Line "<<line_count<<": arguments : logic_expression\n\n";
			$$=$1;
			bool check=true;
			if(para_list.size() != 0)
			{
				if(para_list[argument_count].first =="int" && $1->get_dataType() !="int")
				{
					argument_error_number.push_back(argument_count+1);
					check=false;
				}
					
			}
			if(check)
			{
				$$->code=$1->code;
				$$->code+="\tmov ax,"+$1->get_symbol()+"\n";
				$$->code+="\tmov "+para_list[argument_count].second+to_string(func_number)+",ax\n"; 
				$$->set_symbol($1->get_symbol());
			}
			argument_count++;
			logout<<$$->get_name()<<endl<<endl;
	   }
	   ;

%%
int main(int argc,char *argv[])
{	
	FILE *fin=fopen(argv[1],"r");
	if(fin==NULL)
	{
		printf("Cannot Open Input File.\n");
		exit(1);
	}
	/*yydebug=1;*/
	yyin=fin;
	yyparse();
	logout.close();
	return 0;
}
