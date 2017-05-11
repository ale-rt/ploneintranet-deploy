# Add help text after each target name starting with ' \#\# '
help:
	@grep " ## " $(MAKEFILE_LIST) | grep -v MAKEFILE_LIST | sed 's/\([^:]*\).*##/\1\t/'

buildout: bin/buildout  ## Build a ploneintranet gaia installation
	bin/buildout -v

start:  ##         Start all services
	sudo service redis-server start
	bin/supervisord


# override devel target with no-op for easy re-use of buildout.d/*cfg
fetchrelease:
	@/bin/true

warn: ##  	 ---- beyond here be dragons -----------------------



####################################################################
# docker.io

PROJECT=quaive/gaia

docker-build: .ssh/known_hosts  ## Create docker container
	docker build -t $(PROJECT) .

docker-run:  ## Run docker container
	docker run -i -t \
                --net=host \
                -v /var/tmp:/var/tmp \
                -v $(SSH_AUTH_SOCK):/tmp/auth.sock \
                -v $(HOME)/.bashrc:/app/.bashrc \
                -v $(HOME)/.buildout:/app/.buildout \
                -v $(HOME)/.pypirc:/app/.pypirc \
                -v $(HOME)/.gitconfig:/app/.gitconfig \
                -v $(HOME)/.gitignore_global:/app/.gitignore_global \
                -e SSH_AUTH_SOCK=/tmp/auth.sock \
		-e PYTHON_EGG_CACHE=/var/tmp/python-eggs \
                -v $(PWD):/app -w /app -u app $(PROJECT)
.ssh/known_hosts:
	mkdir -p .ssh
	echo "|1|YftEEH4HWPOfSNPY/5DKE9sxj4Q=|UDelHrh+qov24v5GlRh2YCCWcRM= ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==" > .ssh/known_hosts

####################################################################
# Guido's lazy targets


gitlab-ci: bin/buildout
	bin/buildout -c gitlab-ci.cfg

bin/buildout: bin/python2.7
	@bin/pip install -r requirements.txt

bin/python2.7:
	# This is a workaround for ubuntu 16.04 broken pip
	# see: https://github.com/quaive/gaia/issues/2
	@LC_ALL=C virtualenv --clear -p python2.7 .

clean: ## 	 Remove buildout artefacts
	rm bin/* .installed.cfg || true

solr-clean:  ## Nuke solr database
	rm -rf parts/solr parts/solr-test var/solr var/solr-test bin/solr-instance bin/solr-test

db-clean:  ## Nuke ZODB
	bin/supervisorctl shutdown || true
	@echo "This will destroy your local database! ^C to abort..."
	@sleep 10
	rm -rf var/filestorage var/blobstorage

all-clean: db-clean solr-clean clean  ## Nuke everything

allclean: all-clean



####################################################################
# Testing

test-docsplit:  ## Verify that docsplit dependencies are installed
	@docsplit images -o /tmp testfiles/plone.pdf
	@docsplit images -o /tmp testfiles/minutes.docx
	@echo "Docsplit seems to be installed OK, no errors."

# inspect robot traceback:
# bin/robot-server ploneintranet.suite.testing.PLONEINTRANET_SUITE_ROBOT
# firefox localhost:55001/plone
# To see the tests going on, use DISPLAY=:0, or use Xephyr -screen 1024x768 instead of Xvfb
test-robot: ## Run robot tests with a virtual X server
	Xvfb :99 1>/dev/null 2>&1 & DISPLAY=:99 bin/test -t 'robot'
	@ps | grep Xvfb | grep -v grep | awk '{print $2}' | xargs kill 2>/dev/null

test-norobot: ## Run all tests apart from robot tests
	bin/test -t '!robot'

test: test-docsplit  ## 	 Run all tests, including robot tests with a virtual X server
	Xvfb :99 1>/dev/null 2>&1 & DISPLAY=:99 bin/test
	@ps | grep Xvfb | grep -v grep | awk '{print $2}' | xargs kill 2>/dev/null
