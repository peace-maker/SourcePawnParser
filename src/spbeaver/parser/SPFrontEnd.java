package spbeaver.parser;

import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;

import spbeaver.preprocessor.Preprocessor;

class SPFrontEnd {

  public static void main(String args[]) {
   String inputFileName;
   if(args.length != 1) {
      System.out.println("SPFrontEnd: missing file command line argument");
      //System.exit(1);
      inputFileName = "tests/test.sp";
    }
   else {
      System.out.println("SPFrontEnd: starting on file " + args[0]);
      System.out.flush();
      inputFileName = args[0];
    }
   try { 
      SPParser parser = new SPParser(inputFileName);
      SPScanner scanner = new SPScanner(new FileReader(inputFileName));
      // Link preprocessor class to lexer.
      scanner.preprocessor = parser.preprocessor;
      // Start parsing from the nonterminal "Start".
      SourcePawnFile ast = (SourcePawnFile) parser.parse(scanner);
      ast.collectErrors(parser.parseErrors);
      for (SPParser.Exception ex: parser.parseErrors) {
          System.err.println(ex.getMessage());
      }

//      System.out.printf("Parsed %d preprocessor directives\n", parser.preprocessor.size());
//      for (Preprocessor pre: parser.preprocessor) {
//          System.out.println(pre.printAST());
//      }
      
    /*  Set<Error> typeErrors = ast.getTypeErrors();
      if (!typeErrors.isEmpty()) {
    	  System.out.println("There are " + typeErrors.size() + " type error(s) in "+ args[0]);
    	  for (Error e : typeErrors) {
    		 System.out.println(e.getMessage());
    	  }
    	  System.exit(1);
      }
      */
      // Print the resulting AST on standard output.
      System.out.println(ast.printAST()); 
      System.out.println(ast.print().getString());
    }
    catch (FileNotFoundException e) {
      System.err.println("SPFrontEnd: file " + inputFileName + " not found");
    }
    catch (beaver.Parser.Exception e) {
      System.out.println("Error when parsing: " + inputFileName);      
      System.out.println(e.getMessage());      
    }
    catch (IOException e) {
      System.out.println("SPFrontEnd: " + e.getMessage());
    }
  }

}
