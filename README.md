# Elastrix CLI
The Elastrix CLI is a command line interface for managing cloud application webserver configurations. It works with Elastrix based machine images launched on AWS. The pre-configured machine images are available [here](https://elastrix.io/apps) and can be launched via the [AWS Marketplace](https://aws.amazon.com/marketplace/seller-profile?id=29220b8c-675b-4421-a322-b24525fb7858&ref=dtl_B01G28SOHY).

The CLI is distributed via a Debian repository hosted on S3. The included Gruntfile references the repository but you will not have permissions to publish to it without the GPG key. If you would like to contribute, please see the contribution guidelines.

## Configuration and Requirements
Requires Linux based OS (debian/ubuntu preferred) with:

 - devscripts (sudo apt-get install devscripts)
 - debhelper (sudo apt-get install debhelper)
 - Node.js
 - NPM
 - grunt-cli
 - [deb-s3](https://github.com/krobertson/deb-s3)
   - sudo apt-get install ruby ruby-dev zlib1g-dev
   - sudo gem install deb-s3

To deploy the debian repo to S3, configure the AWS credentials in a file called `/aws.json`. These should be scoped down IAM credentials that have a policy for S3 Access to the deployment bucket.

```
{
  "accessKeyId": "1234",
  "secretAccessKey": "1234"
}
```

## Developing Elastrix Command Line Tools
Tools are separated into modules that are automatically compiled into the elastrix cli using `grunt build`
Create a module in the modules/ folder with simple logic related to it's function and/or app i.e.

    apache.sh
or
    setup.sh
    
The grunt build will compile ALL modules, but you need to add your module to the Gruntfile.js so that it is
included in the build L79 in the Grunfile.js.

## Building Debian Packages
First install the dependencies (see above for requirements). Than build the debian package with Grunt (this concats all scripts into on executable `elastrix`.

    grunt build

 The resulting debian package will be in bin/elastrix.

## Uploading to APT Repo
upload to s3 apt repo (uses [deb-s3](https://github.com/krobertson/deb-s3)). You'll need to have the PGP key on your system for this to work.

    grunt upload
    
You should bump the package.json version when uploading if you want users to receive the update via apt-get update / upgrade. The package.json version is what is used in the debian build.

## Installing with APT
Add apt sources and pull down the key (requires sudo):

    sudo grunt setup-apt-repo

APT configuration is also available via curl:

    curl -L http://elastrix.io/start | sudo bash