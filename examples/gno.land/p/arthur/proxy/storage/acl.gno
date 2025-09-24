package storage

// ACL (Access Control List) management following OpenZeppelin pattern
// Ensures only authorized realms can access storage

func ACLKey() string {
	return "__proxy_acl__"
}

// SetACL sets the allowed packages for storage access
func SetACL(state State, pkgs []string) {
	m := make(map[string]struct{})
	for _, pkg := range pkgs {
		m[pkg] = struct{}{}
	}
	state.Set(ACLKey(), m)
}

// IsInACL checks if a package is allowed to access this storage
func IsInACL(state State, pkg string) bool {
	v, ok := state.Get(ACLKey())
	if !ok {
		return false
	}
	m := v.(map[string]struct{})
	_, ok = m[pkg]
	return ok
}

// AddToACL adds a package to the allowed list
func AddToACL(state State, pkg string) {
	v, ok := state.Get(ACLKey())
	var m map[string]struct{}
	if !ok {
		m = make(map[string]struct{})
	} else {
		m = v.(map[string]struct{})
	}
	m[pkg] = struct{}{}
	state.Set(ACLKey(), m)
}

// RemoveFromACL removes a package from the allowed list
func RemoveFromACL(state State, pkg string) {
	v, ok := state.Get(ACLKey())
	if !ok {
		return
	}
	m := v.(map[string]struct{})
	delete(m, pkg)
	state.Set(ACLKey(), m)
}

// GetACL returns current access control list
func GetACL(state State) []string {
	v, ok := state.Get(ACLKey())
	if !ok {
		return []string{}
	}
	m := v.(map[string]struct{})
	var pkgs []string
	for pkg := range m {
		pkgs = append(pkgs, pkg)
	}
	return pkgs
}