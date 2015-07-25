package spbeaver.preprocessor;

import java.util.HashMap;
import java.util.Stack;

import spbeaver.parser.SPParser;

public class PreprocessorHandler {
    static public class Exception extends java.lang.Exception
    {
        beaver.Symbol symbol;
        public Exception(String msg, beaver.Symbol symbol) {
            super(msg);
            this.symbol = symbol;
        }
        public beaver.Symbol getSymbol() {
            return symbol;
        }
    }
    
    enum IfState {
        IGNORE, // Encountered conditional blocks inside a skip block
        PARSE,  // Parse everything
        SKIP    // Skip everything but preprocessor conditionals
    }
    
    private SPParser parser;
    private Stack<IfState> ifstack = new Stack<>();
    // Set by the #endinput directive
    private boolean endInput = false;
    // Map of #define's and their values
    private HashMap<String, Opt<Expression>> defines = new HashMap<>();
    // Deprecated message for next method declaration
    private boolean deprecated = false;
    private String deprecatedMessage = "";
    // Semicolons required
    private boolean semicolonsRequired = false;
    
    public PreprocessorHandler(SPParser parser) {
        this.parser = parser;
        
        // Add predefined __DATE__ and __TIME__
        defines.put("__DATE__", new Opt<Expression>(new SPString("")));
        defines.put("__TIME__", new Opt<Expression>(new SPString("")));
    }
    
    public SPParser getParser() {
        return parser;
    }
    
    public void addParseError(String error, beaver.Symbol symbol) {
        getParser().parseErrors.add(new SPParser.Exception(error, symbol));
    }
    
    public Opt<Expression> getDefine(String define) {
        return defines.get(define);
    }
    
    public String replaceDefine(String define) {
        // See if it's defined
        Opt<Expression> exprOpt = getDefine(define);
        // Not defined. Just return original string.
        if (exprOpt == null)
            return define;
        
        // This is defined but has no value.
        if (exprOpt.getNumChild() == 0)
            return "";
        
        Expression expr = exprOpt.getChild(0);
        
        // Just paste this thing directly
        if (expr instanceof Literal)
            return ((Literal)expr).getString();
        
        // Scan the identifier. Probably a nested define?
        if (expr instanceof IdentUse)
            return ((IdentUse)expr).getID();
        
        // Insert the String
        if (expr instanceof SPString)
            return ((SPString)expr).getString();
        
        // Evaluate integer expressions before inserting
        try {
            return String.valueOf(expr.value());
        } catch (Exception e) {
            // Assume zero.
            return "0";
        }
    }
    
    public boolean isDeprecated() {
        return deprecated;
    }
    
    public String takeDeprecatedMessage() {
        String msg = deprecatedMessage;
        deprecated = false;
        deprecatedMessage = "";
        return msg;
    }
    
    public boolean semicolonsRequired() {
        return semicolonsRequired;
    }
    
    public boolean shouldSkip() {
        return !ifstack.isEmpty() && (ifstack.peek() == IfState.IGNORE || ifstack.peek() == IfState.SKIP);
    }
    
    public boolean endInput() {
        return endInput;
    }
    
    public void clearEndInput() {
        endInput = false;
    }
    
    public void add(Statement statement) throws Exception {
        statement.visit(this);
    }

    public void accept(Define def) throws Exception {
        if (shouldSkip())
            return;
        
        if (defines.containsKey(def.getName()))
            throw new PreprocessorHandler.Exception("\"" + def.getName() + "\" is already defined.", def); // TODO: Tell location of already defined symbol
        
        defines.put(def.getName(), def.getValueOpt());
    }
    
    public void accept(Undefine undef) throws Exception {
        if (shouldSkip())
            return;
        
        if (!defines.containsKey(undef.getName().getID()))
            throw new PreprocessorHandler.Exception("\"" + undef.getName().getID() + "\" is not defined.", undef);
        
        defines.remove(undef.getName());
    }
    
    // Simulate end of file in lexer!
    public void accept(EndInput end) throws Exception {
        if (shouldSkip())
            return;
        endInput = true;
    }
    
    public void accept(UserError error) throws Exception {
        if (shouldSkip())
            return;
        
        // This is a static error. Just do it!
        throw new PreprocessorHandler.Exception("User error: " + error.getError(), error);
    }
    
    public void accept(UserAssert userAssert) throws Exception {
        if (shouldSkip())
            return;
        
        // Check if this assertion is false.
        if (userAssert.getExpr().value() == 0) {
            userAssert.print();
            String assertion = userAssert.printer().getString();
            // Skip "#assert " and new line at the end
            assertion = assertion.substring(8, assertion.length()-1);
            throw new PreprocessorHandler.Exception("Assertion failed: " + assertion, userAssert);
        }
    }
    
    public void accept(If expr) throws Exception {
        // We're currently skipping. Just keep track of nesting levels.
        if (shouldSkip()) {
            ifstack.push(IfState.IGNORE);
            return;
        }
        
        if (expr.getExpr().value() == 0) {
            ifstack.push(IfState.SKIP);
        }
        else {
            ifstack.push(IfState.PARSE);
        }
    }
    
    public void accept(ElseIf expr) throws Exception {
        if (ifstack.isEmpty())
            throw new PreprocessorHandler.Exception("#elseif without an #if!", expr);
        
        switch (ifstack.pop()) {
        // We're currently skipping. Just keep track of nesting levels.
        case IGNORE:
            ifstack.push(IfState.IGNORE);
            break;
        // 
        case PARSE:
            ifstack.push(IfState.IGNORE);
            break;
        case SKIP:
            if (expr.getExpr().value() == 0) {
                ifstack.push(IfState.SKIP);
            }
            else {
                ifstack.push(IfState.PARSE);
            }
            break;
        }
    }
    
    public void accept(Else expr) throws Exception {
        if (ifstack.isEmpty())
            throw new PreprocessorHandler.Exception("#else without an #if!", expr);
        
        switch (ifstack.pop()) {
        // We're currently skipping. Just keep track of nesting levels.
        case IGNORE:
            ifstack.push(IfState.IGNORE);
            break;
        // 
        case PARSE:
            ifstack.push(IfState.SKIP);
            break;
        case SKIP:
            ifstack.push(IfState.PARSE);
        }
    }
    
    public void accept(EndIf expr) throws Exception {
        if (ifstack.isEmpty())
            throw new PreprocessorHandler.Exception("#endif without an #if!", expr);
        ifstack.pop();
    }
    
    public void accept(DeprecatedMsg deprecated) throws Exception {
        if (shouldSkip())
            return;
        
        // Remember this deprecated message
        // Just overwrite multiple following ones.
        // This is picked up by the next Method declaration.
        this.deprecated = true;
        deprecatedMessage = deprecated.getMessage();
    }
    
    public void accept(RequireSemicolon semicolon) throws Exception {
        if (shouldSkip())
            return;
        
        semicolonsRequired = semicolon.getRequired().value() > 0;
    }
}