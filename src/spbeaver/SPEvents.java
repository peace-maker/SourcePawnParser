package spbeaver;

import beaver.Parser.Events;
import beaver.Scanner;
import beaver.Symbol;

// TODO: Collect scanner and syntax errors
public class SPEvents extends Events
{
    public void scannerError(Scanner.Exception e)
    {
        super.scannerError(e);
    }
    public void syntaxError(Symbol token)
    {
        super.syntaxError(token);
    }
    public void unexpectedTokenRemoved(Symbol token)
    {
        super.unexpectedTokenRemoved(token);
    }
    public void missingTokenInserted(Symbol token)
    {
        super.missingTokenInserted(token);
    }
    public void misspelledTokenReplaced(Symbol token)
    {
        super.misspelledTokenReplaced(token);
    }
    public void errorPhraseRemoved(Symbol error)
    {
        super.errorPhraseRemoved(error);
    }
}