package utils

func GetUniqList(list []string) []string {
	var uniqList []string

	for _, el := range list {
		if !contains(uniqList, el) {
			uniqList = append(uniqList, el)
		}
	}

	return uniqList
}

func contains(list []string, str string) bool {
	for _, el := range list {
		if el == str {
			return true
		}
	}

	return false
}
