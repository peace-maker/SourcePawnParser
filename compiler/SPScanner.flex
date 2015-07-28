package spbeaver.parser; // The generated parser will belong to this package 

import spbeaver.parser.SPParser.Terminals; 
import spbeaver.preprocessor.PreprocessorHandler;
import spbeaver.preprocessor.Statement;
import spbeaver.preprocessor.Include;
import java.util.Stack;
import java.io.FileReader;
// The terminals are implicitly defined in the parser
%%

// define the signature for the generated scanner
%public
%final
%class SPScanner 
%extends beaver.Scanner

// the interface between the scanner and the parser is the nextToken() method
%type beaver.Symbol 
%function nextTokenReal 
%yylexthrow beaver.Scanner.Exception
%eofval{
	return new beaver.Symbol(Terminals.EOF, "end-of-file");
%eofval}

// store line and column information in the tokens
%line
%column

// this code will be inlined in the body of the generated scanner class
%{
  private Stack<SPScanner> stackedScanners = new Stack<>();
  
  // Save the current state
  public void pushCurrentScannerState(boolean include) {
    SPScanner cur = new SPScanner(zzReader);
    cur.isIncludeScanner = include;
    cur.zzState = zzState;
    cur.zzLexicalState = zzLexicalState;
    char newBuffer[] = new char[zzBuffer.length];
    System.arraycopy(zzBuffer, 0, newBuffer, 0, zzBuffer.length);
    cur.zzBuffer = newBuffer;
    cur.zzMarkedPos = zzMarkedPos;
    cur.zzPushbackPos = zzPushbackPos;
    cur.zzCurrentPos = zzCurrentPos;
    cur.zzStartRead = zzStartRead;
    cur.zzEndRead = zzEndRead;
    cur.yyline = yyline;
    cur.yychar = yychar;
    cur.yycolumn = yycolumn;
    cur.zzAtBOL = zzAtBOL;
    cur.zzAtEOF = zzAtEOF;
    stackedScanners.push(cur);
  }
  
  // Reapply the last state from the stack.
  public boolean popScannerState() {
    SPScanner last = stackedScanners.pop();
    zzReader = last.zzReader;
    zzState = last.zzState;
    zzLexicalState = last.zzLexicalState;
    zzBuffer = last.zzBuffer;
    zzMarkedPos = last.zzMarkedPos;
    zzPushbackPos = last.zzPushbackPos;
    zzCurrentPos = last.zzCurrentPos;
    zzStartRead = last.zzStartRead;
    zzEndRead = last.zzEndRead;
    yyline = last.yyline;
    yychar = last.yychar;
    yycolumn = last.yycolumn;
    zzAtBOL = last.zzAtBOL;
    zzAtEOF = last.zzAtEOF;
    return last.isIncludeScanner;
  }
  
  public boolean isIncludeScanner = false;
  
  // Reference to our preprocessor handler.
  public PreprocessorHandler preprocessor = null;
  
  // Get the next token if we're not skipping tokens due to #if #endif preprocessor directives.
  public beaver.Symbol nextToken() throws java.io.IOException, beaver.Scanner.Exception {
    beaver.Symbol sym;
    do {
        // Consume a token
	    sym = nextTokenReal();
	    
	    // If we encountered the end of the macro replacement, continue scanning the previous text.
	    if (sym.getId() == Terminals.EOF && !stackedScanners.isEmpty()) {
	       if(popScannerState())
	           preprocessor.getParser().includeManager.leaveFile();
	       return nextToken();
	    }
	    
	    // See if this is a define
	    if (sym.getId() == Terminals.IDENTIFIER && preprocessor.getDefine((String)sym.value) != null) {
	       // Replace identifier with what it's defined to in some #define preprocessor directive.
	       String replacement = preprocessor.replaceDefine((String)sym.value);
	       
	       // Start lexing from this replacement string until we reach the end.
	       pushCurrentScannerState(false);
	       int lastLine = yyline;
	       int lastColumn = yycolumn;
	       yyreset(new java.io.InputStreamReader(new java.io.ByteArrayInputStream(replacement.getBytes())));
	       yyline = lastLine;
	       yycolumn = lastColumn;
	       // TODO: Keep track of original macro identifier for pretty printing!
	       return nextToken();
	    }
	    
	    // Always return preprocessor or end-of-file symbols.
	    if (sym.getId() == Terminals.PREPROCESSOR) {
	       // Parse the preprocessor line now!
	       Statement preprocessorStmt = preprocessor.parsePreprocessorLine(sym);
	       if (preprocessorStmt instanceof Include) {
	           Include include = (Include)preprocessorStmt;
	           // Read included file!
	           if (!include.getRealPath().isEmpty()) {
	               pushCurrentScannerState(true);
	               yyreset(new FileReader(include.getRealPath()));
	               preprocessor.getParser().includeManager.enterFile(include.getRealPath());
	           }
	       }
	       // Just return the normal symbol
	       // TODO: add preprocessor ASTNode to symbol
	       return sym;
	    } 
	    if (sym.getId() == Terminals.EOF) {
	        // if we're still supposed to skip the lines when we reach the end of the file, there is an #endif missing.
            if (preprocessor.shouldSkip()) {
               preprocessor.getParser().parseErrors.add(new SPParser.Exception("expected token: \"#endif\", but found \"-end of file-\"."));
            }
	        return sym;
	    }
    // Get the next token, if we should still skip.
    } while (preprocessor.shouldSkip());
    // Return the first symbol we shouldn't skip anymore.
    return sym;
  }
  
  private beaver.Symbol sym(short id) {
    return sym(id, yytext());
  }
  private beaver.Symbol sym(short id, Object value) {
    
    // We encountered an #endinput directive
    if (preprocessor.endInput()) {
      // Continue lexing other included files.
      preprocessor.setEndInput(false);
      // Simulate end-of-file!
      return new beaver.Symbol(Terminals.EOF, "end-of-file (#endinput)");
    }
    
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
{Preprocessor} { return sym(Terminals.PREPROCESSOR); }

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
"operator" { return sym(Terminals.OPERATOR); }
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
