
%{
 #include "../syntax/syntax.tab.h"
 #include "../tabsym/tabsym.h"
 #include "../quad/quad.h"
 #include "../optimisation/optimisation.h"
 #include <string.h>
 extern int lignes;
 extern YYSTYPE yylval;

%}

%option noyywrap

lettre [a-zA-Z]
chiffre [0-9]
idf {lettre}({lettre}|{chiffre}|_({lettre}|{chiffre})+)*

string ["]([^"])*["]
entier_ns (0|[1-9]{chiffre}*)
reel_ns ([0][.]{chiffre}+|[1-9]{chiffre}*[.]{chiffre}+)
char ['](.)[']

entier_s ([(][-]{entier_ns}[)])
reel_s [(][-]{reel_ns}[)]


%%

"<" {return left_ar;}
">" {return right_ar;}
"/" {return fw_slash;}
"!" {return excl;}
":" {return col;}
"(" {return left_par;}
")" {return right_par;}
"[" {return left_bracket;}
"]" {return right_bracket;}
"|" {return bar;}
"=" {return eq;}
";" {return semi_col;}
"+" {return plus;}
"-" {return dash;}
"*" {return asterisk;}
"," {return comma;}
INT {return t_int;}
FLT {return t_float;}
BOL {return t_boolean;}
CHR {return t_char;}
STR {return t_string;}
TRUE {
  yylval.integer = 1;
  return v_true;}
FALSE {
  yylval.integer = 0;
  return v_false;}

{entier_ns} { 
    yylval.integer= atoi(yytext);
    return v_integer;
  }

{entier_s} {
    yylval.integer= atoi(sansParentheses(yytext));
    return v_integer;
    }


{reel_ns} {
   if(verifierReelNonSigne(yytext, strlen(yytext))==0) {
      yylval.real = atof(yytext);
      return v_real;
   }
  }
  
{reel_s} {
  if(verifierReelSigne(yytext, strlen(yytext))==0) {
      yylval.real = atof(sansParentheses(yytext));
      return v_real;
   }
}
{string} {
  yylval.string = strdup(yytext);
  return v_string;}

{char} {
    yylval.ch = yytext[1];

    return v_char;
  }

docprogram {return k_docprogram;}
AS {return k_as;}
ARRAY {return k_array;}
SUB {return k_sub;} 
body {return k_body;}
VARIABLE {return k_variable;}
CONSTANTE {return k_const;}
AFF {return k_aff;}
INPUT {return k_input;}
OUTPUT {return k_output;}
AND {return and;}
OR {return or;}
NOT {return not;}
SUP {return sup;}
INF {return inf;}
SUPE {return supe;}
INFE {return infe;}
EGA {return ega;}
DIF {return dif;}
IF {return k_if;} 
THEN {return k_then;}
ELSE {return k_else;}
DO {return k_do;}
WHILE {return k_while;}
FOR {return k_for;}
UNTIL {return k_until;}
{idf} {
  if(ExistDeclarationT(yytext)==-1) {
    inserer(yytext,"idf");
  }
  yylval.string = strdup(yytext);
  return idf;}

[ \t]
[\n] lignes++;
. {
  printf("code:%d: error: token \" %s \" unrecognized\n",lignes,yytext); return err;}

%%



