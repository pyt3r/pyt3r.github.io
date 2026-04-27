---
layout: post
title:  Managing Credentials with pyswark Sekrets
date:   2026-02-25 12:00:00 -0000
tags:   pyswark, sekrets, gluedb
---

**Sekrets** are an application of [GlueDb]({% post_url 2025-06-04-intro-to-gluedb %}): they use the same idea of named records and URIs to help manage credentials and other sensitive config in one place. This post walks through creating a small **generic** sekret database, persisting it to a file, adding a second record, and reading both back — using only the core `Db` + `io` API, no preset required.

## Why use sekrets?

Applications often need credentials, API keys, or config that you don’t want in source code. Sekrets in pyswark give you a single, consistent way to store and read that data:

- **One API** : a sekret database is just a typed GlueDb. You read and write it through `pyswark.core.io.api`, the same way you’d read or write any other URI.
- **Organized by protocol** : Each protocol (i.e. `gdrive2`) lives in its own GlueDb file. You can keep dev and prod stores separate, or point different protocols at different backings (local file, remote, etc.).
- **Typed and validated** : Sekret models (generic, gdrive2, etc.) are Pydantic models, so you get validation and structure instead of raw dicts.
- **Hub + persistence** : For real protocols, a central hub can resolve protocol aliases (i.e. from `Settings`) so callers reach for credentials by name instead of file path. We’ll point at this at the end.

If you’re already using pyswark’s GlueDb for catalogs, sekrets reuse the same ideas (named records, URIs, extraction) so credentials live in one ecosystem instead of ad‑hoc config files or env soup.

## Prerequisites

- [pyswark](https://github.com/pyt3r/pyswark) installed

That’s it. We’ll write to a local file URI in the current directory; nothing in `Settings` or in the hub needs to know about it.

---

## 1. Create a new sekret database and persist it

Create an empty sekrets `Db`, get the **generic** sekret model, build one sekret, post it, and write the database to a file.

```python
from pyswark.core.io import api as io
from pyswark.sekrets import api

DEMO_URI = 'file:./demo-sekrets.gluedb'

# Create an empty sekret database
db = api.Db()

# Get the generic sekret model and create an instance
Sekret = api.sekret('generic')
sekret = Sekret(sekret='my-sekret', description='my-description')

# Add the sekret to the db and persist to file
db.post(sekret, name='my-name')
io.write(db, DEMO_URI, overwrite=True)
```

---

## 2. Retrieve the sekret

Read the database back and pull the record by name:

```python
db    = io.read(DEMO_URI)
creds = db.get('my-name')
print(creds)  # i.e. {'sekret': 'my-sekret', 'description': 'my-description'}
```

Because the database is a plain GlueDb, anything you’d normally do with one (extract, list names, merge) works here too.

---

## 3. Add another sekret and re-persist

Post a second sekret into the same database and write it back to the same URI. `overwrite=True` lets `io.write` replace the existing file in place.

```python
new_sekret = Sekret(sekret='my-new-sekret', description='my-new-description')

db.post(new_sekret, name='my-new-username')
io.write(db, DEMO_URI, overwrite=True)
```

---

## 4. Confirm both records are in the file

Re-read the file and list record names to confirm both entries are persisted:

```python
db = io.read(DEMO_URI)
print(db.getNames())  # ['my-name', 'my-new-username']
```

---

## Graduating to the hub

For ad‑hoc demos like this one, a literal URI string is the simplest path. For real, recurring protocols you’ll typically:

1. Add a member to `pyswark.sekrets.settings.Settings` pointing at the protocol’s gluedb file (this is what `Settings.GDRIVE2` does today).
2. Register it in `pyswark.sekrets.hubdata.DBs` so it lands in the central `HUB`.
3. Then call `api.get(protocol, name)` — the sekrets-aware hub resolves the alias for you and returns a typed credential model (e.g. a `gdrive2.Sekret`).

That layering keeps the demo flow above unchanged while making real protocols a one-line lookup from anywhere in your code.

## Summary

In this post we walked through the full cycle without any global config: create a sekret database, persist it to a file with `io.write`, retrieve credentials with `db.get(name)`, add a second sekret and re-persist, and confirm both records with `db.getNames()`. The same pattern scales to many protocol-specific stores; once a protocol is real enough to deserve a name, you promote it from a literal URI to a `Settings` entry and let the hub do the resolution.

## Final thoughts

If you already use GlueDb for data catalogs, sekrets are a natural next step for credentials: same ideas (named records, URIs, extraction), one API. Start with a small file like `./demo-sekrets.gluedb`, then graduate the protocols you actually use into `Settings` + the hub. The goal is simple — credentials stay typed, centralized, easy to access via `db.get` (or `api.get` once they’re registered), and out of source code.
