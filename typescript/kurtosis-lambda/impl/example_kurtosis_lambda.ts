import { NetworkContext } from "kurtosis-core-api-lib";
import { KurtosisLambda } from "kurtosis-lambda-api-lib";
import { Result, ok, err } from "neverthrow";
import * as log from "loglevel";

const TIPS_REPOSITORY: string[] = [
    "Everything not saved will be lost.",
    "Don't pet a burning dog.",
    "Even a broken clock is right twice a day.",
    "If no one comes from the future to stop you from doing it, then how bad of a decision can it really be?",
    "Never fall in love with a tennis player. Love means nothing to them.",
    "If you ever get caught sleeping on the job, slowly raise your head and say 'In Jesus' name, Amen'",
    "Never trust in an electrician with no eyebrows",
    "If you sleep until lunch time, you can save the breakfast money.",
];

interface ExampleKurtosisLambdaParams {
    iWantATip: boolean;
}

class ExampleKurtosisLambdaResult {
    readonly tip: string

    constructor(tip: string) {
        this.tip = tip;
    }
}

export class ExampleKurtosisLambda implements KurtosisLambda {
    constructor() {}

    async execute(networkCtx: NetworkContext, serializedParams: string): Promise<Result<string, Error>> {
        log.info("Example Kurtosis Lambda receives serializedParams '" + serializedParams + "'");
        let params: ExampleKurtosisLambdaParams;
        try {
            params = JSON.parse(serializedParams)
        } catch (e: any) {
            // Sadly, we have to do this because there's no great way to enforce the caught thing being an error
            // See: https://stackoverflow.com/questions/30469261/checking-for-typeof-error-in-js
            if (e && e.stack && e.message) {
                return err(e as Error);
            }
            return err(new Error("Parsing params string '" + serializedParams + "' threw an exception, but " +
                "it's not an Error so we can't report any more information than this"));
        }

        const exampleKurtosisLambdaResult: ExampleKurtosisLambdaResult = new ExampleKurtosisLambdaResult(
            ExampleKurtosisLambda.getRandomTip(params.iWantATip)
        );

        let stringResult;
        try {
            stringResult = JSON.stringify(exampleKurtosisLambdaResult);
        } catch (e: any) {
            // Sadly, we have to do this because there's no great way to enforce the caught thing being an error
            // See: https://stackoverflow.com/questions/30469261/checking-for-typeof-error-in-js
            if (e && e.stack && e.message) {
                return err(e as Error);
            }
            return err(new Error("An error occurred serializing the Kurtosis Lambda result threw an exception, but " +
                "it's not an Error so we can't report any more information than this"));
        }

        log.info("Example Kurtosis Lambda executed successfully")
        return ok(stringResult);
    }

    private static getRandomTip(shouldGiveAdvice: boolean): string {
        let tip: string;
        if (shouldGiveAdvice) {
            // This gives a random number between [0, length)
            tip = TIPS_REPOSITORY[Math.floor(Math.random() * TIPS_REPOSITORY.length)];
        } else {
            tip = "Kurtosis Lambda Example won't enlighten you today."
        }
        return tip
    }
}