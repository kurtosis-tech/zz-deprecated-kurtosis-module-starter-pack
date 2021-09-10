# TBD
### Changes
* Bootstrapping no longer builds the Lambda, to reduce the amount of text thrown at the user (but we instruct the user to do so after bootstrapping)

### Features
* Bootstrapping automatically copies over Git & Docker ignore files
* Copy Kurtosis Lambda static-files folder into the Docker image

### Fixes
* Upgrade to Kurt Client 0.15.0, which fixes a typo with a method name in ContainerRunConfigBuilder

# 0.1.3
### Changes
* Switch to using productized docs-checker orb

### Features
* Added Typescript

### Fixes
* Added error-checking in `validate-all-bootstraps` to ensure that custom bootstrap params are defined for all supported languages

# 0.1.2
### Features
* Added the Unlicense, dedicating this to the public domain
* Validate bootstraps on every PR

### Fixes
* Fixed escaping of backticks in the README file generated during bootstrap
* Fixed bootstrap deleting sed-replace files after Git init, which meant the newly-generated repos would already have unstaged changes

# 0.1.1
### Features
* Added `ExampleLambda` which is an example of how to implement a Kurtosis Lambda
* Added `ExampleLambdaConfigurator` and `ExampleLambdaArgs` which are used to start the `ExampleLambda`implementation 
* Added the main go file for startup the Lambda
* Added Dockerfile with build and run configurations
* Added Circle CI configuration file
* Added golang directory and go mod file
* Added shell script to execute kurtosis release repository script for this repository
* Implement `ExampleLambda` execute method
* Added bootstrap script; users can use it to start creating their own implementation of Kurtosis Lambda
* Added supported-languages file
* Added script for validating bootstrap during CI

# 0.1.0
* Init commit
