%{
#include <stdio.h>
#include <string.h>

#include "../tabsym/tabsym.h"
#include "../quad/quad.h"

#define BOOL "BLT"
#define INT "INT"
#define FLOAT "FLT"
#define STRING "STR"
#define CHAR "CHR"
int lignes = 1;
char saveType[25];
char saveIdf[30];
char currentExpType[25];
char saveOp[6];
extern int indq;
int debDoWhile;
int debIf;
int thenIf;




void setType(char* s) {
  strcpy(saveType, s);
}
%}


%union {int integer;
  char* string;
  float real;
  char ch;  
  struct {int type;char* res;}NT;
  struct {char* ref;} REF;
  }



%token left_ar right_ar fw_slash excl col left_par right_par left_bracket right_bracket bar eq semi_col plus dash asterisk comma 
%token t_int t_float t_boolean t_char t_string 
%token <integer>v_true <integer> v_false <string> v_string <real> v_real <integer> v_integer <ch>v_char
%token k_docprogram k_as k_array k_sub k_body k_variable k_const k_aff k_input k_output 
%token and or not sup inf supe infe ega dif 
%token k_if  k_then k_else k_do k_while k_for k_until
%token <string> idf err
%left plus dash
%left asterisk fw_slash
%left left_par right_par 
%type <string> TYPE
%type <string> IDF
%type <string> IDF_TAB
%type <string> TAB_ARG
%type<NT> EXPRESSION_ARITHMETIQUE
%type<NT> EXPRESSION_LOGIQUE
%type<NT> AFF_ARG
%type <integer>VALUE_BOOL
%type <NT> AND_ARG
%type <NT> OR_ARG
%type <string> AND
%type <string> OR
%type <string> NOT
%type <string> DIF
%type <string> EGA
%type <string> INF
%type <string> INFE
%type <string> SUP
%type <string> SUPE
%type <string> COMP_ARG
%type <string> OPEN_WHILE
%type <string> WHILE
%type <string> CLOSE_DO



%start S


%%
S: DOCPROGRAM {printf("\n ********* Program compiled successfuly. *********\n");
      YYACCEPT;}

| err
;

DOCPROGRAM: left_ar excl k_docprogram idf right_ar DECLARATIONS left_ar fw_slash k_docprogram right_ar
;

DECLARATIONS:DEC DECLARATIONS 
             |BODY
             ;

DEC:DEC_VARIABLE
    |DEC_CONSTANTE 
    |DEC_ARRAY
    ;

CLOSE_SUB: left_ar fw_slash k_sub right_ar
;

CLOSE_ARRAY: left_ar fw_slash k_array right_ar
;

OPEN_SUB_CONST: left_ar k_sub k_const right_ar
;

OPEN_SUB_VAR: left_ar k_sub k_variable right_ar;
OPEN_SUB_ARRAY: left_ar k_array k_as TYPE right_ar {setType($4)};

TYPE:t_boolean {$$= BOOL;}
     |t_char {$$ = CHAR;}
     |t_int {$$=INT;}
     |t_float {$$=FLOAT;}
     |t_string {$$=STRING;}
     ;

DEC_VARIABLE: OPEN_SUB_VAR BLOCK_DEC_VAR 
;
DEC_CONSTANTE: OPEN_SUB_CONST BLOCK_DEC_CONST
;
DEC_ARRAY: OPEN_SUB_ARRAY BLOCK_DEC_ARRAY
;

LIST_VAR:IDF_CONTROLLER 
    |IDF_CONTROLLER bar LIST_VAR 
    ;

IDF_CONTROLLER: idf {if(ExistDeclaration($1)==0) {
                       if(insererT($1)==-1)
                        printf("erreur semantique [%d] : double declaration de \"%s\"\n",lignes,$1);

          }
                     else 
                        printf("erreur semantique [%d] : double declaration de \"%s\"\n",lignes,$1);
                     };



LIST_CONST: IDF_CONTROLLER_CSTE
    | IDF_CONTROLLER_CSTE bar LIST_CONST ;

IDF_CONTROLLER_CSTE:idf{{if(ExistDeclaration($1)==0) {
                       if(insererCnst($1)==-1)
                        printf("erreur semantique [%d] : double declaration de \"%s\"\n",lignes,$1);

          }
                     else 
                       printf("erreur semantique [%d] : double declaration de \"%s\"\n",lignes,$1);
                     };};

IDF_DEC_INIT:left_ar idf eq VALUE fw_slash right_ar {cnsteInit($2,"oui");InsererType($2,saveType);}
             ;
IDF_DEC_CONST_TYPE: left_ar LIST_CONST k_as TYPE fw_slash right_ar {InsererTypeCnste($4,"null");};


IDF_DEC_VAR:left_ar LIST_VAR k_as TYPE fw_slash right_ar {InsererTypeC($4);}
            ;

IDF_DEC_CONST:IDF_DEC_CONST_TYPE 
              |IDF_DEC_INIT
              ;
IDF_DEC_ARRAY: left_ar idf col v_integer fw_slash right_ar {InsererTailleTab($2,$4);strcpy(saveIdf,$2);InsererType(saveIdf,saveType);}
;

BLOCK_DEC_VAR:IDF_DEC_VAR semi_col BLOCK_DEC_VAR
              |CLOSE_SUB
              ;

BLOCK_DEC_CONST:IDF_DEC_CONST semi_col BLOCK_DEC_CONST
               |CLOSE_SUB
               ;

BLOCK_DEC_ARRAY:IDF_DEC_ARRAY semi_col BLOCK_DEC_ARRAY 
               |CLOSE_ARRAY
;


VALUE:VALUE_BOOL 
     |VALUE_NUMERIC 
     |v_string {setType(STRING);}
     |v_char {setType(CHAR);}
     ;

VALUE_BOOL:v_false {setType(BOOL);$$=0;}
          |v_true {setType(BOOL);$$=1;}
          ;
VALUE_NUMERIC:v_integer {setType(INT);}
             |v_real {setType(FLOAT);}
             ;
CLOSE_BODY: left_ar fw_slash k_body right_ar;
BODY: left_ar k_body right_ar BLOCK_INST  ;

INSTRUCTION:INPUT
           |OUTPUT
           |CONDITIONAL
           |DO_WHILE
           |FOR
           |AFF
           |v_integer
           |v_real 
           ;

BLOCK_INST:INSTRUCTION BLOCK_INST
          |CLOSE_BODY
          ;

BLOCK_INST_FOR:INSTRUCTION BLOCK_INST_FOR
              |CLOSE_FOR
              ;

CLOSE_FOR:left_ar fw_slash k_for right_ar
;

INPUT:left_ar k_input col idf v_string fw_slash right_ar {if(ExistDeclaration($4)==0){
  printf("erreur semantique [%d] : variable non declarer dans input \"%s\"\n",lignes,$4);
}else{
  cmpcomp($5,$4,lignes);
}}
;
OUTPUT:left_ar k_output col OUTPUT_ARG fw_slash right_ar 
;
OUTPUT_ARG:OUTPUT_STR plus OUTPUT_ARG 
          |OUTPUT_IDF plus OUTPUT_ARG 
          |OUTPUT_IDF 
          |OUTPUT_STR 
          ;

OUTPUT_STR:v_string ;
OUTPUT_IDF:idf ;

CONDITIONAL:COND_IF CLOSE_IF {q[debIf-1].op1=IntToChar(indq);}
           |COND_IF_ELSE CLOSE_IF {q[thenIf].op2=IntToChar(indq);}
           ;

COND_IF:left_ar k_if col IF_COND_A right_ar left_ar k_then right_ar BLOCK_INST_THEN
;

IF_COND_A : EXPRESSION_LOGIQUE {quad("BZ","",$1.res,"");debIf=indq;}
;

BLOCK_INST_THEN:INSTRUCTION BLOCK_INST_THEN
               |CLOSE_THEN {thenIf=indq;q[debIf-1].op1=IntToChar(indq);}
               ;

CLOSE_IF:left_ar fw_slash k_if right_ar 
;

CLOSE_THEN:left_ar fw_slash k_then right_ar
;

COND_IF_ELSE:COND_IF_ELSE_A BLOCK_INST_ELSE
;

COND_IF_ELSE_A: COND_IF left_ar k_else right_ar {quad("BR","","","");q[debIf-1].op1=IntToChar(indq)}
;

BLOCK_INST_ELSE:INSTRUCTION BLOCK_INST_ELSE 
               |CLOSE_ELSE
               ;

CLOSE_ELSE:left_ar fw_slash k_else right_ar
;

DO_WHILE: OPEN_WHILE BLOCK_INST_DO {quad("BNZ",$1, q[indq-1].res, "");} 
;
OPEN_WHILE:left_ar k_do right_ar {$$=IntToChar(indq);}
;
BLOCK_INST_DO: INSTRUCTION BLOCK_INST_DO | CLOSE_DO 
;
CLOSE_DO: WHILE left_ar fw_slash k_do right_ar {$$=$1}
;
WHILE: left_ar k_while col EXPRESSION_LOGIQUE fw_slash right_ar {$$=$4.res}
;


FOR: left_ar k_for FOR_INIT  UNTIL right_ar BLOCK_INST_FOR;
FOR_INIT: idf eq v_integer{if(ExistDeclaration($1)==0){
  printf("erreur semantique [%d] : variable non declarer \"%s\"\n",lignes,$1);}}
;
UNTIL:k_until v_integer
     |k_until idf {if(ExistDeclaration($2)==0){
  printf("erreur semantique [%d] : variable non declarer \"%s\"\n",lignes,$2);}}
     ;


EXPRESSION_LOGIQUE:VALUE_BOOL {$$.res=BoolToString($1);}
                  |AND {$$.res=$1}
                  |OR {$$.res=$1}
                  |NOT {$$.res=$1}
                  |SUP {$$.res=$1}
                  |INF {$$.res=$1}
                  |SUPE{$$.res=$1}
                  |INFE{$$.res=$1}
                  |EGA{$$.res=$1}
                  |DIF{$$.res=$1}
                  ;

AND_ARG:EXPRESSION_LOGIQUE comma AND_ARG {if(strcmp($1.res, "FALSE")==0) $$.res="FALSE";else $$.res=$3.res;}
           |EXPRESSION_LOGIQUE comma EXPRESSION_LOGIQUE {
             if(strcmp($1.res, "FALSE")==0) $$.res="FALSE";
             else if(strcmp($1.res, "TRUE")==0) $$.res= $3.res;
             else {
               if(strcmp($3.res, "TRUE")==0) $$.res=$1.res;
               else if(strcmp($3.res, "FALSE")==0) $$.res = "FALSE";
               else {$$.res=temporaire(); quad("AND", $1.res, $3.res, $$.res);} 
             }
             }
           |IDF comma IDF {$$.res=temporaire(); quad("AND", $1, $3, $$.res);}
           |IDF comma AND_ARG {
             if(strcmp($3.res, "FALSE")==0) $$.res="FALSE";
             else if(strcmp($3.res, "TRUE")==0) $$.res = $1;
             else {$$.res=temporaire();quad("AND", $1, $3.res, $$.res);}
            }
           | IDF comma EXPRESSION_LOGIQUE {
            if(strcmp($3.res, "FALSE")==0) $$.res="FALSE";
            else if(strcmp($3.res, "TRUE")==0) $$.res=$1;
            else {$$.res=temporaire();quad("AND", $1, $3.res, $$.res);}
          }
          | EXPRESSION_LOGIQUE  comma IDF {
            if(strcmp($1.res, "FALSE")==0) $$.res="FALSE";
            else if(strcmp($1.res, "TRUE")==0) $$.res=$3;
            else {$$.res=temporaire();quad("AND", $1.res, $3, $$.res);}
          }
           ;
OR_ARG:EXPRESSION_LOGIQUE comma AND_ARG {if(strcmp($1.res, "TRUE")==0) $$.res="TRUE";else $$.res=$3.res;}
           |EXPRESSION_LOGIQUE comma EXPRESSION_LOGIQUE {
             if(strcmp($1.res, "TRUE")==0) $$.res="TRUE";
             else if(strcmp($1.res, "FALSE")==0) $$.res= $3.res;
             else {
               if(strcmp($3.res, "FALSE")==0) $$.res=$1.res;
               else if(strcmp($3.res, "TRUE")==0) $$.res = "TRUE";
               else {$$.res=temporaire(); quad("OR", $1.res, $3.res, $$.res);} 
             }
             }
           |IDF comma IDF {$$.res=temporaire(); quad("OR", $1, $3, $$.res);}
           |IDF comma AND_ARG {
             if(strcmp($3.res, "TRUE")==0) $$.res="TRUE";
             else if(strcmp($3.res, "FALSE")==0) $$.res = $1;
             else {$$.res=temporaire();quad("OR", $1, $3.res, $$.res);}
            }
           | IDF comma EXPRESSION_LOGIQUE {
            if(strcmp($3.res, "TRUE")==0) $$.res="TRUE";
            else if(strcmp($3.res, "FALSE")==0) $$.res=$1;
            else {$$.res=temporaire();quad("OR", $1, $3.res, $$.res);}
          }
          | EXPRESSION_LOGIQUE  comma IDF {
            if(strcmp($1.res, "TRUE")==0) $$.res="TRUE";
            else if(strcmp($1.res, "FALSE")==0) $$.res=$3;
            else {$$.res=temporaire();quad("OR", $1.res, $3, $$.res);}
          }
           ;


AND:and left_par AND_ARG right_par {$$=$3.res}
;
OR:or left_par OR_ARG right_par {$$=$3.res}
;
NOT:not left_par EXPRESSION_LOGIQUE right_par {
  if(strcmp($3.res, "FALSE")==0) $$="TRUE";
  else if (strcmp($3.res, "TRUE")==0) $$ ="FALSE";
  else {$$=temporaire(); quad("NOT", $3.res,"" , $$); printf("test\n");}
  }
   |not left_par IDF right_par {$$=temporaire(); quad("NOT", $3,"" , $$);}
;


EXPRESSION_ARITHMETIQUE:EXPRESSION_ARITHMETIQUE plus EXPRESSION_ARITHMETIQUE {$$.res=temporaire();quad ("+",$1.res,$3.res,$$.res);}
                        |EXPRESSION_ARITHMETIQUE dash EXPRESSION_ARITHMETIQUE {$$.res=temporaire();quad ("-",$1.res,$3.res,$$.res);}
                        |EXPRESSION_ARITHMETIQUE asterisk EXPRESSION_ARITHMETIQUE {$$.res=temporaire();quad ("*",$1.res,$3.res,$$.res);}
                        |EXPRESSION_ARITHMETIQUE fw_slash EXPRESSION_ARITHMETIQUE {$$.res=temporaire();quad ("/",$1.res,$3.res,$$.res);}
                        |left_par EXPRESSION_ARITHMETIQUE right_par {$$=$2;}
                        |IDF plus EXPRESSION_ARITHMETIQUE {isNumeric($1);$$.res=temporaire();quad ("+",$1,$3.res,$$.res);}
                        |IDF dash EXPRESSION_ARITHMETIQUE {isNumeric($1);$$.res=temporaire();quad ("-",$1,$3.res,$$.res);}
                        |IDF asterisk EXPRESSION_ARITHMETIQUE {isNumeric($1);$$.res=temporaire();quad ("*",$1,$3.res,$$.res);}
                        |IDF fw_slash EXPRESSION_ARITHMETIQUE {isNumeric($1);$$.res=temporaire();quad ("/",$1,$3.res,$$.res);}
                        |EXPRESSION_ARITHMETIQUE plus IDF {isNumeric($3);$$.res=temporaire();quad ("+",$1.res,$3,$$.res);}
                        |EXPRESSION_ARITHMETIQUE dash IDF {isNumeric($3);$$.res=temporaire();quad ("-",$1.res,$3,$$.res);}
                        |EXPRESSION_ARITHMETIQUE asterisk IDF {isNumeric($3);$$.res=temporaire();quad ("*",$1.res,$3,$$.res);}
                        |EXPRESSION_ARITHMETIQUE fw_slash IDF {isNumeric($3);$$.res=temporaire();quad ("/",$1.res,$3,$$.res);}
                        |v_integer {testRangInt($1,lignes,saveIdf);$$.res=IntToChar($1);}
                        |v_real {testRangFlt($1,lignes,saveIdf);$$.res=FltToChar($1);}
                        ;

IDF:idf {strcpy(saveIdf,$1);$$=$1;if(ExistDeclaration($1)==0){
  printf("erreur semantique [%d] : variable non declarer \"%s\"\n",lignes,$1);}}
    |IDF_TAB
    ;
IDF_TAB:idf left_bracket TAB_ARG right_bracket {$$=$1;strcpy(saveIdf,$1);if(ExistDeclaration($1)==0){
  printf("erreur semantique [%d] : variable non declarer \"%s\"\n",lignes,$1);}};
TAB_ARG:IDF 
       |v_integer {$$=IntToChar($1);}
       ;

AFF:left_ar k_aff col IDF comma AFF_ARG {if(csteDejaAff($4)==1){printf("erreur semantique [%d] : constante deja affecter \"%s\"\n",lignes,$4);}quad ("=",$6.res,"",$4);}
| left_ar k_aff col IDF comma IDF fw_slash right_ar {
  compatible($4, $6);
  if(csteDejaAff($4)==1)printf("erreur semantique [%d] : constante deja affecter \"%s\"\n",lignes,$4);
  quad ("=",$6,"",$4);
  }
;
AFF_ARG:EXPRESSION_ARITHMETIQUE fw_slash right_ar {isNumeric(saveIdf);$$.res=$1.res;}
       |EXPRESSION_LOGIQUE fw_slash right_ar {idfHasType(saveIdf, BOOL);$$.res=$1.res;}
       |v_string fw_slash right_ar {idfHasType(saveIdf, STRING);$$.res=transfertString($1);}
       |v_char fw_slash right_ar {idfHasType(saveIdf, CHAR);$$.res=CharToString($1);}
       ;

SUP: sup left_par {strcpy(saveOp, "SUP");} COMP_ARG right_par {$$=$4}
;

INF: inf left_par {strcpy(saveOp, "INF");} COMP_ARG right_par {$$=$4}
;
SUPE:supe left_par {strcpy(saveOp, "SUPE");} COMP_ARG right_par{$$=$4}
;
INFE:infe left_par {strcpy(saveOp, "INFE");} COMP_ARG right_par{$$=$4}
;
EGA:ega left_par {strcpy(saveOp, "EGA");} COMP_ARG right_par{$$=$4}
;
DIF:dif left_par {strcpy(saveOp, "DIF");} COMP_ARG right_par{$$=$4}
;

COMP_ARG:EXPRESSION_ARITHMETIQUE comma EXPRESSION_ARITHMETIQUE {$$=temporaire(); quad(strdup(saveOp), $1.res, $3.res, $$);}
        |IDF comma EXPRESSION_ARITHMETIQUE {$$=temporaire(); quad(strdup(saveOp), $1, $3.res, $$);}
        |IDF comma IDF {$$=temporaire(); quad(strdup(saveOp), $1, $3, $$);}
        |EXPRESSION_ARITHMETIQUE comma IDF {$$=temporaire(); quad(strdup(saveOp), $1.res, $3, $$);}
        ;





%%


int yywrap();

int main() {
   initialiter();
   initialiterListeIdf();
   initialiterListeCnst();
   initialiterListeIdfOut();
   yyparse();
   affiche();
   afficherQuad();
}

int yyerror(char * message) {
  printf("code:%d: %s\n", lignes, message);
  return 0;

}