## About [![build status](https://secure.travis-ci.org/SaltwaterC/serverspec-aws.png?branch=master)](https://travis-ci.org/SaltwaterC/serverspec-aws)

Serverspec resources for AWS using AWS SDK for Ruby v2.

## Documentation

The documentation is available as [GitHub page](http://saltwaterc.github.io/serverspec-aws/).

## Usage

There aren't examples per se, but you can take a peek at the spec directory. The integration tests against itself also shows the usage mode. However, in real world use cases, the stubbing of the AWS SDK is (obviously) not necesary, hence you don't need to pass the instance argument for the resource classes which was implemented as a testing feature. Also, the spec_helper doesn't need to enable the stub_responses for real world use cases.
