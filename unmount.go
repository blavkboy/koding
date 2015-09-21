package main

import (
	"fmt"
	"log"

	"github.com/koding/kite"
	"github.com/mitchellh/cli"
)

func UnmountCommandFactory(k *kite.Client) cli.CommandFactory {
	return func() (cli.Command, error) { return &UnmountCommand{k: k}, nil }
}

type UnmountCommand struct {
	k *kite.Client
}

func (c *UnmountCommand) Run(args []string) int {
	// All of the arguments are required currently, so error if anything
	// is missing.
	if len(args) != 1 {
		fmt.Printf(c.Help())
		return 1
	}

	if err := c.k.Dial(); err != nil {
		log.Fatal(err)
	}

	mountRequest := struct {
		LocalPath string `json:"localPath"`
	}{LocalPath: args[0]}

	// Don't care about the response currently, since there is none.
	if _, err := c.k.Tell("remote.unmountFolder", mountRequest); err != nil {
		log.Fatal(err)
	}

	return 0
}

func (*UnmountCommand) Help() string {
	helpText := `
Usage: %s unmount <local folder>

    Unmount specified local folder which was previously mounted.
`
	return fmt.Sprintf(helpText, Name)
}

func (*UnmountCommand) Synopsis() string {
	return fmt.Sprintf("Unmount specified local folder.")
}
