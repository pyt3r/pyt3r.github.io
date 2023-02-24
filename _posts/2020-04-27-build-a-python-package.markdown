---
layout: post
title:  Build a Python Package with Conda
date:   2020-04-27 00:00:00 -0000
tags: conda, build, python, package, test, release
---

Building and releasing packages is a critical process 
that allows developers to seamlessly share versions of their code with other developers.

While developers can facilitate this process in many ways, my favorite approach is outlined in the following post.


#### Prequisites
- Install [mini-conda]
- Get familiar with makefiles


![asset]


### Create Env

First, create a virtual environment, 
which installs the dependencies of the build tools, and those of the code to be packaged.

{% highlight bash %}
$ git clone https://github.com/pyt3r/template-package.git
$ cd template-package
$ make test-env
$ activate test-env
{% endhighlight %}

The command line should appear as follows:

{% highlight bash %}
(test-env) $
{% endhighlight %}

### Build
Placeholder

### Test
Placeholder

### Release
Placeholder


[mini-conda]: https://docs.conda.io/en/latest/miniconda.html
[asset]: ../assets/2020-04-27-build-a-python-package.png
