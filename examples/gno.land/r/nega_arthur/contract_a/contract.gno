package contract_a

import (
	"std"
	stor "gno.land/p/nega_arthur/storage"
)

// MINIMAL CONTRACT A - Data processor (no storage)
var (
	owner       std.Address
	initialized bool
)

// Initialize this processor
func Init(cur realm) {
	if initialized {
		panic("already initialized")
	}
	owner = std.PreviousRealm().Address()
	initialized = true
}

// Process data - simple logic, just stores input as-is
func MethodA(cur realm, storage *stor.Storage, input string) string {
	if !initialized {
		panic("not initialized")
	}

	// Simple processing: store input directly
	stor.Set("last_input", input)
	stor.Set("processed_by", "ContractA")

	return input
}

// Get processed data
func GetData(cur realm, storage *stor.Storage) string {
	if !initialized {
		panic("not initialized")
	}

	if val := storage.Get("last_input"); val != nil {
		return val.(string)
	}
	return ""
}

func Render(path string) string {
	if !initialized {
		return "# Minimal Contract A - Data Processor\n\nNot initialized."
	}
	return "# Minimal Contract A - Data Processor\n\n**Owner:** " + owner.String() + "\n**Logic:** Simple pass-through processing"
}