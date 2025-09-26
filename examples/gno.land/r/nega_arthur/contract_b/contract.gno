package contract_b

import (
	"std"
	stor "gno.land/p/nega_arthur/storage"
)

// MINIMAL CONTRACT B - Enhanced data processor (no storage)
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

// Process data - enhanced logic, adds prefix and increments counter
func MethodA(cur realm, storage *stor.Storage, input string) string {
	if !initialized {
		panic("not initialized")
	}

	// Enhanced processing: add prefix and increment counter
	result := "enhanced: " + input
	storage.Set("last_input", result)
	storage.Set("processed_by", "ContractB")

	// Increment processing counter
	counter := storage.GetCounter()
	storage.SetCounter(counter + 1)

	return result
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
		return "# Minimal Contract B - Enhanced Data Processor\n\nNot initialized."
	}
	return "# Minimal Contract B - Enhanced Data Processor\n\n**Owner:** " + owner.String() + "\n**Logic:** Adds prefix + increments counter"
}