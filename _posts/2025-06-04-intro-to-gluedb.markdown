---
layout: post
title:  Intro to GlueDb
date:   2025-06-04 12:00:00 -0000
tags:   workflow, analytics
---

## Table of Contents
1. [Accessing Data Artifacts](#accessing-data-artifacts)
2. [Managing Data Artifacts](#managing-data-artifacts)
3. [Use Cases](#use-cases)
4. [Final Thoughts](#final-thoughts)

## Intro

GlueDb is a database interface for accessing and managing heterogeneous collections of data artifacts, whether they’re built-in Python types, custom classes, or serialized objects.

I originally developed GlueDb to support my own analytics workflows, where keeping track of files, models, and configuration data quickly became unmanageable. But its utility extends far beyond analytics, offering a flexible system for any project that requires structured access to diverse data.


## Accessing Data Artifacts

Let’s walk through an example using a GlueDb instance:

```python
from pyswark.gluedb import api

db = api.connect( 'pyswark:/data/sma-example.gluedb' )

```

> **Note:**  
> In the URI above, the **pyswark:/** protocol is an alias to the [pyswark-lib/pyswark][pyswark-lib-pyswark] path  
> When unpacked, the full URI points to [pyswark-lib/pyswark/data/sma-example.gluedb][sma-example-gluedb]


### Access By Name

You can retrieve records by name, and GlueDb ensures all names are unique within an instance.

With the instance loaded, we can view the names tagged to each record.  

Gluedb ensures that names in each instance are unique.

```python
print( db.getNames() )
# ['JPM', 'BAC', 'kwargs']
```

We can get a record based on its name and view its body:

```python
record = db.get( 'JPM' )
print( record.body )
```

Which outputs:

```json
{
  "model": "pyswark.gluedb.db.Contents",
  "contents": {
    "uri": "pyswark:/data/ohlc-jpm.csv.gz",
    "datahandler": "",
    "kw": {},
    "datahandlerWrite": "",
    "kwWrite": {}
  }
}
```

We can then acquire the record’s contents:

```python
record   = db.get( 'JPM' )
contents = record.acquire()
print( type( contents ))
# <class 'pyswark.gluedb.db.Contents'>
```

And extract the final data artifact:

```python
JPM = contents.extract()
print( JPM.head(2) )
```

Which outputs:
```mathematica
             Open   High    Low  Close   Volume  Ex-Dividend  Split Ratio 
Date                                                                        
1983-12-30  44.00  44.50  43.50   44.0  47000.0          0.0          1.0   
1984-01-03  43.94  44.25  43.62   44.0  85667.0          0.0          1.0   
```

You can also extract in one call:

```python
JPM = db.extract( "JPM" ) # via string

Enum = db.enum
JPM  = db.extract( Enum.JPM.value ) # via enum
```

### Access by Query

You can also retrieve records using SQLAlchemy expressions:

```python
from sqlalchemy import select
from pyswark.gluedb import table

recordsBefore2025 = db.getByQuery( select( table.Info ).where( 
    table.Info.date_created < '2025-01-01' 
))
recordsAfter2025 = db.getByQuery( select( table.Info ).where( 
    table.Info.date_created > '2025-01-01' 
))

print([ r.info.name for r in recordsBefore2025 ])
# ['JPM', 'BAC']

print([ r.info.name for r in recordsAfter2025 ])
# ['kwargs']
```

## Managing Data Artifacts

GlueDb supports REST-like operations for managing data artifacts:

* `post`
* `put`
* `delete`

Here's how I used these operations to create the `sma-example` database:

```python
from pyswark.gluedb import api
from pyswark.core.models import collection, primitive

db = api.newDb()
db.post( 'JPM', 'pyswark:/data/ohlc-jpm.csv.gz' )
db.post( 'BAC', 'pyswark:/data/ohlc-bac.csv.gz' )
db.post( 'window', primitive.Int("60.0") )
db.post( 'kwargs', collection.Dict({ "window": 60 }))
db.delete( 'window' )
```

Once finalized, I exported the database as follows:

```python
from pyswark.core.io.api import write

write( db, 'file:./sma-example.gluedb' )
```


## Use Cases

GlueDb was originally built to support analytics workflows by acting as a lightweight configuration layer for data artifacts. Here's a simple example:

```python
from pyswark.gluedb import api

db = api.connect( 'pyswark:/data/sma-example.gluedb' )

# extract the data
Enum   = db.enum
JPM    = db.extract( Enum.JPM.value )
BAC    = db.extract( Enum.BAC.value )
kwargs = db.extract( Enum.kwargs.value )

# Calculate the simple moving average (SMA)
JPM_SMA = JPM.rolling( **kwargs ).mean()
BAC_SMA = BAC.rolling( **kwargs ).mean()
```

![sma-plot]

This pattern keeps your code clean, decoupled, and easily configurable. Swapping in new data or parameters doesn’t require digging through logic.  It’s just a matter of updating the GlueDb instance.

### Additional Use Cases

GlueDb’s flexibility makes it a good fit for a range of domains beyond analytics:

* **Data Migrations**

  Consolidate local files and objects into portable formats or move them seamlessly to cloud storage.

* **Machine Learning**

  Keep track of datasets, model versions, and parameters across training runs and experiments.

* **Reproducible Research**

  Version and reference datasets consistently to support transparency and replicability in published work.

## Final Thoughts

GlueDb is ideal for developers, ML practitioners, and data wranglers who want a minimal but powerful system for storing, querying, and managing structured data artifacts.

Thanks for reading.


[pyswark-lib-pyswark]: https://github.com/pyt3r/pyswark-package/blob/master/pyswark
[sma-example-gluedb]: https://github.com/pyt3r/pyswark-package/blob/master/pyswark/data/sma-example.gluedb
[sma-plot]: ../assets/2025-06-04-sma-plot.png