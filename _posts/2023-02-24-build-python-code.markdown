---
layout: post
title:  Build and Release Python Code with Conda
date:   2023-02-23 12:00:00 -0000
tags: conda, anaconda, python, azure, pipelines, build, package, test, upload, release, devops, makefile
---

Building and releasing packages gives developers a mechanism to securely transfer versions of their code 
to other developers and infrastructure.

While developers can facilitate builds and releases in many ways, 
I've outlined one of my favorite approaches in the following four steps.

To exemplify each step, I've shared the commands that I use
to build and release the code saved in
[my template github repository][template-repository].


#### Prequisites
- Install [mini-conda]
- Understand Makefiles


![asset]


### 1. Create the Environment

Beginning with a virtual environment allows developers to easily install and manage the dependencies 
of the code that is to be packaged, along with the dependencies required by the conda build tools.

{% highlight bash %}
$ git clone https://github.com/pyt3r/template-package.git
$ cd template-package
{% endhighlight %}

{% highlight bash %}
$ make test-env
$ conda activate test-env
{% endhighlight %}

Uncovering the makefile command reveals that the environment is installed from the dependencies declared in
[template-package/ci/test-env-requirements.yml].

{% highlight bash %}
$ conda env create \
   --file ci/test-env-requirements.yml \
   --python=3.7
{% endhighlight %}


### 2. Build the Package
With the virtual environment activated, the build step, then, gathers and consolidates the python files into a 
standalone, installable tarball.

{% highlight bash %}
(test-env) $ make conda-package
{% endhighlight %}

Uncovering this makefile command reveals the following:

{% highlight bash %}
$ conda build . --output-folder=./
$ conda install ./**/*.tar.bz2
{% endhighlight %}


### 3. Test the Package
During testing, my preferred approach is to test the package and not the code, as it is the package that 
will ultimately be the artifact that is transferred to other developers.

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
{% endhighlight %}

Once uploaded, other developers will be able to install the package from an Anaconda channel.

{% highlight bash %}
(test-env) $ anaconda upload ./template*.tar.bz2
{% endhighlight %}

For example, installing the package associated with my Anaconda account may be accomplished, as follows:

{% highlight bash %}
(test-env) $ conda install -c pyt3r template
{% endhighlight %}


### Pipelining

Developers can leverage CI/CD pipeline tools to automate the aforementioned steps.  

Using Azure Pipelines, for example, the [builds][azure-build] for [my template github repository][template-repository] 
are triggered each time that the master branch changes.

This preference, along with the end-to-end build approach discussed in this post, 
has been configured in [template-package/azure-pipelines.yml].



[mini-conda]: https://docs.conda.io/en/latest/miniconda.html
[template-repository]: https://github.com/pyt3r/template-package
[template-package/ci/test-env-requirements.yml]: https://github.com/pyt3r/template-package/blob/master/ci/test-env-requirements.yml
[asset]: ../assets/2023-02-24-build-python-code.png
[azure-build]: https://dev.azure.com/pyt3r/template/_build
[template-package/azure-pipelines.yml]: https://github.com/pyt3r/template-package/blob/master/azure-pipelines.yml