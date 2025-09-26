package interpreter

import "gno.land/p/nega_arthur/storage"

// Interpreter interface that all interpreters must implement
type Interpreter interface {
	Call(method string, storage *storage.Storage, args ...interface{}) interface{}
	GetVersion() string
}