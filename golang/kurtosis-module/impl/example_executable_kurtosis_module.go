package impl

import (
	"encoding/json"
	"github.com/kurtosis-tech/kurtosis-client/golang/lib/networks"
	"github.com/palantir/stacktrace"
	"github.com/sirupsen/logrus"
	"math/rand"
	"time"
)

var (
	tipsRepository = []string{
		"Everything not saved will be lost.",
		"Don't pet a burning dog.",
		"Even a broken clock is right twice a day.",
		"If no one comes from the future to stop you from doing it, then how bad of a decision can it really be?",
		"Never fall in love with a tennis player. Love means nothing to them.",
		"If you ever get caught sleeping on the job, slowly raise your head and say 'In Jesus' name, Amen'",
		"Never trust in an electrician with no eyebrows",
		"If you sleep until lunch time, you can save the breakfast money.",
	}
)

type ExampleExecutableKurtosisModule struct {
}

type ExampleExecutableKurtosisModuleParams struct {
	IWantATip bool `json:"iWantATip"`
}

type ExampleExecutableKurtosisModuleResult struct {
	Tip string `json:"tip"`
}

func NewExampleExecutableKurtosisModule() *ExampleExecutableKurtosisModule {
	return &ExampleExecutableKurtosisModule{}
}

func (e ExampleExecutableKurtosisModule) Execute(networkCtx *networks.NetworkContext, serializedParams string) (serializedResult string, resultError error) {
	logrus.Infof("Received serialized execute params '%v'", serializedParams)
	serializedParamsBytes := []byte(serializedParams)
	var params ExampleExecutableKurtosisModuleParams
	if err := json.Unmarshal(serializedParamsBytes, &params); err != nil {
		return "", stacktrace.Propagate(err, "An error occurred deserializing the serialized execute params string '%v'", serializedParams)
	}

	resultObj := &ExampleExecutableKurtosisModuleResult{
		Tip: getRandomTip(params.IWantATip),
	}

	result, err := json.Marshal(resultObj)
	if err != nil {
		return "", stacktrace.Propagate(err, "An error occurred serializing the result object '%+v'", resultObj)
	}
	stringResult := string(result)

	logrus.Info("Execution successful")
	return stringResult, nil
}

func getRandomTip(shouldGiveAdvice bool) string {
	var tip string
	if shouldGiveAdvice {
		rand.Seed(time.Now().Unix())
		tip = tipsRepository[rand.Intn(len(tipsRepository))]
	} else {
		tip = "The module won't enlighten you today."
	}
	return tip
}
