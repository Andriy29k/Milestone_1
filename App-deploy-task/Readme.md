# Monitoring System

> DevOps internship task

## General info

This repository contains a source code of the Class Schedule Project.

The main goal of the project is designing a website where the university or institute staff will be able to create, store and display their training schedules.

## Getting Started

### Prerequisites

> Deploy locally:
- Git
- [Gradle](https://gradle.org/releases/) v6.8
- [PostgreSQL](https://www.postgresql.org/download/) Latest 
- [Apache Tomcat](https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.50/) v9.0.50 
- [MongoDB](https://www.mongodb.com/try/download/community)
- [Redis](https://redis.io/downloads/)
- [NodeJS](https://nodejs.org/en/download) v14.x.x
- [JDK 11](https://www.oracle.com/java/technologies/javase/jdk11-archive-downloads.html)
- SQL Dump file

> Deploy with Docker:
- Docker

### Environment variables setup

1. Add Java to path.
     Edit path and add value: %JAVA_HOME%\bin

2. Create JAVA_HOME environment variable and add path to directory.
     JAVA_HOME:
        determine path to Java directory (example: C:\Program Files\Java\jdk-11).

3. Add Gradle to path.

# Local repository creating 
    
    $ cd /path/to/your/workdir
    $ git clone https://github.com/mentorchita/internship_project.git
    
# Postgres configuration

1. Create user in PostgreSQL.
2. Crate database in PostgreSQL.
3. Make PostgreSQL restore in terminal:
     $psql -U 'your_user' -d 'your_db_name' -f /path/to/dump/file
4. Go to `internship_project\src\main\resources\hibernate.properties` and configure URL, USER, and PASSWORD.

# Redis configuration

1. Start Redis.
2. Setup configuration in `internship_project\src\main\resources\cashe.properties`

# Mongo DB configuration

1. Start MongoDB.
2. Open new connection names 'schedules'.

# Backend server starting with Tomcat

### Gradle build

1. Go to internship project directory and open terminal at the same directory.
2. Execute next command:
     $ gradle clean war
3. Rename created class_schedules.war(`.gradle\build\libs\`) file to 'ROOT.war'.

### Tomcat deploying
### Method 1

1. Go to Tomcat directory/conf, open tomcat-users.xml and add next lines inside <tomcat-users> tags:
     $<role rolename="tomcat"/>
     $<user username="admin" password="admin123" roles="manager-gui"/>
2. Go to Tomcat directory/bin and open `startup.bat`.
3. Go to [localhost](http://localhost:8080/), click `Manager app` in right, execute login by credential in previous step.
4. Go to WAR file to deploy topic and upload `ROOT.war` and click `Deploy`.

### Method 2
1. Go to Tomcat directory/conf, open tomcat-users.xml and add next lines inside <tomcat-users> tags:
     $<role rolename="tomcat"/>
     $<user username="admin" password="admin123" roles="manager-gui"/>
2. Put ROOT.war to `Tomcat/webapps`
3. Go to Tomcat directory/bin and open `startup.bat`.
4. Go to [localhost](http://localhost:8080/), click `Manager app` in right, execute login by credential in previous step.
5. Check status of servers.

# Front-end deploying

1. Create .env file with next content in `internship_project/frontend`:
    $ REACT_APP_API_BASE_URL=http://localhost:8080/
2. In internship_project open terminal and execute next commands:
    $ npm install
    $ npm start

## License

This software is licensed under the [GNU General Public License, version 3](
./LICENSE).