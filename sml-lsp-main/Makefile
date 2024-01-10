all:
	npm install
	cd server/src/parser && lex sml.l && yacc -d sml.y && gcc -w -Wall -g y.tab.c lex.yy.c -o ../../out/parse -lfl
