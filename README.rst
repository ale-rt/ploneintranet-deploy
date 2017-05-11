GAIA
====

This is the Quaive *Gaia* release of Plone intranet.

Prepare system
--------------

See https://docs.ploneintranet.org/installation/quickstart.html

On Ubuntu 16.04.2 LTS:

As root::

  apt-get update && apt-get install -y \
      cron \
      curl \
      file \
      firefox \
      gcc \
      gettext \
      ghostscript \
      git-core \
      graphicsmagick \
      jed \
      libenchant-dev \
      libffi-dev \
      libfreetype6-dev \
      libjpeg-dev \
      libldap2-dev \
      libreoffice \
      libsasl2-dev \
      libsqlite3-dev \
      libxslt1-dev \
      make \
      pdftk \
      poppler-data \
      poppler-utils \
      python-dev \
      python-gdbm \
      python-lxml \
      python-pip \
      python-tk \
      python-virtualenv \
      redis-server \
      ruby2.3 \
      ruby2.3-dev \
      wget \
      wv \
      xvfb \
      zlib1g-dev

   gem install docsplit

   locale-gen en_US.UTF-8 nl_NL@euro

Run the rest not as root but as a non-privileged user::

  git clone https://github.com/ploneintranet/ploneintranet-deploy
  cd ploneintranet-deploy

  make test-docsplit

If that test fails, your system environment is not complete. Fix that first.
Once this test passes, you're ready to bootstrap and run the buildout.


Buildout and start
------------------

As a non-privileged user, go to your `gaia` install and bootstrap and run the buildout::

  make buildout

That should give some compilation warnings but no real errors.
Then you can start the system::

  make start

This starts zeo, two instances, solr and celery. Redis should already be
running at the system level. You don't need LDAP.

This should result in a running instance at port 8080.
Open the ZMI at <yourhost>:8080.
Change the admin password.

Now add a Plone site.

In the ZMI, in that Plone site, run the genericsetup import step "Plone Intranet: Suite".

This should result in an empty Quaive install at <yourhost>:8080.
Do not do anything further as the ZMI admin user.

Configure users
---------------

Instead, prepare some user accounts following the instructions you can find here:
https://docs.ploneintranet.org/development/components/userprofiles.html
Don't forget to also upload avatar images, that looks much more nicely.

Now log in as one of the users you created on <yourhost>:8080.
That's your working Quaive install.


Add web server and load balancer
--------------------------------

At this stage you already have a supervisor running:

- instance
- instance2
- zeo
- solr
- celery

And redis should be running at the system level.

Next step is to make this system accessible from the outside, by adding at least Nginx and probably also HAProxy. See: http://docs.quaive.net/installation/production.html
