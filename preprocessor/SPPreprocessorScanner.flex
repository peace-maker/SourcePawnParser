package spbeaver.preprocessor; // The generated parser will belong to this package 

import spbeaver.preprocessor.SPPreprocessorParser.Terminals; 
// The terminals are implicitly defined in the parser
%%

// define the signature for the generated scanner
%public
%final
%class SPPreprocessorScanner 
%extends beaver.Scanner

// the interface between the scanner and the parser is the nextToken() method
%type beaver.Symbol 
%function nextToken 
%yylexthrow beaver.Scanner.Exception
%eofval{
    return new beaver.Symbol(Terminals.EOF, "end-of-file");
%eofval}

// store line and column information in the tokens
%line
%column

// this code will be inlined in the body of the generated scanner class
%{
  public void setCurrentLine(int line) {
    yyline = line;
  }
  private beaver.Symbol sym(short id) {
    return new beaver.Symbol(id, yyline + 1, yycolumn + 1, yylength(), yytext());
  }
  private beaver.Symbol sym(short id, Object value) {
    return new beaver.Symbol(id, yyline + 1, yycolumn + 1, yylength(), value);
  }
%}

LineTerminator = \r|\n|\r\n
InputCharacter = [^\r\n]
WhiteSpace     = {LineTerminator} | [ \t\f]

// Literals
DecimalLiteral   = [1-9][0-9_]* | 0
HexLiteral       = "0x" [0-9a-fA-F]+
//OctalLiteral     = 0 [0-7]+ // NO OCTALS IN PAWN :'(
IntegerLiteral   = {DecimalLiteral} | {HexLiteral}

EscapeCode       = \\ | (a|b|e|f|n|r|t|v) | x [0-9a-fA-F]{0,2} ;? | (\'|\"|\%) | [0-9]{1,3} ;?
StringLiteral    = \" ( [^\"\\\n\r] | \\ {EscapeCode} | \\ [ \t\f]* {LineTerminator})* \"

Identifier     = [a-zA-Z_][a-zA-Z0-9_]*

// Comment can be the last line of the file, without line terminator.
LineComment    = "//" {InputCharacter}* {LineTerminator}?
MultiComment   = "/*" ~"*/"

%%

// discard whitespace information and comments
{LineComment} { }
{MultiComment} { }
{WhiteSpace} { }

// Keywords
"define" { return sym(Terminals.DEFINE); }
"undef" { return sym(Terminals.UNDEFINE); }
"include" { return sym(Terminals.INCLUDE); }
"tryinclude" { return sym(Terminals.TRYINCLUDE); }
"endinput" { return sym(Terminals.ENDINPUT); }

"error" { return sym(Terminals.ERROR); }
"assert" { return sym(Terminals.ASSERT); }

"if" { return sym(Terminals.IF); }
"elseif" { return sym(Terminals.ELSEIF); }
"else" { return sym(Terminals.ELSE); }
"endif" { return sym(Terminals.ENDIF); }

"defined" { return sym(Terminals.DEFINED); }

"pragma" { return sym(Terminals.PRAGMA); }
"deprecated" { return sym(Terminals.DEPRECATED); }

// Separators
"(" { return sym(Terminals.LPAREN); }
")" { return sym(Terminals.RPAREN); }

// Operators
"<" { return sym(Terminals.LT); }
">" { return sym(Terminals.GT); }
"!" { return sym(Terminals.BANG); }
"~" { return sym(Terminals.TILDE); }
"+" { return sym(Terminals.PLUS); }
"-" { return sym(Terminals.MINUS); }
"*" { return sym(Terminals.STAR); }
"/" { return sym(Terminals.SLASH); }
"&" { return sym(Terminals.AMPERSAND); }
"|" { return sym(Terminals.BITOR); }
"^" { return sym(Terminals.BITXOR); }
"%" { return sym(Terminals.PERCENT); }
"==" { return sym(Terminals.EQ); }
"<=" { return sym(Terminals.LE); }
">=" { return sym(Terminals.GE); }
"!=" { return sym(Terminals.NE); }
"||" { return sym(Terminals.LOGICOR); }
"&&" { return sym(Terminals.LOGICAND); }
"<<" { return sym(Terminals.SHL); }
">>>" { return sym(Terminals.SHRU); }
">>" { return sym(Terminals.SHR); }

{IntegerLiteral} { return sym(Terminals.INTEGERLIT); }
{StringLiteral} { return sym(Terminals.STRINGLIT); }
{Identifier} { return sym(Terminals.IDENTIFIER); }

// fall through errors
[^] { return sym(Terminals.LITERAL); }
