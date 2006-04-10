%option noyywrap align never-interactive prefix="voneline"
%{
/* $Id$
 ******************************************************************************
 * DESCRIPTION: voneline: Convert Verilog gates to one-line-per-instance
 * 
 * Author: Wilson Snyder <wsnyder@wsnyder.org> or <wsnyder@iname.com>
 * 
 * Code available from: http://www.veripool.com/vl
 * 
 ******************************************************************************
 * 
 * Copyright 1998-2006 by Wilson Snyder.  This program is free software; you can
 * redistribute it and/or modify it under the terms of either the GNU
 * General Public License or the Perl Artistic License.
 *
 * This Package is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 *****************************************************************************/

#include "config.h"

int Opt_Width = 0;
int Cur_Column = 0;

%}

%x CMTMODE
%x INSTMODE

WHITESPACE	[ \t\r]
NEWLINE		[\n]
WHITENL		[ \t\r\n]
%%

{NEWLINE}+     		{ printf ("\n"); Cur_Column=0; }
{WHITESPACE}+		{ printf (" "); }
"//".*[\n]     		{ ECHO; Cur_Column=0; }
"/*"	       		{ ECHO; BEGIN(CMTMODE); }
"endmodule"		{ ECHO; }
[a-zA-Z]		{ ECHO; BEGIN(INSTMODE); }
.	       		{ ECHO; }

<CMTMODE>"*"+[^*/\n]* 	{ ECHO; }
<CMTMODE>"*"+"/"	{ ECHO; BEGIN(INITIAL); }
<CMTMODE>. 		{ ECHO; }

<INSTMODE>"//"[^\n]*[\n] 	{ ECHO; Cur_Column=0; }
<INSTMODE>{WHITENL}+	{ printf (" "); Cur_Column+=1; }
<INSTMODE>;	 	{ ECHO; BEGIN(INITIAL); Cur_Column+=yyleng; }
<INSTMODE>,	 	{ if (Opt_Width && Cur_Column > Opt_Width) {
			       printf("\n "); Cur_Column = 1;
			  }
			  ECHO; Cur_Column+=yyleng; }
<INSTMODE>[^,;\n \t]* 	{ ECHO; Cur_Column+=yyleng; }

%%

void version() {
    fprintf(stderr, "voneline %s\n",VERSION);
}

void help() {
    version();
    fprintf (stderr, "Usage: [--version] [--debug] [--width #] <IN >OUT\n");
    fprintf (stderr, "Distributed from http://www.veripool.com\n");
}

int main (int argc, const char *argv[]) {
    int arg;
    for (arg=1; arg<argc; arg++) {
	const char* ap = argv[arg];
	if (ap[0]=='-' && ap[1]=='-') ap++;
	if (0==strcmp (ap, "-debug")) {
	} else if (0==strcmp (ap, "-help")) {
	    help();
	    exit(0);
	} else if (0==strcmp (ap, "-version")) {
	    version();
	    exit(0);
	} else if (0==strcmp (ap, "-width") && argc>=1) {
            arg++;
	    Opt_Width = atoi(argv[arg]);
	} else {
	    fprintf(stderr, "%%Error: Unknown option %s\n", argv[arg]);
	    help();
	    exit(0);
	}
    }

    yylex();
    printf ("\n");
    return(0);
}
