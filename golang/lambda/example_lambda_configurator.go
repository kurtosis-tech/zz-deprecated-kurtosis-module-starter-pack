/*
 * Copyright (c) 2021 - present Kurtosis Technologies LLC.
 * All Rights Reserved.
 */

package lambda

import (
	"encoding/json"
	"github.com/kurtosis-tech/kurtosis-lambda-api-lib/golang/lib/lambda"
	"github.com/palantir/stacktrace"
	"github.com/sirupsen/logrus"
)

const(
	defaultLogLevel = "info"
)

type ExampleLambdaConfigurator struct{}

func NewExampleLambdaConfigurator() *ExampleLambdaConfigurator {
	return &ExampleLambdaConfigurator{}
}

func (t ExampleLambdaConfigurator) ParseParamsAndCreateLambda(serializedCustomParamsStr string) (lambda.Lambda, error) {
	serializedCustomParamsBytes := []byte(serializedCustomParamsStr)
	var args ExampleLambdaArgs
	if err := json.Unmarshal(serializedCustomParamsBytes, &args); err != nil {
		return nil, stacktrace.Propagate(err, "An error occurred deserializing the Lambda serialized custom params with value '%v", serializedCustomParamsStr)
	}

	err := setLogLevel(args.LogLevel)
	if err != nil {
		return nil, stacktrace.Propagate(err, "An error occurred setting the log level")
	}

	lambda := NewExampleLambda()

	return lambda, nil
}

func setLogLevel(logLevelStr string) error {
	if logLevelStr == "" {
		logLevelStr = defaultLogLevel
	}
	level, err := logrus.ParseLevel(logLevelStr)
	if err != nil {
		return stacktrace.Propagate(err, "An error occurred parsing loglevel string '%v'", logLevelStr)
	}

	logrus.SetLevel(level)
	logrus.SetFormatter(&logrus.TextFormatter{
		ForceColors:   true,
		FullTimestamp: true,
	})
	return nil
}
