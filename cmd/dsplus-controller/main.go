package main

import (
	"fmt"
	"github.com/aaronlyc/dsplus/utils/version"
	log "github.com/sirupsen/logrus"
	"github.com/spf13/cobra"
	"os"
)

// 创建一个命令行对象
func newCommand() *cobra.Command {
	var (
		printVersion bool
		logLevel     string
	)

	var command = cobra.Command{
		Use:   "dsplus",
		Short: "dsplus is a controller to operate on dsplus CRD.",
		RunE: func(c *cobra.Command, args []string) error {
			// 打印版本
			if printVersion {
				fmt.Println(version.GetVersion())
				return nil
			}

			// 设置日志级别
			// 分为panic, error, warn, info, debug, trace
			// 默认info
			setLogLevel(logLevel)
			// 设置完整的时间戳
			formatter := &log.TextFormatter{
				FullTimestamp: true,
			}
			log.SetFormatter(formatter)
			// 这里初始化的日志带上版本信息
			v := version.GetVersion()
			fmt.Println(v)
			log.WithField("version", v).Info("Daemon set plus starting")
			return nil
		},
	}

	command.Flags().StringVar(&logLevel, "loglevel", "info", "Set the logging level. One of: debug|info|warn|error")
	command.Flags().BoolVar(&printVersion, "version", false, "Print version")
	return &command
}

func main() {
	if err := newCommand().Execute(); err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
}

// setLogLevel parses and sets a logrus log level
func setLogLevel(logLevel string) {
	level, err := log.ParseLevel(logLevel)
	if err != nil {
		log.Fatal(err)
	}
	log.SetLevel(level)
}

func checkError(err error) {
	if err != nil {
		log.Fatal(err)
	}
}
