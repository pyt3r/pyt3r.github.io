---
layout: post
title:  A Simple Trick to Deserialize Any Pydantic Model
date:   2024-08-15 12:00:00 -0000
tags: pydantic, python, serializaton
---

# Table of Contents
1. [Problem](#problem)
2. [Without The Trick](#without-any-tricks)
3. [With The Trick](#with-the-trick)
4. [One Last Example](#one-last-example)


### Problem

Pydantic provides serialization methods to export any model object. 
But what if a user needs to import, or deserialize, any model object 
from its serialized form?

While this might seem challenging, there's a simple trick to make it possible.

### Without the Trick

First, let's see how deserialization might work using native pydantic:

( *excerpted from [practice/examples/pydantic/ser_des.py][example-code]* )

![snippet-native-code]

The four-step process of serializing and deserialzing **mulder** can be 
generalized as follows:

![snippet-native-chart]

Seems fine, *right*?  No need to add any tricks...

Well, not exactly.
Upon closer inspection, Step 4 proves to be inconvenient and problematic.

For example, if a user encounters a serialized version of mulder in a database, 
how would they know how to instantiate the serialized data?

In other words, only someone with prior knowledge of the serialized data 
would know to import the **Character** model class and instantiate **mulder**.


### With The Trick

Let's revisit the previous example with a small adjustment. 

This time, before serialization, we'll embed a line of metadata into the data,
as follows:

![snippet-enhanced-code-1]

By including **pmodel** metadata about the serialized object, 
the (de)serialization process can be simplified into just two steps. 

Additionally, the user no longer needs to know the specific model class 
associated with the serialized data.

![snippet-enhanced-chart]


### One Last Example

To demonstrate that this simple trick of ours truly works for **any** model,
let's examine one more example:

![snippet-enhanced-code-2]


What's especially elegant here is that we only need to include the top-level 
**pymodel**—in this case, **TvShow**—and native pydantic takes care of the **Character** 
models for us...

And there you have it! 
A simple trick to streamline your pydantic (de)serialization process.

Thanks for following along.

- Peter
  
[example-code]: https://github.com/pyt3r/practice-package/blob/master/practice/examples/pydantic/ser_des.py
[snippet-native-code]: ../assets/2024-08-15-native-code.png
[snippet-native-chart]: ../assets/2024-08-15-native-chart.png
[snippet-enhanced-code-1]: ../assets/2024-08-15-enhanced-code-1.png
[snippet-enhanced-chart]: ../assets/2024-08-15-enhanced-chart.png
[snippet-enhanced-code-2]: ../assets/2024-08-15-enhanced-code-2.png