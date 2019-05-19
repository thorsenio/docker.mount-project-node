# mount-project-node
Docker image for mounting a project into a containerized Node environment.

This package mounts the current directory into a Docker container that contains Node v10.14
and NPM v6.8.0.

## Dependencies
This module requires Bash \[version to be added] and Docker \[version to be added].

## Installation

To install only in the current project:

```bash
$ npm install --save-dev mount-project-node
```

To install globally:

```bash
$ npm install --global mount-project-node
```

## How to use

To mount a project into a container:

```bash
$ cd PATH/TO/PROJECT

# If installed globally
$ mount-project-node

# If installed in the project
$ npx mount-project-node
```

To exit the container:

```bash
[root@mount-node-project-X.X.X] exit
```
