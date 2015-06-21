package spbeaver;

public class DeclFlags {
	public static final int NONE = 0;
	public static final int NEW = (1<<0);
	public static final int PUBLIC = (1<<1);
	public static final int STOCK = (1<<2);
	public static final int STATIC = (1<<3);
	public static final int REFERENCE = (1<<4);
	public static final int CONST = (1<<5);
	public static final int VARIADIC = (1<<6);
	
	public static final int NATIVE = (1<<7);
	public static final int FORWARD = (1<<8);
}
