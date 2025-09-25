package storage

import (
	"std"

	"gno.land/p/nt/avl"
)

// ProxyStorage provides simple persistent state management for proxy contracts
type ProxyStorage struct {
	state *avl.Tree
}

// NewProxyStorage creates a new proxy storage instance
func NewProxyStorage() *ProxyStorage {
	return &ProxyStorage{
		state: avl.NewTree(),
	}
}

func (s *ProxyStorage) onlyTrustedRealm(state State) {
	if !IsInACL(state, std.PreviousRealm().PkgPath()) {
		panic("unexpected storage access from realm: " + std.PreviousRealm().PkgPath())
	}
}

// State interface matches OpenZeppelin pattern for consistent storage operations
type State interface {
	Get(key string) (value any, exists bool)
	Set(key string, value any) (updated bool)
}

// ExecFn defines the execution function type for storage operations
type ExecFn func(state State) any

// Execute runs a function against the storage state for a specific accountID
func (s *ProxyStorage) Execute(accountID string, execFn ExecFn) any {
	tree, ok := s.state.Get(accountID)
	if !ok {
		tree = avl.NewTree()
		s.state.Set(accountID, tree)
	} else {
		s.onlyTrustedRealm(State(tree.(*avl.Tree)))
	}
	return execFn(State(tree.(*avl.Tree)))
}

// GetAccountIDs returns all contract instance IDs (for admin/debugging)
func (s *ProxyStorage) GetAccountIDs() []string {
	var ids []string
	s.state.Iterate("", "", func(key string, value any) bool {
		ids = append(ids, key)
		return false
	})
	return ids
}

// HasAccount checks if a contract instance exists
func (s *ProxyStorage) HasAccount(accountID string) bool {
	_, exists := s.state.Get(accountID)
	return exists
}