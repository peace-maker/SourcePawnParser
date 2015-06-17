package spbeaver;

public class BinaryOperator {
	public enum BinaryOp {
		NONE,
		MUL,
		DIV,
		MOD,
		PLUS,
		MINUS,
		SHL,
		SHRU,
		SHR,
		BITAND,
		BITOR,
		BITXOR,
		
		LT,
		LE,
		GT,
		GE,
		EQ,
		NE,
		
		OR,
		AND
	}
	
	public static String binaryOpToString(BinaryOp op) {
		switch(op) {
		case MUL:
			return "*";
		case DIV:
			return "/";
		case MOD:
			return "%";
		case PLUS:
			return "+";
		case MINUS:
			return "-";
		case SHL:
			return "<<";
		case SHRU:
			return ">>>";
		case SHR:
			return ">>";
		case BITAND:
			return "&";
		case BITOR:
			return "|";
		case BITXOR:
			return "^";
		case LT:
			return "<";
		case LE:
			return "<=";
		case GT:
			return ">";
		case GE:
			return ">=";
		case EQ:
			return "=";
		case NE:
			return "!=";
		case OR:
			return "||";
		case AND:
			return "&&";
		default:
			return "";
		}
	}
}

