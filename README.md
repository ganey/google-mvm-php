# google-mvm-php

Docker file for Google Managed VM for php, nginx and memcached. Works well for Laravel applications.

This is based on my older repo at ganey/gvm-docker

It runs a local memcached as a socket, but at current Google containers do come with a memcache server on port 11211 at the host 'memcache'

The app.yaml here is an example and is enough to get an app uploaded and running.

Health requests at _ah/health and _ah/start are currently not working.

Document Root is /var/www/public


This VM has only had basic testing for vulnerabilities, if you find any issues, please submit them / add a pull request.

## Quick Start

In your Dockerfile add:

~~~~
FROM ganey/google-mvm-php

ADD . /var/www
~~~~

This will add your current working directory to /var/www. Document Root is /var/www/public

Use the app.yaml here as an example (this starts the micro instance without scaling)

Nothing.php is not required to exist for this docker to work.

By default the docker will serve phpinfo();



To deploy to Google cloud, set your default project based on the current gcloud sdk docs (this are changing rapidly, please do this yourself)

~~~~
gcloud preview app deploy app.yaml
~~~~

This will take a while to serve and should deploy a phpinfo(); page.


If you get any issues, please open them on GitHub as issues.


## Local Usage

Clone this repository.

To build the docker locally:

~~~~
docker build -t=ganey/google-mvm-php .
~~~~

To build the docker locally with project files:

~~~~
#Uncomment the ADD . /var/www in the Dockerfile, change . to your project dir

docker build -t=ganey/google-mvm-php .
~~~~

To run the docker and mount a dir into the docker VM to track local file changes:

~~~~
docker run --name=gvm -v /e/websites/website-name:/var/www -p 8080:8080 ganey/google-mvm-php
~~~~

If you serve files at a different dir, just symlink /var/www/public to your new dir
E.g if you use public_html, add this to your Dockerfile

~~~~
RUN ln -s /var/www/public /var/www/public_html
~~~~

To deploy to Google cloud, set your default project based on the current gcloud sdk docs (this are changing rapidly, please do this yourself)

~~~~
gcloud preview app deploy app.yaml
~~~~

The docker will then build remotely on a self terminating compute instance, and then deploy as a Google MVM.



## Notes

For php apps you may wish to access Google services like you may have done on Google App Engine.

Check out the google/api-client composer package and create some service credentials in the console to use with these.


For CloudSQL you will probably want to setup SSL only access due to the dynamic IP address allocation of VM's
