package enums

type UserStatus int

const (
	UserOnline UserStatus = iota
	UserOperator
	UserAway
	UserOffline
	UserUnknown
)

func (s UserStatus) String() string {
	return [...]string{"Online", "Operator", "Away", "Offline", "Unknown"}[s]
}

func GetStatusFromSymbol(symbol string) UserStatus {
	switch symbol {
	case "=":
		return UserOnline
	case "*":
		return UserOperator
	case "+":
		return UserAway
	case "-":
		return UserOffline
	default:
		return UserUnknown
	}
}
