package spbeaver.preprocessor;

import java.util.HashMap;
import java.util.Stack;

import spbeaver.parser.SPParser;

public class PreprocessorHandler {
    static public class Exception extends java.lang.Exception
    {
        Exception(String msg)
        {
            super(msg);
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
    
    private HashMap<String, Opt<Expression>> defines = new HashMap<>();
    
    public PreprocessorHandler(SPParser parser) {
        this.parser = parser;
    }
    
    public Opt<Expression> getDefine(String define) {
        return defines.get(define);
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
        if (defines.containsKey(def.getName()))
            throw new PreprocessorHandler.Exception("\"" + def.getName() + "\" is already defined."); // TODO: Tell location of already defined symbol
        
        defines.put(def.getName(), def.getValueOpt());
    }
    
    public void accept(Undefine undef) throws Exception {
        if (!defines.containsKey(undef.getName().getID()))
            throw new PreprocessorHandler.Exception("\"" + undef.getName().getID() + "\" is not defined.");
        
        defines.remove(undef.getName());
    }
    
    // Simulate end of file in lexer!
    public void accept(EndInput end) throws Exception {
        endInput = true;
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
            throw new PreprocessorHandler.Exception("#elseif without an #if!"); // TODO: Tell location
        
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
            throw new PreprocessorHandler.Exception("#else without an #if!"); // TODO: Tell location
        
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
            throw new PreprocessorHandler.Exception("#endif without an #if!"); // TODO: Tell location
        ifstack.pop();
    }
}