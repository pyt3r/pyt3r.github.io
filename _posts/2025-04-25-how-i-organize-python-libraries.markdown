---
layout: post
title:  How I Organize Python Libraries
date:   2025-04-25 12:00:00 -0000
tags: python, library, lib, core, util
---

When building Python libraries, structure matters just as much as syntax. A clean, consistent layout helps make one's codebase understandable not just for others, but for one's future self as well.

Over the years, I’ve gravitated towards a few guidelines when organizing my own libraries...

## Table of Contents
1. [What goes in a Python Library?](#what-goes-in-a-python-library)
2. [What goes in the /lib package?](#what-goes-in-the-lib-package)
3. [What goes in the /core package?](#what-goes-in-the-core-package)
4. [What goes in the /util package?](#what-goes-in-the-util-package)
5. [What goes in the other packages?](#what-goes-in-the-other-packages)
6. [Final Thoughts](#final-thoughts)

---

## What goes in a Python Library?

Before diving in, let’s quickly define a few terms the Python community often throws around:

- A **module** is a single `.py` file that contains Python code.
- A **package** is a directory containing an `__init__.py` file and one or more modules or sub-packages.
- A **library** is a **collection of packages and modules** that provide a wide range of tools.

The `tree` of a Python `library` could be exemplified as follows: 

```bash
library/
├── __init__.py
├── package_0
│    ├── __init__.py
│    ├── module_0.py
│    ├── module_n.py
│    ├── sub_package_0
│    │    ├── __init__.py
│    │    ├── module_0.py
│    │    └── module_n.py
│    └── sub_package_n
│        └── __init__.py
└── package_n
     └── __init__.py
```

With that context, here’s how I like to break things down when building a Python library.


---

## What goes in the /lib package?

The `/lib` package is where I place **customizations and extensions to third-party libraries**. It’s essentially my override zone. Anything in `/lib` is tightly coupled to an external dependency.

* In my [`pyswark-lib`][pyswark-github], for example, I extend the `Pydantic BaseModel` with extra features I use consistently across the `pyswark`.

    ```python
    from pyswark.lib.pydantic.base import BaseModel
    ```
* Likewise, AliasEnum is my custom flavor of Python enums with support for aliases.

    ```python
    from pyswark.lib.enum import AliasEnum
    ```
  
* If another developer were to extend `pyswark`, they might create their own `/lib/pyswark` directory to patch or override the internals.

* **Guideline**: modules in `/lib` can be imported from anywhere in the library.

---

## What goes in the /core package?
This is the heart of the library, containing modules that form its foundational internal frameworks. These aren’t just utility functions.  They’re the building blocks that define how the library operates and approaches problems.

* In `pyswark`, for example, I've added a flexible I/O system used across the library. It’s abstracted enough to support local files, URLs, or custom URIs.

    ```python
    from pyswark.core.io import api
    
    data = api.read( "pyswark://data/df.csv" )
    ```


* **Guideline**: modules in `/core` should not be imported by anything in `/lib` or `/util`.

---

## What goes in the /util package?
The `/util` package is where I stash all those low-level helpers that don’t fit anywhere else. They’re generic, lightweight, and not tied to any specific functionality or domain model.

* Common contents include:
    
    * Custom loggers
    
    * Timing/performance decorators
    
    * Memoization helpers

* Some might argue that the previously mentioned `pyswark` I/O system belongs in `/util`, but I placed them in `/core` because they act as a framework—not just a set of helpers. It’s a judgment call, but that’s my reasoning.

* **Guideline**: modules in `/util` should not be imported by anything in `/lib` or `/core`


---

## What goes in the *other packages*?
Outside of `/lib`, `/core`, and `/util`, all other packages should reflect features or domains specific to the library.

* These contain the sub-packages and modules that users will interact with most directly.

* The *other packages* can be imported by eachother, so long as circular dependencies are avoided. 
  
* A clean separation of concerns here goes a long way toward making the project scalable and testable.

---

## Final Thoughts

Every library has its own needs, and no one structure fits all.

But a few conscious architectural choices -- like separating patches, core logic, and utility helpers -- help to avoid headaches down the road. 

If you're building your own library, I hope this post offers a solid starting point.


[pyswark-github]: https://github.com/pyt3r/pyswark-lib