cucumber-plugin
===

run cucumber tests under Jenkins CI

prerequisites
===

following packages should be installed:

- ruby installed with rvm in `single-user install mode`
- ruby bundler

exported builders
===

## cucumber_builder

### run cucumber tests

It is simple wrapper around `bundle exec cucumber` command.  Directory layout should follow this scheme:

    $WORKSPACE/cucumber/test-suite-one/
    $WORKSPACE/cucumber/test-suite-two/
    $WORKSPACE/cucumber/test-suite-three/
    # etc

- cucumber_publisher run `bundle exec cucumber` command from every subdirectory in `$WORKSPACE/cucumber/`

![layout](https://raw.github.com/melezhik/cucumber-plugin/master/images/layout.png "cucumber_publisher interface")

Environment setup
===

You can set environment variables via "Jenkins/Configuration/Global properties/Environment variables" interface to adjust plugin behavior.

## http_proxy
Standard way to do things when you behind http proxy server.

    http://my.proxy.server

## cucumber\_ruby\_version
cucumber_publisher runs tests with rvm installed ruby of `default version 1.8.7`, specify another one if you have ruby installed of another version.

    1.9.3

## LC_ALL
Setup your standard encoding.

    ru_RU.UTF-8

