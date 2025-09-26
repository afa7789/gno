package storage

// Storage provides a simple key-value interface
// This is a pure package that all realms can import and use
type Storage interface {
	Get(key string) interface{}
	Set(key string, value interface{})
	Has(key string) bool
	Delete(key string)
}

// SimpleStorage implements Storage interface
type SimpleStorage struct {
	data map[string]interface{}
}

// NewStorage creates a new storage instance
func NewStorage() Storage {
	return &SimpleStorage{
		data: make(map[string]interface{}),
	}
}

func (s *SimpleStorage) Get(key string) interface{} {
	return s.data[key]
}

func (s *SimpleStorage) Set(key string, value interface{}) {
	s.data[key] = value
}

func (s *SimpleStorage) Has(key string) bool {
	_, exists := s.data[key]
	return exists
}

func (s *SimpleStorage) Delete(key string) {
	delete(s.data, key)
}

// Slot provides a typed interface to a specific storage key
type Slot struct {
	storage Storage
	key     string
}

func (s *SimpleStorage) Slot(key string) *Slot {
	return &Slot{
		storage: s,
		key:     key,
	}
}

func (slot *Slot) Save(value interface{}) {
	slot.storage.Set(slot.key, value)
}

func (slot *Slot) Get() interface{} {
	return slot.storage.Get(slot.key)
}

func (slot *Slot) GetInt() int {
	if val := slot.Get(); val != nil {
		if intVal, ok := val.(int); ok {
			return intVal
		}
	}
	return 0
}

func (slot *Slot) GetString() string {
	if val := slot.Get(); val != nil {
		if strVal, ok := val.(string); ok {
			return strVal
		}
	}
	return ""
}