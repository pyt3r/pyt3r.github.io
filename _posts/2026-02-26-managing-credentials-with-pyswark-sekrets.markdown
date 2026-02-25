---
layout: post
title:  Managing Credentials with pyswark Sekrets
date:   2026-02-26 12:00:00 -0000
tags:   pyswark, sekrets, gluedb
---

**Sekrets** are an application of [GlueDb](https://pyt3r.github.io/intro-to-gluedb/): they use the same idea of named records and URIs to help manage credentials and other sensitive config in one place. This post walks through creating a small **generic** sekret database, persisting it to a file using the **GITHUB_IO_DEMO** preset, and then adding another sekret via the secrets hub so that both are stored in the same file.

## Why use sekrets?

Applications often need credentials, API keys, or config that you don’t want in source code. Sekrets in pyswark give you a single, consistent way to store and read that data:

- **One API** : `api.get(protocol, name)` returns the right credentials for a service and identity, without hardcoding paths or env vars in every script.
- **Organized by protocol** : Each “protocol” (i.e. `github-io-demo`, `gdrive2`) is its own GlueDb. You can keep dev and prod stores separate, or point different protocols at different backings (local file, remote, etc.).
- **Typed and validated** : Sekret models (generic, gdrive2, etc.) are Pydantic models, so you get validation and structure instead of raw dicts.
- **Hub + persistence** : The central hub can resolve protocol aliases (i.e. from `Settings`) and, with `postToDb` / `mergeToDb`, write changes back to the underlying file or URI so updates persist without manual save logic.

If you’re already using pyswark’s GlueDb for catalogs, sekrets reuse the same ideas (named records, URIs, extraction) so credentials live in one ecosystem instead of ad‑hoc config files or env soup.

## Prerequisites

- [pyswark](https://github.com/pyt3r/pyswark) installed
- The sekrets hub configured to include the GITHUB_IO_DEMO entry (i.e. in `sekrets.hubdata`, post `Settings.GITHUB_IO_DEMO.uri` under a name the hub can resolve)

In `settings.py` you might have:

```python
# pyswark.sekrets.settings
class Settings( Base ):
    # ...
    GITHUB_IO_DEMO = './github-io-demo.gluedb', Alias( 'github-io-demo' )
```

The alias `github-io-demo` is what you use in the API when reading or writing to this database.

---

## 1. Create a new sekret database and persist it

Create an empty sekrets Db, get the **generic** sekret model, build one sekret, post it, and write the database to a file. For the demo we use a file URI in the current directory; you can switch this to `Settings.GITHUB_IO_DEMO.uri` if your preset is set up to point at that path.

```python
from pyswark.core.io import api as io
from pyswark.sekrets import api
from pyswark.sekrets.settings import Settings

# Preset URI for the demo 
DEMO_URI = Settings.GITHUB_IO_DEMO.uri # './github-io-demo.gluedb'

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

## 2. Retrieve the sekret via the API

Once the hub has an entry for this database (resolvable by the alias `github-io-demo`), you can fetch the sekret with `api.get(protocol, name)`:

```python
# Retrieve by protocol (alias) and record name
creds = api.get('github-io-demo', 'my-name')
print(creds)  # i.e. {'sekret': 'my-sekret', 'description': 'my-description'}
```

---

## 3. Add another sekret and persist via the hub

Use the central hub to post a second sekret into the same database. The hub resolves the protocol alias and writes the updated GlueDb back to its URI.

```python
# Create a second sekret
new_sekret = Sekret(sekret='my-new-sekret', description='my-new-description')

# Post it into the GITHUB_IO_DEMO db and persist (hub resolves 'github-io-demo')
hub = api.getHub()
hub.postToDb(new_sekret, 'github-io-demo', name='my-new-username')

# Fetch it back
print(api.get('github-io-demo', 'my-new-username'))
```

---

## 4. Confirm both records are in the file

Read the GlueDb file and list record names to confirm both entries are persisted:

```python
db = io.read(DEMO_URI)
print(db.getNames())  # ['my-name', 'my-new-username']
```

---

## Summary

In this post we walked through the full cycle: create a sekret database and persist it to a file, retrieve credentials with `api.get(protocol, name)`, persist another sekret via `hub.postToDb(...)`, and confirm both records with `db.getNames()`. While the **GITHUB_IO_DEMO** preset keeps the demo in one file; the same pattern can scale to many protocol-specific stores managed by a single hub.

## Final thoughts

If you already use GlueDb for data catalogs, sekrets are a natural next step for credentials: same ideas (named records, URIs, extraction), one API. Start with a small store like `github-io-demo`, then add more protocols or environments as you need them. The goal is simple—credentials stay typed, centralized, easy to access via `api.get`, and out of source code.
