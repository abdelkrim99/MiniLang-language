cd lexical
flex lexical.l
cd ../syntax
bison -d -v syntax.y
cd ../
gcc ./lexical/lex.yy.c ./syntax/syntax.tab.c ./tabsym/tabsym.c ./quad/quad.c ./optimisation/optimisation.c ./routines/routine.c  ./generation/generation.c -w -ll -ly -o compiler.exe
./compiler.exe<code.txt


