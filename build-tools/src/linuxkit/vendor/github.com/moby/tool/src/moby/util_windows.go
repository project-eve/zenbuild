package moby

import (
	"os"
)

func homeDir() string {
	return os.Getenv("USERPROFILE")
}
