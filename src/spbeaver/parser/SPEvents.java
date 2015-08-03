package spbeaver.parser;

import beaver.Parser.Events;
import beaver.Scanner;
import beaver.Symbol;

public class SPEvents extends Events
{
    private SPParser parser;
    public SPEvents(SPParser parser)
    {
        this.parser = parser;
    }
    public void scannerError(Scanner.Exception e)
    {
        parser.parseErrors.add(new SPParser.Exception(e.getMessage(), e.line, e.column, parser.includeManager.currentFile()));
    }
    public void syntaxError(Symbol token)
    {
        parser.parseErrors.add(new SPParser.Exception("Syntax Error: unexpected token " + getTokenString(token), token, parser.includeManager.currentFile()));
    }
    public void unexpectedTokenRemoved(Symbol token)
    {
        parser.parseErrors.add(new SPParser.Exception("Recovered: removed unexpected token " + getTokenString(token), token, parser.includeManager.currentFile()));
    }
    public void missingTokenInserted(Symbol token)
    {
        parser.parseErrors.add(new SPParser.Exception("Recovered: inserted missing token " + getTokenString(token), token, parser.includeManager.currentFile()));
    }
    public void misspelledTokenReplaced(Symbol token)
    {
        parser.parseErrors.add(new SPParser.Exception("Recovered: replaced unexpected token with " + getTokenString(token), token, parser.includeManager.currentFile()));
    }
    public void errorPhraseRemoved(Symbol error)
    {
        parser.parseErrors.add(new SPParser.Exception("Recovered: removed error phrase", error, parser.includeManager.currentFile()));
    }
    
    private String getTokenString(Symbol token)
    {
        StringBuilder sb = new StringBuilder();
        if (token.value != null)
        {
            sb.append('"');
            sb.append(token.value);
            sb.append('"');
        }
        else
        {
            sb.append('#');
            sb.append(token.getId());
        }
        return sb.toString();
    }
}