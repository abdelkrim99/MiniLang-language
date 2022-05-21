#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "../quad/quad.h"
#include "optimisation.h"
#include <math.h>

extern int indq;
int redirect = 0;

void optimiser() {
  int changes, iter=0;
  
  do {
    changes =   propArth()+ propCopie()+eliminer();

    
    //printf("%d, %d, %d\n", propArth(), propCopie(), eliminer());
    iter ++;
  }while(changes > 0);

  printf("%d iterations\n", iter);
}

int nearBlockLine(int index) {
  int start=indq;
  while(index < indq) {
    if(q[index].opr!=NULL && q[index].opr[0]=='B'&& atoi(q[index].op1) < start)
      start = atoi(q[index].op1);
    index++;
  }
  return start;

}

int remplacer(char* temp1, char* temp2, int index){
  int change = 0;

  int block = nearBlockLine(index);

  while(index < block) {
    if(q[index].opr!= NULL && strcmp(q[index].opr, "=")==0 && strcmp(q[index].res, temp1)==0 )
      return change;
    if(update(temp1, temp2, index) == 1) {
      //printf("enters %d\n", index);
      change = 1;
      printf("%s par %s dans %d\n", temp1, temp2, index);
      //printf("update %s with %s line %d\n", temp1, temp2, index);
      //printf("from %d block %d\n", index,block);
    }
      

    index++;
  }
  
  return change;
}

int update(char * temp1, char *temp2 , int index) {
  if (q[index].opr!=NULL && strcmp(q[index].op1, "")!=0 && strcmp(q[index].op1, temp1)== 0) {

     q[index].op1 = temp2;
     return 1;
  }
     
     
    
    if (q[index].opr!=NULL &&strcmp(q[index].op2, "")!=0 && strcmp(q[index].op2, temp1)== 0) {
      
     q[index].op2 = temp2;
     return 1;
    }
    return 0;
    
   }


int propCopie() {
  int analyse = 0;
  int change = 0;
  while(analyse+1 < indq) {
    if (q[analyse].opr!=NULL && strcmp(q[analyse].opr, "=")==0) {

      if (remplacer(q[analyse].res, q[analyse].op1, analyse+1) == 1) change=1;
      

    }
    //printf("change %d from %d\n ", change, analyse);
    
    analyse ++;
  }
  //printf("last %d\n", analyse);
  return change;
  
  
  
}

int used(char*temp, int index) {

  int i=0;
  if(i >= indq) return 1;
  
  while(i < indq ) {

    if(i==index) {i++;continue;}
    if(q[i].opr!=NULL && strcmp(q[i].res, temp)==0) {
      return 1;
    }
    if(q[i].opr!=NULL && strcmp(q[i].op1, temp)==0 || q[i].opr!=NULL && strcmp(q[i].op2, temp)==0){

      return 0;
    }
      

    i++;
  }
  return 1;
  
}

int eliminer() {
  int analyse = 0;
  int change = 0;
  int count=0;


  while(analyse + 1< indq) {  
    if(q[analyse].opr!=NULL && strcmp(q[analyse].opr, "=")== 0 && used(q[analyse].res, analyse)!=0) {
      removeQuad(analyse); change = 1;
      count++;
      
    }
    analyse ++;

    
  }
  if(q[analyse].opr!=NULL && strcmp(q[analyse].opr, "=")==0) {
    removeQuad(analyse); int change = 1;count++;
  }
  
    

    corrigerBranch();
   printf("\n\n");
  //printf("%d eliminations\n", count);
  return change;
}

void corrigerBranch() {
  int branch=0;
  while(branch < indq) {
    if (q[branch].opr!=NULL && q[branch].opr[0] == 'B') {
      int etiq = atoi(q[branch].op1);
      
      
      while(etiq < indq && q[etiq].opr == NULL) {
        
        etiq++;
        }
      sprintf(q[branch].op1, "%d", etiq);
      
    }
    branch++;
  }
}

int isNumber(char *s)
{
  int i=0;

  while(s[i] != '\0')
  {

    if (s[i] == '.')
    {
      return (2);
    }

    if (isdigit(s[i]) == 0)
      return(0);

    

    i++;
  }

  return(1);
  
}

int propArth(){
  int ind=0;
  int change= 0;
  while(ind<indq){
    if(q[ind].opr != NULL) {
      if ((strcmp(q[ind].opr, "+") == 0) && (isNumber(q[ind].op1) == 1) && (isNumber(q[ind].op2) == 1))
      {
        sprintf(q[ind].op1, "%d", atoi(q[ind].op2) + atoi(q[ind].op1));
        q[ind].op2="";
        q[ind].opr = "=";
        change = 1;
      }

          if ((strcmp(q[ind].opr, "+") == 0) && (isNumber(q[ind].op1) == 2) && (isNumber(q[ind].op2) == 2))
      {
        sprintf(q[ind].op1, "%.2f", atof(q[ind].op2) + atof(q[ind].op1));

        q[ind].op2 = "";
        q[ind].opr = "=";
        change = 1;
      }
    }
    ind++;
  }
  return change;
}