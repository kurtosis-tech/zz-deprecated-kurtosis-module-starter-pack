import { KurtosisLambda, KurtosisLambdaConfigurator } from 'kurtosis-lambda-api-lib';
import { Result, err, ok } from 'neverthrow';
import * as log from 'loglevel';

const DEFAULT_LOG_LEVEL: string = "info";

type LoglevelAcceptableLevelStrs = log.LogLevelDesc

class ExampleKurtosisLambdaConfigurator implements KurtosisLambdaConfigurator {
	public parseParamsAndCreateKurtosisLambda(serializedCustomParamsStr: string): Result<KurtosisLambda, Error> {
		let args: ExampleKurtosisLambdaArgs;
		try {
			args = JSON.parse(serializedCustomParamsStr);
		} catch (e: Error) {
			return err(e)
		}

		const setLogLevelResult: Result<null, Error> = ExampleKurtosisLambdaConfigurator.setLogLevel(args.getLogLevel())
		if (setLogLevelResult.isErr()) {
			return err(setLogLevelResult.error);
		}

		const lambda: KurtosisLambda = new ExampleKurtosisLambdaConfigurator();
		return ok(lambda);
	}

	private static setLogLevel(logLevelStr: string): Result<null, Error> {
		let logLevelDescStr: string = logLevelStr;
		if (logLevelStr === null || logLevelStr === undefined || logLevelStr === "") {
			logLevelDescStr = DEFAULT_LOG_LEVEL;
		}
		const logLevelDesc: log.LogLevelDesc = logLevelDescStr as log.LogLevelDesc
		log.setLevel(logLevelDesc);
		return ok(null);
	}
}