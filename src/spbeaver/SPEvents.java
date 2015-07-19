package spbeaver;

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
        super.scannerError(e);
        parser.parseErrors.add(new SPParser.Exception(e.getMessage(), e.line, e.column));
    }
    public void syntaxError(Symbol token)
    {
        super.syntaxError(token);
        parser.parseErrors.add(new SPParser.Exception("Syntax Error: unexpected token", token));
    }
    public void unexpectedTokenRemoved(Symbol token)
    {
        super.unexpectedTokenRemoved(token);
        parser.parseErrors.add(new SPParser.Exception("Recovered: removed unexpected token", token));
    }
    public void missingTokenInserted(Symbol token)
    {
        super.missingTokenInserted(token);
        parser.parseErrors.add(new SPParser.Exception("Recovered: inserted missing token", token));
    }
    public void misspelledTokenReplaced(Symbol token)
    {
        super.misspelledTokenReplaced(token);
        parser.parseErrors.add(new SPParser.Exception("Recovered: replaced unexpected token with", token));
    }
    public void errorPhraseRemoved(Symbol error)
    {
        super.errorPhraseRemoved(error);
        parser.parseErrors.add(new SPParser.Exception("Recovered: removed error phrase", error));
    }
}