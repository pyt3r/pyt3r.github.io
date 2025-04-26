---
layout: post
title:  How I Organize Python Libraries
date:   2025-04-25 12:00:00 -0000
tags: python, library, lib, core, util
---

When building Python libraries, structure matters just as much as syntax. A clean, consistent layout helps make your codebase understandable not just for others, but for your future self.

Over the years, I’ve developed a pattern I like to follow when organizing my own libraries.

Let’s walk through it.

## Table of Contents
1. [What Even Is a Python Library?](#what-even-is-a-python-library)
2. [/lib](#lib)
3. [/core](#core)
4. [/util](#util)
5. [The Other Packages](#the-other-packages)
6. [tl;dr](#tldr)

---

## What Even Is a Python Library?

Before diving in, let’s quickly define a few terms the Python community often throws around:

- A **module** is a single `.py` file that contains Python code.
- A **package** is a directory containing an `__init__.py` file and one or more modules or sub-packages.
- A **library** is a broader term—usually referring to a **collection of packages and modules** designed for reuse.

With that context, here’s how I like to break things down when building a Python library.

---

## /lib

The `/lib` package is where I place **customizations and extensions to third-party libraries**. It’s essentially my override zone. Anything in `/lib` is tightly coupled to an external dependency.

### Example from `pyswark`

```python
from pyswark.lib.pydantic.base import BaseModel
from pyswark.lib.enum import AliasEnum
```

In `pyswark`, I extend Pydantic’s BaseModel with extra features I use consistently across projects. Likewise, AliasEnum is my custom flavor of Python enums with support for aliases.

If another developer were to extend `pyswark`, they might create their own `/lib/pyswark` directory to patch or override our internals.

**Guideline: Modules in** `/lib` **can be imported from anywhere in the project.**

---

## /core
This is the heart of the library—the modules that represent its core ideas and internal frameworks. These aren’t just utility functions; they define how the library works and think about problems.

Example from `pyswark`

```python
from pyswark.core.io import api

data = api.read("pyswark://data/df.csv")
```

In this case, `api.read()` is part of a flexible I/O system I use across the library. It’s abstracted enough to support local files, URLs, or custom URIs.

**Guideline: Modules in** `/core` **are used throughout the codebase, but should not be imported by anything in** `/lib' **or** `/util`

---

## /util
The `/util` package is where I stash all those low-level helpers that don’t fit anywhere else. They’re generic, lightweight, and not tied to any specific functionality or domain model.

Common contents include:

* Custom loggers

* Timing/performance decorators

* Chunking, retry, or memoization helpers

**Guideline: Modules in** `/util` **can be used by any part of the library except** `/core` **and** `/lib' **to avoid circular dependency traps.**


Some might argue that file readers/writers previously mentioned belong in `/util`, but I placed them in `/core` because they act as a framework—not just a set of helpers. It’s a judgment call, but that’s my reasoning.

---

## The Other Packages
Outside of `/lib`, `/core`, and `/util`, all other packages should reflect features or domains specific to your library. These are the modules users will interact with most directly.

I try to keep these packages decoupled, focusing on avoiding circular dependencies. A clean separation of concerns here goes a long way toward making the project scalable and testable.

---

## Final Thoughts

Every library has its own needs, and no one structure fits all. But by making a few conscious architectural choices—like separating patches, core logic, and utility helpers; you can avoid headaches down the road. This structure has worked well for me in building reusable, maintainable Python tools like `pyswark`.

If you're building your own library, I hope this gives you a solid jumping-off point.


