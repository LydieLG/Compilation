%code requires{
#include "Table_des_symboles.h"
#include "Attribute.h"
 }

%{

#include <stdio.h>

extern int yylex();
extern int yyparse();

void yyerror (char* s) {
  printf ("%s\n",s);
}

%}

%union {
	attribute val;
}
%token <val> NUMI NUMF
%token TINT TFLOAT STRUCT
%token <val> ID
%token AO AF PO PF PV VIR
%token RETURN VOID EQ
%token <val> IF ELSE WHILE

%token <val> AND OR NOT DIFF EQUAL SUP INF
%token PLUS MOINS STAR DIV
%token DOT ARR

%left DIFF EQUAL SUP INF       // low priority on comparison
%left PLUS MOINS               // higher priority on + -
%left STAR DIV                 // higher priority on * /
%left OR                       // higher priority on ||
%left AND                      // higher priority on &&
%left DOT ARR                  // higher priority on . and ->
%nonassoc UNA                  // highest priority on unary operator

%type <val> exp
%type <val> type
%type <val> vir
%type <val> did
%type <val> vlist
%type <val> typename
%type <val> var_decl
%type <val> while
%type <val> while_cond
%type <val> loop
%type <val> else
%type <val> if
%type <val> bool_cond
%type <val> inst

%start prog



%%

prog : block                   {}
;

block:
decl_list inst_list            {} // rien à remplir dans cette accolade
;

// I. Declarations

decl_list : decl decl_list     {}
|                              {}
;

decl: var_decl PV              {}
| struct_decl PV               {}
| fun_decl                     {}
;

// I.1. Variables
var_decl : type vlist          {}
;

// I.2. Structures
struct_decl : STRUCT ID struct {}
;

struct : AO attr AF            {}
;

attr : type ID                 {}
| type ID PV attr              {}

// I.3. Functions

fun_decl : type fun            {}
;

fun : fun_head fun_body        {}
;

fun_head : ID PO PF            {}
| ID PO params PF              {}
;

params: type ID vir params     {}
| type ID                      {}
;

vlist: did vir vlist           {}
| did                          {}
;

did: ID                        {  sid id = string_to_sid($1->name);
                                  attribute att = new_attribute();
                                  att->name=id;
                                  att->type_val = $<val>0->type_val;
                                  $$ = att;
                                  set_symbol_value(id,att);
                                  fprintf(test_h," %s;\n",att->name);
                                }

vir : VIR                      {  $$ = $<val>-1;
                                  if ($$->type_val == INT){
                                    fprintf(test_h, "int");
                                  }
                                  else{
                                    fprintf(test_h, "float");
                                  }
                                }
;

fun_body : AO block AF         {}
;

// I.4. Types
type
: typename pointer             {}
| typename                     {$$=$<val>1;}
;

typename
: TINT                          { attribute att = new_attribute();
                                  att->type_val = INT;
                                  $$ = att;
                                  fprintf(test_h,"int");
                                }
| TFLOAT                        { attribute att = new_attribute();
                                  att->type_val = FLOAT;
                                  $$ = att;
                                  fprintf(test_h,"float");
                                }
| VOID                          {}
| STRUCT ID                     {}
;

pointer
: pointer STAR                 {}
| STAR                         {}
;


// II. Instructions

inst_list: inst PV inst_list   {}
| inst                         {}
|                              {}
;

inst:
exp                           {}
| AO block AF                 {}
| aff                         {}
| ret                         {}
| cond                        {}
| loop                        {}
| PV                          {}
;


// II.1 Affectations

aff : ID EQ exp               { attribute attr =  get_symbol_value(string_to_sid($1->name));
                                if (attr->type_val == $3->type_val){
                                  set_symbol_value(string_to_sid($1->name), $3);
                                  fprintf(test_c,"\t%s = r%d;\n", $1->name, $3->reg_number);
                                }
                                else{
                                  yyerror("Affectation impossible ! Types différents !\n");
                                }
                              }
| STAR exp EQ exp             {}
;

// II.2 Return
ret : RETURN exp              {}
| RETURN PO exp PF            {}
;

// II.3. Conditionelles
cond :
if bool_cond stat else stat        {}
|  bool_cond stat                  {}
;


stat: AO block AF             {}
;

bool_cond : PO exp PF         {}
;

if : IF                       {}
;

else : ELSE                   {}
;

// II.4. Iterations

loop : while while_cond inst  { fprintf(test_c, "\tgoto l%d;\n", $1->reg_number);
                                fprintf(test_c, "\tl%d:\n", $2->reg_number);
                              }
;

while_cond : PO exp PF        { $$->int_val = new_l_number();
                                $$->reg_number = new_l_number();
                                fprintf(test_c, "\tif (r%d) goto l%d;\n", $2->reg_number, $$->int_val);
                                fprintf(test_c, "\tgoto l%d;\n", $$->reg_number);
                                fprintf(test_c, "\tl%d:\n", $$->int_val);
                              }

while : WHILE                 { $$ = new_attribute();
                                $$->reg_number = new_l_number();
                                fprintf(test_c, "\tl%d:\n", $$->reg_number);
                              }
;


// II.3 Expressions
exp
// II.3.0 Exp. arithmetiques
: MOINS exp %prec UNA         {}
| exp PLUS exp                { $$ = new_attribute();
                                attribute att1 = $1;
                                attribute att2 = $3;
                                $$->reg_number = new_registre();

                                if((att1->type_val == FLOAT) || (att2->type_val == FLOAT))
                                {
                                  fprintf(test_h, "float r%d;\n", $$->reg_number);
                                  $$->type_val = FLOAT;
                                }
                                else
                                {
                                  fprintf(test_h, "int r%d;\n", $$->reg_number);
                                  $$->type_val = INT;
                                }
                                fprintf(test_c, "\tr%d = r%d + r%d;\n", $$->reg_number, att1->reg_number, att2->reg_number);
                              }
| exp MOINS exp               { $$ = new_attribute();
                                attribute att1 = $1;
                                attribute att2 = $3;
                                $$->reg_number = new_registre();

                                if((att1->type_val == FLOAT) || (att2->type_val == FLOAT))
                                {
                                  fprintf(test_h, "float r%d;\n", $$->reg_number);
                                  $$->type_val = FLOAT;
                                }
                                else
                                {
                                  fprintf(test_h, "int r%d;\n", $$->reg_number);
                                  $$->type_val = INT;
                                }
                                fprintf(test_c, "\tr%d = r%d - r%d;\n", $$->reg_number, att1->reg_number, att2->reg_number);
                              }
| exp STAR exp                { $$ = new_attribute();
                                attribute att1 = $1;
                                attribute att2 = $3;
                                $$->reg_number = new_registre();

                                if((att1->type_val == FLOAT) || (att2->type_val == FLOAT))
                                {
                                  fprintf(test_h, "float r%d;\n", $$->reg_number);
                                  $$->type_val = FLOAT;
                                }
                                else
                                {
                                  fprintf(test_h, "int r%d;\n", $$->reg_number);
                                  $$->type_val = INT;
                                }
                                fprintf(test_c, "\tr%d = r%d * r%d;\n", $$->reg_number, att1->reg_number, att2->reg_number);
                              }
| exp DIV exp                 { $$ = new_attribute();
                                attribute att1 = $1;
                                attribute att2 = $3;
                                $$->reg_number = new_registre();

                                if((att1->type_val == FLOAT) || (att2->type_val == FLOAT))
                                {
                                  fprintf(test_h, "float r%d;\n", $$->reg_number);
                                  $$->type_val = FLOAT;
                                }
                                else
                                {
                                  fprintf(test_h, "int r%d;\n", $$->reg_number);
                                  $$->type_val = INT;
                                }
                                fprintf(test_c, "\tr%d = r%d / r%d;\n", $$->reg_number, att1->reg_number, att2->reg_number);
                              }
| PO exp PF                   { $$=$2;}
| ID                          { attribute att = get_symbol_value(string_to_sid($1->name));
                                $$=att;
                              }
| NUMI                        { $$->reg_number = new_registre();
                                $$->int_val = $1->int_val;
                                $$->type_val = INT;
                                fprintf(test_h, "int r%d;\n", $$->reg_number);
                                fprintf(test_c, "\tr%d = %d;\n", $$->reg_number, $$->int_val );
                              }
| NUMF                        { $$->reg_number = new_registre();
                                $$->float_val = $1->float_val;
                                $$->type_val = FLOAT;
                                fprintf(test_h, "float r%d;\n", $$->reg_number);
                                fprintf(test_c, "\tr%d = %f;\n", $$->reg_number, $$->float_val );
                              }

// II.3.1 Déréférencement

| STAR exp %prec UNA          {}

// II.3.2. Booléens

| NOT exp %prec UNA           {}

| exp INF exp                 { attribute att = new_attribute();
                                att->reg_number = new_registre();
                                att->type_val = INT;
                                fprintf(test_c, "\tr%d = r%d < r%d;\n", att->reg_number , $1->reg_number , $3->reg_number);
                                fprintf(test_h, "int r%d;\n", att->reg_number);
                                $$=att;
                              }

| exp SUP exp                 { attribute att = new_attribute();
                                att->reg_number = new_registre();
                                att->type_val = INT;
                                fprintf(test_c, "\tr%d = r%d > r%d;\n", att->reg_number , $1->reg_number , $3->reg_number);
                                fprintf(test_h, "int r%d;\n", att->reg_number);
                                $$=att;
                              }

| exp EQUAL exp               { attribute att = new_attribute();
                                att->reg_number = new_registre();
                                att->type_val = INT;
                                fprintf(test_c, "\tr%d = r%d == r%d;\n", att->reg_number , $1->reg_number , $3->reg_number);
                                fprintf(test_h, "int r%d;\n", att->reg_number);
                                $$=att;
                              }

| exp DIFF exp                { attribute att = new_attribute();
                                att->reg_number = new_registre();
                                att->type_val = INT;
                                fprintf(test_c, "\tr%d = r%d != r%d;\n", att->reg_number , $1->reg_number , $3->reg_number);
                                fprintf(test_h, "int r%d;\n", att->reg_number);
                                $$=att;
                              }

| exp AND exp                 { attribute att = new_attribute();
                                att->reg_number = new_registre();
                                att->type_val = INT;
                                fprintf(test_c, "\tr%d = r%d && r%d;\n", att->reg_number , $1->reg_number , $3->reg_number);
                                fprintf(test_h, "int r%d;\n", att->reg_number);
                                $$=att;
                              }

| exp OR exp                  { attribute att = new_attribute();
                                att->reg_number = new_registre();
                                att->type_val = INT;
                                fprintf(test_c, "\tr%d = r%d || r%d;\n", att->reg_number , $1->reg_number , $3->reg_number);
                                fprintf(test_h, "int r%d;\n", att->reg_number);
                                $$=att;
                              }

// II.3.3. Structures

| exp ARR ID                  {}
| exp DOT ID                  {}

| app                         {}
;

// II.4 Applications de fonctions

app : ID PO args PF;

args :  arglist               {}
|                             {}
;

arglist : exp VIR arglist     {}
| exp                         {}
;



%%
int main ()
{ test_h = fopen("test/test.h", "w");
  test_c = fopen("test/test.c", "w");

  fprintf(test_c, "#include \"test.h\"\n\n");
  fprintf(test_h, "#include <stdbool.h>\n");
  fprintf(test_h, "#include <stdio.h>\n\n");
  fprintf(test_c, "int main(void){\n");

  yyparse ();

  fprintf(test_c, "\tprintf(\"\\033[32mOK\\033[0m\\n\");\n");

  fprintf(test_c, "\treturn 0;\n}");
  fclose(test_c);
  fclose(test_h);
}
