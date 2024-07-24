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

4. Create environment file and add secrets
	Add an `.env` file in your repository's root directory and add the following key value-pairs:
```
	NEXUS_ADMIN_PASSWORD=
	NEXUS_USER_1_ID=team-1
	NEXUS_USER_1_EMAIL=
	NEXUS_USER_1_PWD=
        NEXUS_USER_2_ID=team-2
        NEXUS_USER_2_EMAIL=
        NEXUS_USER_2_PWD=
```

## Usage (Exercises)
1. Add your Remote Hostname and IP to config/remote.properties

	First, you have to add the IP address of your remote machine and the root user to `config/remote.properties` file.

2. Install Java 11 and run nexus with a newly created user account on remote server

	To install dependencies remotely, run `.scripts/remote-install-nexus-repo.sh`

3. To kill the running server check the logs from step 3 for its Process ID (PID).

	To kill the node server, run `kill <PID>` on the remote server.

4. Login to nexus at IP address defined in config/remote.properties and port 8081
	
	a. Change the default admin user password.
	b. Create new blob store for team 1 and new blob store for team 2
	c. Create new npm-hosted repository for team 1 and maven-hosted repository for team 2
	d. Create new users for team-1 and team-2 with nx-anonymous privilege
	e. Create new nexus-npm-hosted role with nx-repository-admin-npm-npm-hosted-* privilege and assign to team-1 user
        f. Create new nexus-maven-hosted role with nx-repository-admin-maven2-maven-hosted-* privilege and assign to team-2 user
	g. 

## Usage (Demo Projects)


