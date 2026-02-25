---
layout: post
title:  Setting Up fsspec for Google Drive with a Service Account
date:   2026-02-18 12:00:00 -0000
tags:   infrastructure, google-drive
---

## Table of Contents
1. [Why a Service Account?](#why-a-service-account)
2. [Set Up a Google Cloud Project](#set-up-a-google-cloud-project)
3. [Create a Service Account](#create-a-service-account)
4. [Create a JSON Key](#create-a-json-key)
5. [Share Your Drive Folder](#share-your-drive-folder)
6. [Install Dependencies](#install-dependencies)
7. [Connect with fsspec](#connect-with-fsspec)
   - [Passing credentials as a dict or string](#passing-credentials-as-a-dict-or-string)
8. [Read and Write Files](#read-and-write-files)
9. [Using as an fsspec Backend](#using-as-an-fsspec-backend)
10. [Final Thoughts](#final-thoughts)

## Why a Service Account?

The standard OAuth2 flow for Google Drive requires a browser-based login, caches refresh tokens that can expire, and breaks on headless machines. A service account eliminates all of that:

- **No browser required** : authentication uses a static JSON key
- **No token expiry** : service account keys don't expire (unless you rotate them)
- **No credential cache** : no stale tokens under `~/.cache/pydrive2fs/`
- **CI/CD friendly** : works in pipelines, containers, and remote servers


## Set Up a Google Cloud Project

Before creating a service account, you need a Google Cloud project with the Drive API enabled. Follow the first two steps of the [PyDrive2 Quickstart](https://docs.iterative.ai/PyDrive2/quickstart/):

1. Go to [Google APIs Console](https://console.cloud.google.com/apis) and create a new project (or select an existing one)
2. Search for **Google Drive API**, select the entry, and click **Enable**

These two steps give your project permission to make Drive API calls. Without this, requests will fail with a `403 Drive API has not been used` error.


## Create a Service Account

1. In the same project, go to [IAM & Admin > Service Accounts](https://console.cloud.google.com/iam-admin/serviceaccounts)
2. Click **+ CREATE SERVICE ACCOUNT**
3. Enter a name (i.e. `pydrive2-sa`) and click **CREATE AND CONTINUE**
4. Skip the optional "Grant access" steps and click **DONE**

You'll see the service account listed with an email like:

```
pydrive2-sa@your-project.iam.gserviceaccount.com
```

Take note of this email - you'll need it to share your Drive folder.


## Create a JSON Key

1. Click on the service account you just created
2. Go to the **KEYS** tab
3. Click **ADD KEY** > **Create new key**
4. Select **JSON** and click **CREATE**
5. A `.json` file downloads automatically

Move it to a secure location in your project:

```bash
mv ~/Downloads/your-project-xxxxxx.json ./service-account-key.json
```

> **Warning:** This key grants access to any Drive resources shared with the service account. Keep it out of version control (add it to `.gitignore`).


## Share Your Drive Folder

The service account is a separate Google identity - it can only access files and folders explicitly shared with it.

1. Open [Google Drive](https://drive.google.com) in your browser
2. Right-click the folder you want to access > **Share**
3. Paste the service account email (i.e. `pydrive2-sa@your-project.iam.gserviceaccount.com`)
4. Set the permission level (**Viewer** for read-only, **Editor** for read/write)
5. Click **Send**

To find the folder ID, open the folder in Drive and copy the ID from the URL:

```
https://drive.google.com/drive/folders/<this_is_the_folder_id>
```


## Install Dependencies

```bash
pip install pydrive2[fsspec]
```


## Connect with fsspec

```python
from pydrive2.auth import GoogleAuth
from pydrive2.fs import GDriveFileSystem

def connect(folder_id, key_file):
    """Connect to a Google Drive folder using a service account."""
    settings = {
        "client_config_backend": "service",
        "service_config": {
            "client_json_file_path": key_file,
        },
    }
    gauth = GoogleAuth(settings=settings)
    gauth.ServiceAuth()
    return GDriveFileSystem(folder_id, google_auth=gauth)

key_file  = "./service-account-key.json"
folder_id = "<this_is_the_google_drive_folder_id>"

fs = connect(folder_id, key_file)
```

That's it - no browser popup, no cached tokens.

### Passing credentials as a dict or string

You don't have to use a key file path. PyDrive2 also accepts the key as a **dict** (i.e. from a secrets store or `api.read()`) or as a **JSON string** (i.e. from an environment variable). Useful when you load credentials once and want to avoid passing paths around, or in environments where the key is injected at runtime.

**Option 1: Pass a dict**

Build `GoogleAuth` with `service_config["client_json_dict"]` and pass it into `GDriveFileSystem`:

```python
from pydrive2.auth import GoogleAuth
from pydrive2.fs import GDriveFileSystem

def connect_with_keys(folder_id, keys):
    """
    Connect using service account credentials from a dict.
    keys: from api.read(key_file), a secrets backend, etc.
    Optional: include "path" in keys to use as folder_id.
    """
    keys = dict(keys)
    folder_id = keys.pop("path", folder_id)  # optional custom key
    settings = {
        "client_config_backend": "service",
        "service_config": {
            "client_json_dict": keys,
        },
    }
    gauth = GoogleAuth(settings=settings)
    gauth.ServiceAuth()
    return GDriveFileSystem(folder_id, google_auth=gauth)

# Example: load once, connect without a path
keys = api.read("./service-account-key.json")  # or from env/secrets
folder_id = keys.get("path", "<folder_id>")
fs = connect_with_keys(folder_id, keys)
```

**Option 2: Pass a JSON string**

Use `client_json` when you have the key as a string (i.e. `json.dumps(keys)` or an env var):

```python
import json

# From a dict
client_json_str = json.dumps(keys)
fs = GDriveFileSystem(
    folder_id,
    use_service_account=True,
    client_json=client_json_str,
)

# Or from an environment variable
import os
fs = GDriveFileSystem(
    folder_id,
    use_service_account=True,
    client_json=os.environ["GDRIVE_SERVICE_ACCOUNT_JSON"],
)
```

No key file path is required; credentials are passed in memory.


## Read and Write Files

### List files

```python
for root, dirs, files in fs.walk(folder_id):
    for d in dirs:
        print(f"dir:  {root}/{d}")
    for f in files:
        print(f"file: {root}/{f}")
```

### Read a file

```python
import json

with fs.open(f"{folder_id}/config.json", "r") as f:
    data = json.load(f)
    print(data)
```

### Write a file

```python
with fs.open(f"{folder_id}/output.json", "w") as f:
    json.dump({"status": "ok"}, f)
```

### Use with pandas

```python
import pandas as pd

with fs.open(f"{folder_id}/data.csv", "r") as f:
    df = pd.read_csv(f)
    print(df.head())
```


## Using as an fsspec Backend

PyDrive2's `GDriveFileSystem` is an fsspec-compatible filesystem, but it does **not** auto-register itself with fsspec. To use it through the standard `fsspec.filesystem` and `fsspec.open` APIs, you need to register it first:

```python
import fsspec
from pydrive2.fs import GDriveFileSystem

fsspec.register_implementation("gdrive2", GDriveFileSystem)
```

After registration, you can use the standard fsspec API:

```python
fs = fsspec.filesystem(
    "gdrive2",
    path="<this_is_the_google_drive_folder_id>",
    use_service_account=True,
    client_json_file_path="./service-account-key.json",
)

folder_id = "<this_is_the_google_drive_folder_id>"

# List all entries in the folder
entries = fs.ls(folder_id)
for entry in entries:
    print(entry)
```

Open files using `fsspec.open`:

```python
import json

with fsspec.open(
    f"gdrive2://{folder_id}/config.json",
    "r",
    use_service_account=True,
    client_json_file_path="./service-account-key.json",
) as f:
    data = json.load(f)
    print(data)
```

### Registering a Custom Implementation

You can also subclass `GDriveFileSystem` to inject default credentials or add custom behavior, then register under your own protocol name:

```python
import fsspec
from pydrive2.auth import GoogleAuth
from pydrive2.fs import GDriveFileSystem

class MyDriveFileSystem(GDriveFileSystem):
    """GDrive filesystem that authenticates with a service account by default."""
    protocol = "mydrive"

    def __init__(self, path, key_file="./service-account-key.json", **kwargs):
        settings = {
            "client_config_backend": "service",
            "service_config": {
                "client_json_file_path": key_file,
            },
        }
        gauth = GoogleAuth(settings=settings)
        gauth.ServiceAuth()
        super().__init__(path, google_auth=gauth, **kwargs)

fsspec.register_implementation("mydrive", MyDriveFileSystem)

# Callers only need the folder ID
fs = fsspec.filesystem("mydrive", path=folder_id)
entries = fs.ls(folder_id)
```

This keeps authentication details out of calling code and lets you swap backends by changing the protocol string.


## Final Thoughts

A service account is the simplest way to connect to Google Drive programmatically. There's no browser flow, no token cache, and no expiring refresh tokens. It works the same on your laptop, in a notebook, and in a CI/CD pipeline.

The only requirement is sharing the target folder with the service account email. After that, it's just `connect(folder_id, key_file)`.
