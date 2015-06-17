package spbeaver;

import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;

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
      SPParser parser = new SPParser();
      // Start parsing from the nonterminal "Start".
      SourcePawnFile ast = (SourcePawnFile) parser.parse(new SPScanner(new FileReader(inputFileName)));
      //System.out.println(ast.numChildren);
//      SPScanner sc = new SPScanner(new FileReader(inputFileName));
//      Symbol s;
//      try {
//		while((s = sc.nextToken()).getId() != Terminals.EOF) {
//			  System.out.println(Terminals.NAMES[s.getId()] + ": " + s.value);
//		  }
//	} catch (Exception e) {
//		// TODO Auto-generated catch block
//		e.printStackTrace();
//	}
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
      System.out.println("MJFrontEnd: " + e.getMessage());
    }
  }

}
