package spbeaver.parser;

import java.io.File;
import java.util.LinkedList;
import java.util.Stack;

public class IncludeManager {
    private final String[] FILE_EXTENSIONS = {".inc", ".p", ".pawn"}; 
    
    class SourceFile {
        private int fileIndex;
        private String filePath;
        public SourceFile(String filePath, int fileIndex) {
            this.fileIndex = fileIndex;
            this.filePath = filePath;
        }
        public int getFileIndex() {
            return fileIndex;
        }
        public String getFilePath() {
            return filePath;
        }
    }
    
    private SPParser parser;
    
    public IncludeManager(SPParser parser) {
        this.parser = parser;
    }

    private Stack<SourceFile> fileStack = new Stack<>();
    
    private int totalFiles = 0;
    
    private LinkedList<String> searchPaths = new LinkedList<>();
    
    public void addSearchPath(String path) {
        // Paths have to end with a directory seperator
        if (!path.endsWith("/") && !path.endsWith("\\"))
            path = path + "/";
        searchPaths.add(path);
    }
    
    /**
     * Try to find the file in one of the search paths.
     * Tries different file extensions too.
     * 
     * @param path The path to the file to include.
     * @param currentFile The file which is parsed currently and had the #include line.
     * @param tryCurrentPath Whether to look for the file in the current directory or only in the search path.
     * @return Full resolved path of existing file or empty string if not found.
     */
    public String resolvePath(String path, boolean tryCurrentPath) {
        String realPath = "";
        if (tryCurrentPath) {
            realPath = tryExtensionsPath(path);
            // Can't find the file in the active directory.
            if (realPath.isEmpty()) {
                // try to open the file in the same directory as the current file.
                int lastForwardSlash = currentFile().lastIndexOf('/');
                int lastBackwardSlash = currentFile().lastIndexOf('\\');
                int lastSlash = Math.max(lastForwardSlash, lastBackwardSlash);
                if (lastSlash != -1) {
                    realPath = currentFile().substring(0, lastSlash+1) + path;
                    realPath = tryExtensionsPath(realPath);
                }
            }
        }
        
        // Try all search paths
        for (String searchPath: searchPaths) {
            if (!realPath.isEmpty())
                break;
            
            realPath = searchPath + path;
            realPath = tryExtensionsPath(realPath);
        }
        
        return realPath;
    }
    
    private String tryExtensionsPath(String path) {
        
        File file = new File(path);
        if (file.exists() && !file.isDirectory())
            return path;
        
        // Try all possible file extensions.
        String realPath;
        for (int i=0; i<FILE_EXTENSIONS.length; i++) {
            realPath = path + FILE_EXTENSIONS[i];
            file = new File(realPath);
            if (file.exists() && !file.isDirectory())
                return realPath;
        }
        
        return "";
    }
    
    public void enterFile(String path) {
        fileStack.push(new SourceFile(path, totalFiles++));
        parser.preprocessor.pushIfStack();
//        System.out.println("Parsing include " + path);
    }
    
    public String leaveFile() {
        SourceFile include = fileStack.pop();
        parser.preprocessor.popIfStack();
//        System.out.println("Finished parsing " + include.getFilePath());
        return include.getFilePath();
    }
    
    public int fileIndex() {
        return fileStack.peek().getFileIndex();
    }
    
    public String currentFile() {
        return fileStack.peek().getFilePath();
    }
}
