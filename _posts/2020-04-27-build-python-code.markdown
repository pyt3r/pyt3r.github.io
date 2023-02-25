---
layout: post
title:  Build and Release Python Code with Conda
date:   2020-04-27 00:00:00 -0000
tags: conda, anaconda, python, build, package, test, upload, release, devops, makefile
---

Building and releasing packages gives developers a mechanism to securely transfer versions of their code 
to other developers and infrastructure.

While developers can facilitate builds and releases in many ways, 
I've outlined one of my favorite approaches in the following four steps.

To exemplify each step, I've shared the commands that I use
to build and release the python code saved in
[my template github repository][template-repository].


#### Prequisites
- Install [mini-conda]
- Understand Makefiles


![asset]


### 1. Create the Environment

The virtual environment contains the dependencies of the code that is to be packaged,
along with the dependencies required by the conda build tools.

{% highlight bash %}
$ git clone https://github.com/pyt3r/template-package.git
$ cd template-package
{% endhighlight %}

{% highlight bash %}
$ make test-env
$ conda activate test-env
{% endhighlight %}

Uncovering the makefile command reveals that these dependencies are set in
[template-package/ci/test-env-requirements.yml].

{% highlight bash %}
$ conda env create \
   --file ci/test-env-requirements.yml \
   --python=3.7
{% endhighlight %}


### 2. Build the Package
The build step gathers and consolidates the python files into a tarball.

{% highlight bash %}
(test-env) $ make conda-package
{% endhighlight %}

Uncovering this makefile command reveals the following:

{% highlight bash %}
$ conda build . --output-folder=./
$ conda install ./**/*.tar.bz2
{% endhighlight %}


### 3. Test the Package
Upon invoking tests, it's critical to test the package and not the code.

To ensure that the tests run against the package,
the following makefile command navigates away from the importable code prior to running the tests.

{% highlight bash %}
(test-env) $ make test-package
{% endhighlight %}

Uncovering this makefile command reveals the following:

{% highlight bash %}
$ cd .. && \
   python -c "import template; template.test('unittests')" && \
    conda uninstall template -y --force && \
     cd template-package
{% endhighlight %}


### 4. Release the Package

Releasing the package requires login credentials for an Anaconda account, which can be created for free.

{% highlight bash %}
(test-env) $ anaconda login 
# --> enter your credentials
{% endhighlight %}

{% highlight bash %}
(test-env) $ anaconda upload ./template*.tar.bz2
{% endhighlight %}

Upon uploading the package, others will be able to install it. 
The package associated with my Anaconda account, for example, can be installed, as follows:

{% highlight bash %}
(test-env) $ conda install -c pyt3r template
{% endhighlight %}

[mini-conda]: https://docs.conda.io/en/latest/miniconda.html
[template-repository]: https://github.com/pyt3r/template-package
[template-package/ci/test-env-requirements.yml]: https://github.com/pyt3r/template-package/blob/master/ci/test-env-requirements.yml
[asset]: ../assets/2020-04-27-build-python-code.png
