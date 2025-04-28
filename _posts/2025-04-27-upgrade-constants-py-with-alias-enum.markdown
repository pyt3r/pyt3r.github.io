---
layout: post
title:  Upgrade constants.py with AliasEnum
date:   2025-04-27 12:00:00 -0000
tags:   enum
---

## Table of Contents
1. [The Implementation](#the-implementation)
2. [Handling Duplicates](#handling-duplicates)
3. [Final Thoughts](#final-thoughts)


Recently, I realized I needed a better way to manage and interact with constants in Python. I often encountered situations where I needed to look up a value, but the item in question had multiple aliases.

While dictionaries can store aliases as key-value pairs, they don’t expose their keys as class attributes, a feature I appreciate when working with enums.
However, while enums were closer to what I needed, they still didn’t fully solve the problem.

So, I decided to patch Python’s `Enum` class to handle these cases more elegantly.

---

## The Implementation

Using an extended `Enum` class called [`AliasEnum`][pyswark-enum-github], I can define constants with multiple aliases and look them up flexibly.

Here's an example:

```python
from pyswark.lib.enum import AliasEnum

class Guitarists( AliasEnum ):

    # Bands that start with 'the':
    THE_ALLMAN_BROTHERS_BAND = 'Duane Allman', [ 'The Allman Brothers' ]
    THE_GRATEFUL_DEAD        = 'Jerry Garcia', [ 'The Dead', 'The Grateful Dead' ]

    # Bands with special characters
    AC_DC        = 'Angus Young', [ 'AC/DC' ]
    GUNS_N_ROSES = 'Slash', [ "Guns N' Roses" ]
```

The `AliasEnum` retains the basic `Enum` behavior:

```python
guitarist = Guitarists.THE_GRATEFUL_DEAD
print( guitarist.value )  # 'Jerry Garcia'
```

But where `AliasEnum` shines is with the extended `.get()` method.

```python
guitarists = [
    Guitarists.get( Guitarists.THE_GRATEFUL_DEAD ), # via enum member
    Guitarists.get( 'THE_GRATEFUL_DEAD' ),          # via enum name
    Guitarists.get( 'The Dead' ),                   # via alias #0
    Guitarists.get( 'The Grateful Dead' ),          # via alias #1
]

for guitarist in guitarists:
    print( guitarist.value )  # Always prints 'Jerry Garcia'
```

You can retrieve the enum member:

- by the Enum name
- by one of its aliases
- or by the enum itself

This makes handling flexible identifiers effortless.

---

## Handling Duplicates

Another nice feature of `AliasEnum` is how it handles duplicate entries and duplicate aliases:

```python
class Guitarists( AliasEnum ):
    THE_GRATEFUL_DEAD = 'Jerry Garcia', [ 'The Dead', 'The Grateful Dead' ]
    DEAD_AND_COMPANY  = 'John Mayer',   [ 'The Dead', 'Dead & Co.' ]

# Raises ValueError: duplicate alias for {'THE_GRATEFUL_DEAD': {'The Dead'}}
```

This ensures that alias collisions are caught early rather than causing subtle bugs later.

---

## Final Thoughts

If you often find yourself stuck between messy dictionaries and rigid enums, give something like `AliasEnum` a try. 
It's made the constants in my codebases cleaner and more maintainable.

---



[pyswark-enum-github]: https://github.com/pyt3r/pyswark-lib/blob/master/pyswark/lib/enum.py