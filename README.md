### ec2-manager

This is a (*very*) simple EC2 state manager that basically allows for starting,
stopping, restarting, and checking the status of a (for now) single EC2 instance.

### Usage

First, you need to have [docker](https://docs.docker.com/get-docker/) installed.

Then, in order to use the `ec2-manager`, you need to create a file `.env.ec2.manager` 
with environmental variables that are going to be used by the docker image.
The file should look like this:

```shell
REGION=<YOUR_AWS_REGION>
INSTANCE_ID=<YOUR_INSTANCE_ID>
AWS_ACCESS_KEY_ID=<YOUR_AWS_KEY_ID>
AWS_SECRET_ACCESS_KEY=<YOUR_AWS_ACCESS_KEY>
```

Once all this is set up, run the following command:

```shell
docker run --env-file <PATH/TO/YOUR/.env.ec2.manager> -it baduker/ec2-manager --check-status
```

As a sample output, you should get something like this:

```shell
$ docker run --env-file .env.e2.manager -it baduker/ec2-manager --check-status
The EC2 i-12345EXAMPLE is stopped.
Would you like to start it? [y/N] y
The EC2 i-12345EXAMPLE is "pending".
Waiting for the EC2 i-12345EXAMPLE to start.
The EC2 i-12345EXAMPLE is running.
$ docker run --env-file .env.e2.manager -it baduker/ec2-manager --check-status
The EC2 i-12345EXAMPLE is running.
```

The script has the following options:

```
--start-ec2
    Start an EC2, if it's not already running.
--stop-ec2
    Stop an EC2, if it's not already stopped.
--restart-ec2
    Restart an EC2, which on AWS basically means stopping and then starting
    the instance again.
--check-status
    Check the current status of an EC2. Can be either running or stopped.
```