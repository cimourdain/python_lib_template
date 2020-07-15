PROJECT_NAME = lib_name
PYVERSION ?= 3.6.10
POETRY_VERSION ?= 1.0.9

DOCKER_CONTAINER_NAME = $(APP_NAME)-$(PYVERSION)
DOCKER_CMD_ENV_VARS = PROJECT_NAME=$(PROJECT_NAME) PYVERSION=$(PYVERSION)
DOCKER_RUN = $(DOCKER_CMD_ENV_VARS) docker-compose run --rm development

BLACK_FOLDERS = $(PROJECT_NAME) tests samples
ISORT_FOLDERS = $(PROJECT_NAME) tests samples
MYPY_FOLDERS = $(PROJECT_NAME)


.PHONY: shell
shell:
	$(DOCKER_RUN) bash

.PHONY: init
init:
	docker build --pull \
		--rm \
		-f Dockerfile \
		-t "$(PROJECT_NAME)/dev:$(PYVERSION)" \
		--target development \
		--build-arg IMAGE_NAME="$(PYVERSION)-slim" \
		--build-arg POETRY_VERSION=$(POETRY_VERSION) \
		--build-arg PROJECT_NAME=$(PROJECT_NAME) \
		--build-arg USER_NAME=$(PROJECT_NAME) \
		--build-arg USER_UID=$(shell id -u $$USER) \
		--build-arg USER_GID=$(shell id -g $$USER) \
		.

	# create container and intsall lib
	$(DOCKER_CMD_ENV_VARS) docker-compose run development

.PHONY: test
test:
	$(DOCKER_RUN) bash -c "poetry run pytest --cov=$(PROJECT_NAME) tests/ -x"

.PHONY: format
format:
	$(DOCKER_RUN) bash -c "poetry run black $(BLACK_FOLDERS) && poetry run isort -rc $(ISORT_FOLDERS)"

.PHONY: style
style:
	$(DOCKER_RUN) bash -c "poetry run black $(BLACK_FOLDERS) --check --diff && poetry run isort --check-only -rc $(ISORT_FOLDERS) && poetry run mypy $(MYPY_FOLDERS)"

.PHONY: docs
docs:
	$(DOCKER_RUN) bash -c "poetry run mkdocs build --clean"


.PHONY: docs-serve
docs-serve:
	# use docker inspect to find the ip where the doc is rendered
	$(DOCKER_RUN) bash -c "PYTHONPATH=. poetry run mkdocs serve"

.PHONY: ci
ci: style test docs

.PHONY: clean
clean:
	bash scripts/docker stop_running_containers ${PROJECT_NAME}*
	bash scripts/docker remove_containers ${PROJECT_NAME}*
	bash scripts/docker clean_images ${PROJECT_NAME}*
