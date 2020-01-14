ifneq (,)
.error This Makefile requires GNU Make.
endif

# -------------------------------------------------------------------------------------------------
# Default configuration
# -------------------------------------------------------------------------------------------------
.PHONY: help lint pycodestyle pydocstyle black dist sdist bdist build checkbuild deploy autoformat clean


VERSION = 2.7

# -------------------------------------------------------------------------------------------------
# Default Target
# -------------------------------------------------------------------------------------------------
help:
	@echo "lint             Lint source code"
	@echo "build            Build Python package"
	@echo "dist             Create source and binary distribution"
	@echo "sdist            Create source distribution"
	@echo "bdist            Create binary distribution"
	@echo "clean            Build"


# -------------------------------------------------------------------------------------------------
# Lint Targets
# -------------------------------------------------------------------------------------------------

lint: pycodestyle pydocstyle black

pycodestyle:
	docker run --rm -v $(PWD):/data cytopia/pycodestyle --show-source --show-pep8 badchars

pydocstyle:
	docker run --rm -v $(PWD):/data cytopia/pydocstyle badchars

black:
	docker run --rm -v ${PWD}:/data cytopia/black -l 100 badchars


# -------------------------------------------------------------------------------------------------
# Build Targets
# -------------------------------------------------------------------------------------------------

dist: sdist bdist

sdist:
	docker run \
		--rm \
		$$(tty -s && echo "-it" || echo) \
		-v $(PWD):/data \
		-w /data \
		-u $$(id -u):$$(id -g) \
		python:$(VERSION)-alpine \
		python setup.py sdist

bdist:
	docker run \
		--rm \
		$$(tty -s && echo "-it" || echo) \
		-v $(PWD):/data \
		-w /data \
		-u $$(id -u):$$(id -g) \
		python:$(VERSION)-alpine \
		python setup.py bdist_wheel --universal

build:
	docker run \
		--rm \
		$$(tty -s && echo "-it" || echo) \
		-v $(PWD):/data \
		-w /data \
		-u $$(id -u):$$(id -g) \
		python:$(VERSION)-alpine \
		python setup.py build

checkbuild:
	docker run \
		--rm \
		$$(tty -s && echo "-it" || echo) \
		-v $(PWD):/data \
		-w /data \
		python:$(VERSION)-alpine \
		sh -c "pip install twine \
		&& twine check dist/*"


# -------------------------------------------------------------------------------------------------
# Publish Targets
# -------------------------------------------------------------------------------------------------

deploy:
	docker run \
		--rm \
		$$(tty -s && echo "-it" || echo) \
		-v $(PWD):/data \
		-w /data \
		python:$(VERSION)-alpine \
		sh -c "pip install twine \
		&& twine upload dist/*"


# -------------------------------------------------------------------------------------------------
# Misc Targets
# -------------------------------------------------------------------------------------------------

autoformat:
	docker run \
		--rm \
		$$(tty -s && echo "-it" || echo) \
		-v $(PWD):/data \
		-w /data \
		cytopia/black -l 100 badchars
clean:
	-rm -rf badchars.egg-info/
	-rm -rf dist/
	-rm -rf build/
