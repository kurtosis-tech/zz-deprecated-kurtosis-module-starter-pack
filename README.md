Kurtosis Lambda Starter Pack
============================
This repo contains:

1. Libraries in various languages for create custom implementations of Kurtosis Lambda
1. Example implementations of Kurtosis Lambda in each language
1. Infrastructure for bootstrapping a new Kurtosis Lambda, that you can use to create your own customized Kurtosis Lambda

Kurtosis Lambda Quickstart
--------------------
Prerequisites:
* A [Kurtosis user account](https://www.kurtosistech.com/sign-up)
* `git` installed on your machine
* `docker` installed on your machine

Quickstart steps:
1. Clone this repo's `master` branch: `git clone --single-branch --branch master git@github.com:kurtosis-tech/kurtosis-lambda-starter-pack.git`
1. View [the supported languages](https://github.com/kurtosis-tech/kurtosis-lambda-starter-pack/blob/master/supported-languages.txt) and choose the language you'd like your Kurtosis Lambda in
1. Run `bootstrap/bootstrap.sh` and follow the helptext instructions to fill in the script arguments and bootstrap your repo
1. Customize your own Kurtosis Lambda redefining the generated files inside the `impl` folder
    1. Rename the files and objects, if you want, using a name that describes the implementation of your Kurtosis Lambda 
    1. Implement the functionality of your Kurtosis Lambda inside the execute method
       1. Define what parameters it will receive and what parameters it will return
       1. A good practice is to validate and sanitize the received parameters
    1. Write the Kurtosis Lambda Configurator for your own Kurtosis Lambda, define inside this which parameters will be used to create and configure the Kurtosis Lambda
    1. Refactor the main method inside the main file so that it now uses your own custom Kurtosis Configurator
    1. Run `scripts/build.sh`, when you finish your Kurtosis Lambda, to update the Docker image
   