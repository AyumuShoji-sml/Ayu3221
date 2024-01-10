%{
  #include <stdio.h>
  #include <stdlib.h>
  #include "y.tab.h"
  #define DEBUG 0

  extern int position;
  int num_chars = 0;
%}

%%

"let" {
  num_chars += yyleng;
  if (DEBUG) {
    printf("LET ");
  }
  return (LET);
}

"in" {
  num_chars += yyleng;
  if (DEBUG) {
    printf("IN ");
  }
  return (IN);
}

"end" {
  num_chars += yyleng;
  if (DEBUG) {
    printf("END ");
  }
  return (END);
}

"val" {
  num_chars += yyleng;
  if (DEBUG) {
    printf("VAL ");
  }
  return (VAL);
}

"fn" {
  num_chars += yyleng;
  if (DEBUG) {
    printf("FN ");
  }
  return (FN);
}

"fun" {
  num_chars += yyleng;
  if (DEBUG) {
    printf("FUN ");
  }
  return (FUN);
}

"=>" {
  num_chars += yyleng;
  if (DEBUG) {
    printf("ARROW ");
  }  
  return (RA);
}



"=" {
  num_chars += yyleng;
  if (DEBUG) {
    printf("EQUAL ");
  }
  return ('=');
}

"," {
  num_chars += yyleng;
  if (DEBUG) {
    printf("COMMA ");
  }
  return (',');
}

"(" {
  num_chars += yyleng;
  if (DEBUG) {
    printf("( ");
  }
  return ('(');
}

")" {
  num_chars += yyleng;
  if (DEBUG) {
    printf(") ");
  }
  return (')');
}

"\eof" {
  if (DEBUG) {
    printf("EOF ");
  }
  return (EOF);
}

[a-zA-Z][a-zA-Z0-9]* {
  num_chars += yyleng;
  yylval.id_value = malloc(strlen(yytext) + 1);
  sprintf(yylval.id_value, "%s", yytext);
  if (position != -1 && num_chars == position) {
    if (DEBUG) {
      printf("IDCURSOR(%s) ", yytext);
    }
    return (IDCURSOR);
  } else {
    if (DEBUG) {
      printf("ID(%d) ", yytext);
    }
    return (ID);
  }
}



[0-9][0-9]* {
  num_chars += yyleng;
  sscanf(yytext, "%d", &yylval.int_value);
  if (DEBUG) {
    printf("CONST(%s) ", yytext);    
  }
  return (NUM);
}

[ \n\t]+ {
  num_chars += yyleng;
}

%%
