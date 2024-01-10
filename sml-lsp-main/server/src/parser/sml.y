%{
  #include <stdio.h>
  #include <stdlib.h>
  #include <string.h>

  int position = -1;
  char *result;
%}

%union {
  char *res;
  int int_value;
  char *id_value;
  struct exp *exp;
  struct appexp *appexp;
  struct atexp *atexp;
  struct dec *dec;
  struct patset *patset;
}

%token <id_value> ID IDCURSOR
%token <int_value> NUM
%token LET VAL IN END FN FUN RA

%type<res> exp
%type<res> appexp
%type<res> atexp
%type<res> dec
%type<res> args
%type<res> patset
%type<res> pat

%%

start
: exp
{
  result = malloc(sizeof(result) * (strlen($1)+100));
  sprintf(result, "{\"tag\":\"START\",\"exp\":%s}", $1);
  free($1);
}

exp
: appexp
{
  char *buf;
  buf = malloc(sizeof(char) * (strlen($1)+100));
  sprintf(buf, "{\"tag\":\"EXP1\",\"appexp\":%s}", $1);
  free($1);
  $$ = buf;
}
| FN ID RA exp
{
  char *buf;
  buf = malloc(sizeof(char) * (strlen($2)+strlen($4)+100));
  sprintf(buf, "{\"tag\":\"EXP2\",\"id\":\"%s\",\"exp\":%s}", $2, $4);
  free($2);
  free($4);
  $$ = buf;
}

appexp
: atexp
{
  char *buf;
  buf = malloc(sizeof(char) * (strlen($1)+100));
  sprintf(buf, "{\"tag\":\"APPEXP1\",\"atexp\":%s}", $1);
  free($1);
  $$ = buf;
}
| appexp atexp
{
  char *buf;
  buf = malloc(sizeof(char) * (strlen($1)+strlen($2)+100));
  sprintf(buf, "{\"tag\":\"APPEXP2\",\"appexp\":%s,\"atexp\":%s}", $1, $2);
  free($1);
  free($2);
  $$ = buf;
}

atexp
: ID
{
  char *buf;
  buf = malloc(sizeof(char) * (strlen($1)+100));
  sprintf(buf, "{\"tag\":\"ATEXP1\",\"id\":\"%s\"}", $1);
  free($1);
  $$ = buf;
}
| IDCURSOR
{
  char *buf;
  buf = malloc(sizeof(char) * (strlen($1)+100));
  sprintf(buf, "{\"tag\":\"ATEXP1_2\",\"idcursor\":\"%s\"}", $1);
  free($1);
  $$ = buf;
}
| NUM
{
  char *buf;
  buf = malloc(sizeof(char) * (100));
  sprintf(buf, "{\"tag\":\"ATEXP2\",\"num\":%d}", $1);
  $$ = buf;
}
| '(' exp ')'
{
  char *buf;
  buf = malloc(sizeof(char) * (strlen($2)+100));
  sprintf(buf, "{\"tag\":\"ATEXP3\",\"exp\":%s}", $2);
  free($2);
  $$ = buf;
}
| exp ')'
{
  char *buf;
  buf = malloc(sizeof(char) * (strlen($1)+100));
  sprintf(buf, "{\"tag\":\"ATEXP4\",\"exp\":%s}", $1);
  free($1);
  $$ = buf;
}
| '(' exp
{
  char *buf;
  buf = malloc(sizeof(char) * (strlen($2)+100));
  sprintf(buf, "{\"tag\":\"ATEXP5\",\"exp\":%s}", $2);
  free($2);
  $$ = buf;
}
| '('')'
{
  char *buf;
  buf = malloc(sizeof(char) * (100));
  sprintf(buf, "{\"tag\":\"ATEXP6\"}");
  $$ = buf;
}
| LET dec IN exp END
{
  char *buf;
  buf = malloc(sizeof(char) * (strlen($2)+strlen($4)+100));
  sprintf(buf, "{\"tag\":\"ATEXP7\",\"dec\":%s,\"exp\":%s}", $2, $4);
  free($2);
  free($4);
  $$ = buf;
}
| LET dec error
{
  char *buf;
  buf = malloc(sizeof(char) * (strlen($2)+100));
  sprintf(buf, "{\"tag\":\"ATEXP8\",\"dec\":%s,\"error\":\"NULL\"}", $2);
  free($2);
  $$ = buf;
}
| LET dec IN exp error
{
  char *buf;
  buf = malloc(sizeof(char) * (strlen($2)+strlen($4)+100));
  sprintf(buf, "{\"tag\":\"ATEXP9\",\"dec\":%s,\"exp\":%s}", $2, $4);
  free($2);
  free($4);
  $$ = buf;
  yyerrok;
}

dec
: VAL ID '=' exp
{
  char *buf;
  buf = malloc(sizeof(char) * (strlen($2)+strlen($4)+100));
  sprintf(buf, "{\"tag\":\"DEC1\",\"id\":\"%s\",\"exp\":%s}", $2, $4);
  free($2);
  free($4);
  $$ = buf;
}
| VAL error
{
  char *buf;
  buf = malloc(sizeof(char) * 100);
  sprintf(buf, "{\"tag\":\"DEC2\",\"error\":\"NULL\"}");
  $$ = buf;
}
| VAL ID error
{
  char *buf;
  buf = malloc(sizeof(char) * (strlen($2)+100));
  sprintf(buf, "{\"tag\":\"DEC3\",\"id\":\"%s\"}", $2);
  free($2);
  $$ = buf;
}
| FUN ID args '=' exp
{
  char *buf;
  buf = malloc(sizeof(char) * (strlen($2)+strlen($3)+strlen($5)+100));
  sprintf(buf, "{\"tag\":\"DEC4\",\"id\":\"%s\",\"args\":[%s],\"exp\":%s}", $2, $3, $5);
  free($2);
  free($3);
  free($5);
  $$ = buf;
}
| FUN ID  args ',' args '=' exp
{
  char *buf;
  buf = malloc(sizeof(char) * (strlen($2)+strlen($3)+strlen($5)+strlen($7)+100));
  sprintf(buf, "{\"tag\":\"DEC100\",\"id\":\"%s\",\"args\":[%s],\"args\":[%s],\"exp\":%s}", $2, $3, $5, $7);
  free($2);
  free($3);
  free($5);
  free($7);
  $$ = buf;
} 
| FUN ID  patset
{
  char *buf;
  buf = malloc(sizeof(char) * (strlen($2)+strlen($3)+100));
  sprintf(buf, "{\"tag\":\"DEC300\",\"id\":\"%s\",\"patset\":%s}", $2, $3);
  free($2);
  free($3);
  $$ = buf;
} 
| FUN ID  args ','
{
  char *buf;
  buf = malloc(sizeof(char) * (strlen($2)+strlen($3)+100));
  sprintf(buf, "{\"tag\":\"DEC500\",\"id\":\"%s\",\"args\":[%s]}", $2, $3);
  free($2);
  free($3);
  $$ = buf;
} 
| FUN ID '(' args ',' args ')' '=' exp
{
  char *buf;
  buf = malloc(sizeof(char) * (strlen($2)+strlen($4)+strlen($6)+strlen($9)+100));
  sprintf(buf, "{\"tag\":\"DEC200\",\"id\":\"%s\",\"args\":[%s],\"args\":[%s],\"exp\":%s}", $2, $4, $6, $9);
  free($2);
  free($4);
  free($6);
  free($9);
  $$ = buf;
}  
| FUN ID '(' args ',' args ')'
{
  char *buf;
  buf = malloc(sizeof(char) * (strlen($2)+strlen($4)+strlen($6)+100));
  sprintf(buf, "{\"tag\":\"DEC400\",\"id\":\"%s\",\"args\":[%s],\"args\":[%s]}", $2, $4, $6);
  free($2);
  free($4);
  free($6);
  $$ = buf;
} 
| FUN ID '(' args ','
{
  char *buf;
  buf = malloc(sizeof(char) * (strlen($2)+strlen($4)+100));
  sprintf(buf, "{\"tag\":\"DEC600\",\"id\":\"%s\",\"args\":[%s]}", $2, $4);
  free($2);
  free($4);
  $$ = buf;
} 
| FUN ID '(' args
{
  char *buf;
  buf = malloc(sizeof(char) * (strlen($2)+strlen($4)+100));
  sprintf(buf, "{\"tag\":\"DEC900\",\"id\":\"%s\",\"args\":[%s]}", $2, $4);
  free($2);
  free($4);
  $$ = buf;
} 
| FUN ID '('
{
  char *buf;
  buf = malloc(sizeof(char) * (strlen($2)+100));
  sprintf(buf, "{\"tag\":\"DEC1000\",\"id\":\"%s\"}", $2);
  free($2);
  $$ = buf;
} 
| FUN ID error
{
  char *buf;
  buf = malloc(sizeof(char) * (strlen($2)+100));
  sprintf(buf, "{\"tag\":\"DEC1200\",\"id\":\"%s\"}", $2);
  free($2);
  $$ = buf;
} 
| FUN ID args
{
  char *buf;
  buf = malloc(sizeof(char) * (strlen($2)+strlen($3)+100));
  sprintf(buf, "{\"tag\":\"DEC1100\",\"id\":\"%s\",\"args\":[%s]}", $2, $3);
  free($2);
  free($3);
  $$ = buf;
} 
| FUN ID '(' args ',' args
{
  char *buf;
  buf = malloc(sizeof(char) * (strlen($2)+strlen($4)+strlen($6)+100));
  sprintf(buf, "{\"tag\":\"DEC700\",\"id\":\"%s\",\"args\":[%s],\"args\":[%s]}", $2, $4, $6);
  free($2);
  free($4);
  free($6);
  $$ = buf;
} 
| FUN ID args',' args ')'
{
  char *buf;
  buf = malloc(sizeof(char) * (strlen($2)+strlen($3)+strlen($5)+100));
  sprintf(buf, "{\"tag\":\"DEC800\",\"id\":\"%s\",\"args\":[%s],\"args\":[%s]}", $2, $3, $5);
  free($2);
  free($3);
  free($5);
  $$ = buf;
} 
| FUN ID error '=' exp
{
  char *buf;
  buf = malloc(sizeof(char) * (strlen($2)+100));
  sprintf(buf, "{\"tag\":\"DEC5\",\"id\":\"%s\"}", $2);
  free($2);
  $$ = buf;
}
| error
{
  char *buf;
  buf = malloc(sizeof(char) * 100);
  sprintf(buf, "{\"tag\":\"DEC6\"}");
  $$ = buf;
}

args
: args ID
{
  char *buf;
  buf = malloc(sizeof(char) * (strlen($1)+strlen($2)+100));
  sprintf(buf,"%s,{\"id\":\"%s\"}", $1, $2);
  free($1);
  free($2);
  $$ = buf;
}
| ID
{
  char *buf;
  buf = malloc(sizeof(char) * (strlen($1)+100));
  sprintf(buf, "{\"id\":\"%s\"}", $1);
  free($1);
  $$ = buf;
}

patset
: ID ',' pat
{
  char *buf;
  buf = malloc(sizeof(char) * (strlen($1)+strlen($3)+100));
  sprintf(buf, "{\"tag\":\"PATSET\",\"id\":\"%s\",\"pat\":%s}", $1, $3);
  free($1);
  free($3);
  $$ = buf;
}


pat
: ID
{
  char *buf;
  buf = malloc(sizeof(char) * (strlen($1)+100));
  sprintf(buf, "{\"tag\":\"PAT\",\"id\":\"%s\"}", $1);
  free($1);
  $$ = buf;
}

%%

int yyerror(char *msg) {
  fprintf(stderr, "エラーが発生しました%s\n", msg);
  return 0;
}

int main(int argc, char *argv[]) {
  extern int yyparse(void);
  extern FILE *yyin;

  position = atoi(argv[1]);

  yyin = stdin;
  
  if (yyparse()) {
    fprintf(stderr, "Error!\n");
    exit(1);
  }
  printf(result);
}