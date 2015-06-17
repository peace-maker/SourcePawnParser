package spbeaver;

public class UnaryOperator {
	public enum UnaryOp {
		INC,
		DEC,
		NEG,
		INV,
		COMPL
	}
	
	public static String unaryOpToString(UnaryOp op) {
		switch(op) {
		case INC:
			return "++";
		case DEC:
			return "--";
		case NEG:
			return "-";
		case INV:
			return "!";
		case COMPL:
			return "~";
		default:
			return "";
		}
	}
}
