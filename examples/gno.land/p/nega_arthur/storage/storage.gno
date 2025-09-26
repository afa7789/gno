package storage

// MINIMAL STORAGE - Pure package, no realm
// The PROXY holds instances of this storage
type Storage struct {
	data map[string]interface{}
}

// Create new storage instance
func NewStorage() *Storage {
	return &Storage{
		data: make(map[string]interface{}),
	}
}

// Set a value
func (s *Storage) Set(key string, value interface{}) {
	s.data[key] = value
}

// Get a value
func (s *Storage) Get(key string) interface{} {
	return s.data[key]
}

// Get counter (convenience)
func (s *Storage) GetCounter() int {
	if val, ok := s.data["counter"].(int); ok {
		return val
	}
	return 0
}

// Set counter (convenience)
func (s *Storage) SetCounter(value int) {
	s.data["counter"] = value
}

// Initialize with default values
func (s *Storage) Init() {
	s.data["counter"] = 0
}