Kurtosis Lambda Starter Pack
============================
This repo contains:

1. Example implementations of a Kurtosis Lambda in each language
1. Infrastructure for bootstrapping a new Kurtosis Lambda, that you can use to create your own customized Kurtosis Lambda

Kurtosis Lambda Quickstart
--------------------------
Prerequisites:
* A [Kurtosis user account](https://www.kurtosistech.com/sign-up)
* `git` installed on your machine
* `docker` installed on your machine

Quickstart steps:
1. Clone this repo's `master` branch: `git clone --single-branch --branch master git@github.com:kurtosis-tech/kurtosis-lambda-starter-pack.git`
1. View [the supported languages](https://github.com/kurtosis-tech/kurtosis-lambda-starter-pack/blob/master/supported-languages.txt) and choose the language you'd like your Kurtosis Lambda in
1. Run `bootstrap/bootstrap.sh` and follow the helptext instructions to fill in the script arguments and bootstrap your repo
1. Customize your own Kurtosis Lambda by editing the generated files inside the `/path/to/your/code/repos/kurtosis-lambda/impl` folder
    1. Rename files and objects, if you want, using a name that describes the functionality of your Kurtosis Lambda 
    1. Write the functionality of your Kurtosis Lambda inside your implementation of the `KurtosisLambda.execute` method by using the serialized parameters (validating & sanitizing the parameters as necessary)
    1. Write an implementation of `KurtosisLambdaConfigurator` that accepts configuration parameters and produces an instance of your custom Kurtosis Lambda
    1. Edit the main file and replace the example `KurtosisLambdaConfigurator` with your own implementation that produces your custom Lambda
    1. Run `path/to/your/code/repos/scripts/build.sh` to package your Kurtosis Lambda into a Docker image that can be used inside Kurtosis
   