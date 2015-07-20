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
        super.scannerError(e);
    }
    public void syntaxError(Symbol token)
    {
        parser.parseErrors.add(new SPParser.Exception("Syntax Error: unexpected token", token));
        super.syntaxError(token);
    }
    public void unexpectedTokenRemoved(Symbol token)
    {
        parser.parseErrors.add(new SPParser.Exception("Recovered: removed unexpected token", token));
        super.unexpectedTokenRemoved(token);
    }
    public void missingTokenInserted(Symbol token)
    {
        parser.parseErrors.add(new SPParser.Exception("Recovered: inserted missing token", token));
        super.missingTokenInserted(token);
    }
    public void misspelledTokenReplaced(Symbol token)
    {
        parser.parseErrors.add(new SPParser.Exception("Recovered: replaced unexpected token with", token));
        super.misspelledTokenReplaced(token);
    }
    public void errorPhraseRemoved(Symbol error)
    {
        parser.parseErrors.add(new SPParser.Exception("Recovered: removed error phrase", error));
        super.errorPhraseRemoved(error);
    }
}