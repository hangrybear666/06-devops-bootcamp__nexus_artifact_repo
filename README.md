# Hosting Sonatype Nexus Repository on Remote Linux VPS

This repo......

The main deployment is:
- A Nexus Repository running with JDK 11 on DigitalOcean's Linux VPS Environment.

## Setup

1. Pull SCM

Pull the repository locally by running 
```
  git clone https://github.com/hangrybear666/06-devops-bootcamp__nexus_artifact_repo.git 
```

2. Create Remote Linux VPS and configure

	Generate local ssh key and add to remote VPS's `authorized_keys` file.

3. Install additional dependencies on remote

	Some Linux distros ship without the `netstat` command we use. In that case run `apt install net-tools`


## Usage (Exercises)
1. Add your Remote Hostname and IP to config/remote.properties

	First, you have to add the IP address of your remote machine and the root user to `config/remote.properties` file.

2. Install Java 11 and run nexus with a newly created user account on remote server

	To install dependencies remotely, run `.scripts/remote-install-nexus-repo.sh`

5. To kill the running server check the logs from step 3 for its Process ID (PID).

	To kill the node server, run `kill <PID>` on the remote server.


## Usage (Demo Projects)


