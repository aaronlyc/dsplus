package main

import (
	"fmt"
	"os"

	"github.com/spf13/cobra"
)

// 创建一个命令行对象
func newCommand() *cobra.Command {
	var command = cobra.Command{
		Use:   "dsplus",
		Short: "dsplus is a controller to operate on dsplus CRD.",
		RunE: func(c *cobra.Command, args []string) error {
			return nil
		},
	}

	return &command
}

func main() {
	if err := newCommand().Execute(); err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
}
