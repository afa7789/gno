package storage

import (
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
	}
	return execFn(State(tree.(*avl.Tree)))
}