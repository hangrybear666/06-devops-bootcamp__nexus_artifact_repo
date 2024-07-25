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

5. Ensure Java 17, gradle 7.4, maven, node and npm are installed on your local machine.

	Make sure to check https://docs.gradle.org/current/userguide/compatibility.html for the correct version compatibility between gradle and java. I can recommend using SDKMAN! to install different versions of gradle, maven and jdk on linux. https://sdkman.io/install. 

For node and npm installed in the local user account only, I can recommend Node Version Manager (NVM) https://github.com/nvm-sh/nvm?tab=readme-ov-file#installing-and-updating on linux. 

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
        c. Create new users for team-1 and team-2
	d. Create new npm-hosted repository for team 1 and maven-hosted repository for team 2
	e. Create new nexus-npm-hosted role with `nx-repository-admin-npm-npm-hosted-*` and `nx-repository-view-npm-npm-hosted-*` privilege and assign to team-1 user
        f. Create new nexus-maven-hosted role with `nx-repository-admin-maven2-maven-hosted-*` and `nx-repository-view-maven2-maven-hosted-*` privilege and assign to team-2 user
	g. In Nexus, navigate to Realms and add `npm Bearer Token Realm` as active.

5.  Clone npm, gradle and maven git repositories to your local git folder.

```
	cd GIT_DIRECTORY
	git clone https://gitlab.com/twn-devops-bootcamp/latest/05-cloud/cloud-basics-exercises
	git clone https://gitlab.com/twn-devops-bootcamp/latest/06-nexus/java-maven-app
	git clone https://gitlab.com/twn-devops-bootcamp/latest/06-nexus/java-app
```

6. Add your git directory to config/local.properties
	
	Add `GIT_DIRECTORY=/[PATH_TO_GIT]` key=value pair to `config/local.properties`

7. Publish a node.js package to your npm-hosted repository in nexus.

	Execute `./build-and-publish-npm.sh` and enter the username team-1 and password from step 4c when prompted.

8. Publish a gradle java application to maven-hosted repository. 

	Navigate to `java-app` in your GIT_DIRECTORY and change the line in `build.gradle` to match your repo url:
```
	url "http://xx.xx.xx.xx:xxxx/repository/maven-snapshots/"

```
	In `gradle.properties` change user and password to the ones from step 4c.
```
repoUser = xxxxxxx
repoPassword = xxxxxxx
```

	Then execute
```
	gradle clean build
	gradle publish
```

9. Publish a maven java application to maven-hosted repository.

	Navigate to `java-maven-app` in your GIT_DIRECTORY and replace the `distributionManagement` the line in `pom.xml` to match your repo url:

```
    <distributionManagement>
        <repository>
	    <name>Maven Hosted</name>
            <id>nexus</id>
            <url>http://xxx.xxx.xx.xx:8081/repository/maven-hosted/</url>
        </repository>
    </distributionManagement>

```
	Execute `mvn package` then navigate to your user's home directory where a hidden .m2 folder should have been created after executing the package command. In the .m2 folder create a file called `settings.xml` and add (with your password):

```
<settings>
  <servers>
    <server>
      <id>nexus</id>
      <username>team-2</username>
      <password>xxxxxxxxxxxxx</password>
    </server>
  </servers>
</settings>

``` 

	Then execute `mvn deploy`
## Usage (Demo Projects)

1. The exercises already cover nexus hosting, gradle and maven publishing and no further demonstration is required.


