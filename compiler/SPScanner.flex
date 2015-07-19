package spbeaver; // The generated parser will belong to this package 

import spbeaver.SPParser.Terminals; 
// The terminals are implicitly defined in the parser
%%

// define the signature for the generated scanner
%public
%final
%class SPScanner 
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
Label          = {Identifier} :

// Comment can be the last line of the file, without line terminator.
LineComment    = "//" {InputCharacter}* {LineTerminator}?
MultiComment   = "/*" ~"*/"

Preprocessor   = # {InputCharacter}* {LineTerminator}?

%%

// discard whitespace information and comments
{LineComment} { }
{MultiComment} { }
{WhiteSpace} { }
{Preprocessor} { }

// Keywords
"aquire" | // R
"as" | // R
"assert" | // R
"begin" | // R *begin
"builtin" | // R
"catch" | // R
"cast_to" | // R
"double" | // R
"defined" | // R
"end" | // R *end
"exit" | // R
"explicit" | // R
"finally" | // R
"foreach" | // R
"implicit" | // R
"import" | // R
"in" | // R
"int8" | // R
"int16" | // R
"int32" | // R
"int64" | // R
"interface" | // R
"intn" | // R
"let" | // R
"namespace" | // R
"object" | // R
"package" | // R
"private" | // R
"protected" | // R
"readonly" | // R
"sealed" | // R
"sleep" | // R
"then" | // R *then
"throw" | // R
"try" | // R
"typeof" | // R
"uint8" | // R
"uint16" | // R
"uint32" | // R
"uint64" | // R
"uintn" | // R
"union" | // R
"using" | // R
"var" | // R
"variant" | // R
"virtual" | // R
"with" { /*return sym(Terminals.RESERVED);*/ } // R

"break" { return sym(Terminals.BREAK); }
"case" { return sym(Terminals.CASE); }
//"cellsof" { return sym(Terminals.CELLSOF); }
"const" { return sym(Terminals.CONST); }
"continue" { return sym(Terminals.CONTINUE); }
"decl" { return sym(Terminals.DECL); }
"default" { return sym(Terminals.DEFAULT); }
"do" { return sym(Terminals.DO); }
"else" { return sym(Terminals.ELSE); }
"enum" { return sym(Terminals.ENUM); }
"false" { return sym(Terminals.FALSE); }
"for" { return sym(Terminals.FOR); }
"forward" { return sym(Terminals.FORWARD); }
"funcenum" { return sym(Terminals.FUNCENUM); }
"functag" { return sym(Terminals.FUNCTAG); }
//"function" { return sym(Terminals.FUNCTION); }
//"goto" { return sym(Terminals.GOTO); }
"if" { return sym(Terminals.IF); }
"native" { return sym(Terminals.NATIVE); }
"new" { return sym(Terminals.NEW); }
//"operator" { return sym(Terminals.OPERATOR); }
"public" { return sym(Terminals.PUBLIC); }
"return" { return sym(Terminals.RETURN); }
"sizeof" { return sym(Terminals.SIZEOF); }
"stock" { return sym(Terminals.STOCK); }
"struct" { return sym(Terminals.STRUCT); }
"switch" { return sym(Terminals.SWITCH); }
//"tagof" { return sym(Terminals.TAGOF); }
"static" { return sym(Terminals.STATIC); }
"true" { return sym(Terminals.TRUE); }
"while" { return sym(Terminals.WHILE); }

//"char" { return sym(Terminals.CHAR); } // NEW
//"delete" { return sym(Terminals.DELETE); } // NEW
//"float" { return sym(Terminals.FLOAT); } // NEW
//"int" { return sym(Terminals.INT); } // NEW
//"methodmap" { return sym(Terminals.METHODMAP); } // NEW
//"null" { return sym(Terminals.NULL); } // NEW
//"__nullable__" { return sym(Terminals.NULLABLE); } // NEW
//"this" { return sym(Terminals.THIS); } // NEW
//"typedef" { return sym(Terminals.TYPEDEF); } // NEW
//"typeset" { return sym(Terminals.TYPESET); } // NEW
//"view_as" { return sym(Terminals.VIEWAS); } // NEW

// Separators
"(" { return sym(Terminals.LPAREN); }
")" { return sym(Terminals.RPAREN); }
"{" { return sym(Terminals.LBRACE); }
"}" { return sym(Terminals.RBRACE); }
"[" { return sym(Terminals.LBRACKET); }
"]" { return sym(Terminals.RBRACKET); }
";" { return sym(Terminals.SEMICOLON); }
"," { return sym(Terminals.COMMA); }
//"." { return sym(Terminals.DOT); }

// Operators
"=" { return sym(Terminals.ASSIGN); }
"<" { return sym(Terminals.LT); }
">" { return sym(Terminals.GT); }
"!" { return sym(Terminals.BANG); }
"~" { return sym(Terminals.TILDE); }
"?" { return sym(Terminals.QMARK); }
":" { return sym(Terminals.COLON); }
"+" { return sym(Terminals.PLUS); }
"-" { return sym(Terminals.MINUS); }
"*" { return sym(Terminals.STAR); }
"/" { return sym(Terminals.SLASH); }
"&" { return sym(Terminals.AMPERSAND); }
"|" { return sym(Terminals.BITOR); }
"^" { return sym(Terminals.BITXOR); }
"%" { return sym(Terminals.PERCENT); }
"+=" { return sym(Terminals.ASSIGN_ADD); }
"-=" { return sym(Terminals.ASSIGN_SUB); }
"*=" { return sym(Terminals.ASSIGN_MUL); }
"/=" { return sym(Terminals.ASSIGN_DIV); }
"%=" { return sym(Terminals.ASSIGN_MOD); }
"&=" { return sym(Terminals.ASSIGN_BITAND); }
"|=" { return sym(Terminals.ASSIGN_BITOR); }
"^=" { return sym(Terminals.ASSIGN_BITXOR); }
">>=" { return sym(Terminals.ASSIGN_SHR); }
">>>=" { return sym(Terminals.ASSIGN_SHRU); }
"<<=" { return sym(Terminals.ASSIGN_SHL); }
"==" { return sym(Terminals.EQ); }
"<=" { return sym(Terminals.LE); }
">=" { return sym(Terminals.GE); }
"!=" { return sym(Terminals.NE); }
"||" { return sym(Terminals.LOGICOR); }
"&&" { return sym(Terminals.LOGICAND); }
"<<" { return sym(Terminals.SHL); }
">>>" { return sym(Terminals.SHRU); }
">>" { return sym(Terminals.SHR); }
"++" { return sym(Terminals.INC); }
"--" { return sym(Terminals.DEC); }
"..." { return sym(Terminals.ELLIPSES); }
//".." { return sym(Terminals.DOUBLEDOT); }
//"::" { return sym(Terminals.DOUBLECOLON); }

{IntegerLiteral} { return sym(Terminals.INTEGERLIT); }
{FloatLiteral} { return sym(Terminals.FLOATLIT); }
{CharacterLiteral} { return sym(Terminals.CHARLIT); }
{StringLiteral} { return sym(Terminals.STRINGLIT); }
{Label} { return sym(Terminals.LABEL); }
{Identifier} { return sym(Terminals.IDENTIFIER); }

// fall through errors
[^] { throw new beaver.Scanner.Exception("illegal character \"" + yytext() + "\" at line " + yyline + "," + yycolumn); }
