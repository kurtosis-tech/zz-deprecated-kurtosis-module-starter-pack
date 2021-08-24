import { KurtosisLambdaConfigurator, KurtosisLambdaExecutor } from "kurtosis-lambda-api-lib";
import { ExampleKurtosisLambdaConfigurator } from "./impl/example_kurtosis_lambda_configurator";
import * as log from "loglevel";

const SUCCESS_EXIT_CODE: number = 0;
const FAILURE_EXIT_CODE: number = 1;

// >>>>>>>>>>>>>>>>>>> REPLACE WITH YOUR OWN CONFIGURATOR <<<<<<<<<<<<<<<<<<<<<<<<
const configurator: KurtosisLambdaConfigurator = new ExampleKurtosisLambdaConfigurator();
// >>>>>>>>>>>>>>>>>>> REPLACE WITH YOUR OWN CONFIGURATOR <<<<<<<<<<<<<<<<<<<<<<<<

const lambdaExecutor: KurtosisLambdaExecutor = new KurtosisLambdaExecutor(configurator)
lambdaExecutor.run().then(runLambdaResult => {
    let exitCode: number = SUCCESS_EXIT_CODE;
    if (runLambdaResult.isErr()) {
        log.error("An error occurred running the Kurtosis Lambda executor:")
        console.log(runLambdaResult.error);
        exitCode = FAILURE_EXIT_CODE;
    }
    process.exit(exitCode);
})