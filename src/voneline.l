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

%}

%x CMTMODE
%x INSTMODE

WHITESPACE	[ \t\r]
NEWLINE		[\n]
WHITENL		[ \t\r\n]
%%

{NEWLINE}+     	{ printf ("\n"); }
{WHITESPACE}+	{ printf (" "); }
"//".*[\n]     	{ ECHO; }
"/*"	       	{ ECHO; BEGIN(CMTMODE); }
"endmodule"	{ ECHO; }
[a-zA-Z]	{ ECHO; BEGIN(INSTMODE); }

.	       		{ ECHO; }

<CMTMODE>"*"+[^*/\n]* 	{ ECHO; }
<CMTMODE>"*"+"/"	{ ECHO; BEGIN(INITIAL); }
<CMTMODE>. 		{ ECHO; }

<INSTMODE>"//"[^\n]*[\n] 	{ ECHO; }
<INSTMODE>[^;\n \t]* 	{ ECHO; }
<INSTMODE>{WHITENL}+	{ printf (" "); }
<INSTMODE>;	 	{ ECHO; BEGIN(INITIAL); }

%%

int main()
{
    yylex();
    printf ("\n");
    return(0);
}
