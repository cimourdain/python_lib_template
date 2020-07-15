# Python lib template
[![Build Status](https://travis-ci.com/cimourdain/python_lib_template.svg?branch=master)](https://travis-ci.com/cimourdain/python_lib_template)
[![Documentation Status](https://readthedocs.org/projects/python-lib-template/badge/?version=latest)](https://python-lib-template.readthedocs.io/en/latest/?badge=latest)
![docker](https://badgen.net/badge/icon/docker?icon=docker&label)
![poetry](https://badgen.net/badge/packaging/poetry/cyan)
[![black](https://badgen.net/badge/code%20style/black/000)](https://github.com/ambv/black)
[![mypy](https://badgen.net/badge/code%20style/mypy/pink)](https://github.com/python/mypy)

Dockerized python lib template using poetry.


## Features

 - Dockerized environment (no other prerequisite than docker installed)
 - Multiple python version
 - CI for Travis
 - Documentation for readthedocs.io (built with mkdocs-materialized)
 - Dev tools: pytest, black, mypy etc.

## Usage
### Pre Install
Set your project lib name:

 - rename lib_name folder
 - update project name & settings in pyproject.toml, Makefile, mkdocs.yml

Define the python versions you want your lib to run:

 - Set all versions for ci in `.travis.yml`
 - Set the default python version in `Makefile` 

### Install
Install project with `make init`


### Usage

See commands available in Makefile:

 - `make test` run all tests for project
 - `make format` apply black and isort
 - `make style` check with black, isort and mypy
 - `make docs` build documentation 
 - `make clean` delete projects containers and images 
 - `make shell` enter the docker container to run `poetry run ...` commands manually

### Documentation
To serve documentation, use `make docs-serve`, the documentation is rendered to <docker-container-ip>:8000 (use docker inspect to get container IP)
