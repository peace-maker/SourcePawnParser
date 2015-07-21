package spbeaver.parser;

import beaver.Parser.Events;
import beaver.Scanner;
import beaver.Symbol;

// TODO: Collect scanner and syntax errors
public class SPEvents extends Events
{
    private SPParser parser;
    public SPEvents(SPParser parser)
    {
        this.parser = parser;
    }
    public void scannerError(Scanner.Exception e)
    {
        parser.parseErrors.add(new SPParser.Exception(e.getMessage(), e.line, e.column));
    }
    public void syntaxError(Symbol token)
    {
        parser.parseErrors.add(new SPParser.Exception("Syntax Error: unexpected token", token));
    }
    public void unexpectedTokenRemoved(Symbol token)
    {
        parser.parseErrors.add(new SPParser.Exception("Recovered: removed unexpected token", token));
    }
    public void missingTokenInserted(Symbol token)
    {
        parser.parseErrors.add(new SPParser.Exception("Recovered: inserted missing token", token));
    }
    public void misspelledTokenReplaced(Symbol token)
    {
        parser.parseErrors.add(new SPParser.Exception("Recovered: replaced unexpected token with", token));
    }
    public void errorPhraseRemoved(Symbol error)
    {
        parser.parseErrors.add(new SPParser.Exception("Recovered: removed error phrase", error));
    }
}