package lambda

import (
	"encoding/json"
	"github.com/kurtosis-tech/kurtosis-client/golang/lib/networks"
	"github.com/palantir/stacktrace"
	"github.com/sirupsen/logrus"
	"math/rand"
	"time"
)

var (
	advicesRepository = []string{
		"Everything not saved will be lost.",
		"Don't pet a burning dog.",
		"Even a broken clock is right twice a day.",
		"If no one comes from the future to stop you from doing it, then how bad of a decision can it really be?",
		"Never fall in love with a tennis player. Love means nothing to them.",
		"If you eve get caught sleeping on the job, slowly raise your head and say 'In Jesus name, Amen'",
		"Neve trust in an electrician with no eyebrows",
		"If you sleep until lunch time, you can save the breakfast money.",
	}
)

type ExampleLambda struct {
}

type ExampleLambdaParams struct {
	IWantAnAdvice bool `json:"i_want_an_advice"`
}

type ExampleLambdaResult struct {
	Advice string `json:"advice"`
}

func NewExampleLambda() *ExampleLambda {
	return &ExampleLambda{}
}

func (e ExampleLambda) Execute(networkCtx *networks.NetworkContext, serializedParams string) (serializedResult string, resultError error) {
	logrus.Infof("Example Lambda receives serializedParams '%v'", serializedParams)
	serializedParamsBytes := []byte(serializedParams)
	var params ExampleLambdaParams
	if err := json.Unmarshal(serializedParamsBytes, &params); err != nil {
		return "", stacktrace.Propagate(err, "An error occurred deserializing the Example Lambda serialized params with value '%v", serializedParams)
	}

	exampleLambdaResult := &ExampleLambdaResult{
		Advice: getRandomAdvice(params.IWantAnAdvice),
	}

	result, err := json.Marshal(exampleLambdaResult)
	if err != nil {
		return "", stacktrace.Propagate(err, "An error occurred serializing the Example Lambda Result with value '%+v\n'", exampleLambdaResult)
	}
	stringResult := string(result)

	logrus.Info("Example Lambda executed successfully")
	return stringResult, nil
}

func getRandomAdvice(getAnAdvice bool) string {
	var advice string
	if getAnAdvice {
		rand.Seed(time.Now().Unix())
		advice = advicesRepository[rand.Intn(len(advicesRepository))]
	} else {
		advice = "Kurtosis Lambda Example won't enlighten you today."
	}
	return advice
}
