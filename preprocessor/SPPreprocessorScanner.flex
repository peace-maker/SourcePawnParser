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
FloatLiteral     = [0-9]+ "." [0-9]+ ( e "-"? [0-9]+)?

EscapeCode       = \\ | (a|b|e|f|n|r|t|v) | x [0-9a-fA-F]{0,2} ;? | (\'|\"|\%) | [0-9]{1,3} ;?
CharacterLiteral = \' ( [^\'\\\n\r] | \\ {EscapeCode} ) \'
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
"include" { return sym(Terminals.INCLUDE); }
"endinput" { return sym(Terminals.ENDINPUT); }

//"if" { return sym(Terminals.IF); }
//"else" { return sym(Terminals.ELSE); }
//"endif" { return sym(Terminals.ENDIF); }

//"defined" { return sym(Terminals.DEFINED); }

"<" { return sym(Terminals.LT); }
">" { return sym(Terminals.GT); }

{IntegerLiteral} { return sym(Terminals.INTEGERLIT); }
{FloatLiteral} { return sym(Terminals.FLOATLIT); }
{CharacterLiteral} { return sym(Terminals.CHARLIT); }
{StringLiteral} { return sym(Terminals.STRINGLIT); }
{Identifier} { return sym(Terminals.IDENTIFIER); }

// fall through errors
[^] { return sym(Terminals.LITERAL); }
