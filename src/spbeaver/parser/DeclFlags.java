package spbeaver.parser;

public class DeclFlags {
	public static final int NONE = 0;
	public static final int NEW = (1<<0);
	public static final int PUBLIC = (1<<1);
	public static final int STOCK = (1<<2);
	public static final int STATIC = (1<<3);
	public static final int REFERENCE = (1<<4);
	public static final int CONST = (1<<5);
	public static final int VARIADIC = (1<<6);
	
	public static final int DEPRECATED = (1<<7);
	
	public static final int NATIVE = (1<<8);
	public static final int FORWARD = (1<<9);
	public static final int FUNCTAG = (1<<10);
	public static final int OPERATOR = (1<<11);
	
	public static final int INLINE = (1<<12);
}
