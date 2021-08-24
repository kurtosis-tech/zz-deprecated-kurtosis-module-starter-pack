const SUCCESS_EXIT_CODE: number = 0;
const FAILURE_EXIT_CODE: number = 1;

// >>>>>>>>>>>>>>>>>>> REPLACE WITH YOUR OWN CONFIGURATOR <<<<<<<<<<<<<<<<<<<<<<<<
const configurator: KurtosisLambdaConfigurator = new KurtosisLambdaConfigur
// >>>>>>>>>>>>>>>>>>> REPLACE WITH YOUR OWN CONFIGURATOR <<<<<<<<<<<<<<<<<<<<<<<<


lambdaExecutor := execution.NewKurtosisLambdaExecutor(configurator)
if err := lambdaExecutor.Run(); err != nil {
    logrus.Errorf("An error occurred running the kurtosis-lambda executor:")
    fmt.Fprintln(logrus.StandardLogger().Out, err)
    os.Exit(failureExitCode)
}
os.Exit(successExitCode)