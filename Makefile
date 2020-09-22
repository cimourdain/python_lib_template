PROJECT_NAME = lib_name
PYVERSION ?= 3.6.10
POETRY_VERSION ?= 1.0.9

DOCKER_CONTAINER_NAME = $(APP_NAME)-$(PYVERSION)
DOCKER_CMD_ENV_VARS = PROJECT_NAME=$(PROJECT_NAME) PYVERSION=$(PYVERSION)
DOCKER_RUN = $(DOCKER_CMD_ENV_VARS) docker-compose run --rm development

PYTEST_OPTIONS = -x -vvv
TESTS_FOLDERS = tests
SAMLPLES_FOLDERS = samples
BLACK_FOLDERS = $(PROJECT_NAME) $(TESTS_FOLDERS) $(SAMPLES_FOLDERS)
ISORT_FOLDERS = $(PROJECT_NAME) $(TESTS_FOLDERS) $(SAMPLES_FOLDERS)
MYPY_FOLDERS = $(PROJECT_NAME)



shell:
	$(DOCKER_RUN) bash

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

test:
	$(DOCKER_RUN) bash -c "poetry run pytest --cov=$(PROJECT_NAME) tests/ $(PYTEST_OPTIONS)"

test-report:
	$(DOCKER_RUN) bash -c "poetry run pytest --cov=$(PROJECT_NAME) tests/ --cov-report html"

format:
	$(DOCKER_RUN) bash -c "poetry run black $(BLACK_FOLDERS)"
	$(DOCKER_RUN) bash -c "poetry run isort -rc $(ISORT_FOLDERS)"
	$(DOCKER_RUN) bash -c "poetry run radon cc -a -nb $(RADON_FOLDERS)"


style:
	$(DOCKER_RUN) bash -c "poetry run black $(BLACK_FOLDERS) --check --diff"
	$(DOCKER_RUN) bash -c "poetry run flake8 $(FLAKE8_FOLDERS)"
	$(DOCKER_RUN) bash -c "poetry run isort --check-only -rc $(ISORT_FOLDERS)"
	$(DOCKER_RUN) bash -c "poetry run mypy $(MYPY_FOLDERS)"
	$(DOCKER_RUN) bash -c "poetry run xenon --max-absolute B --max-modules A --max-average A $(RADON_FOLDERS)"

docs:
	$(DOCKER_RUN) bash -c "poetry run mkdocs build --clean"


docs-serve:
	# use docker inspect to find the ip where the doc is rendered
	$(DOCKER_RUN) bash -c "PYTHONPATH=. poetry run mkdocs serve"

ci: style test docs

clean:
	bash scripts/docker stop_running_containers $(PROJECT_NAME)*
	bash scripts/docker remove_containers $(PROJECT_NAME)*
	bash scripts/docker clean_images $(PROJECT_NAME)*

.PHONY: shell init test test-report format style docs docs-serve ci clean
