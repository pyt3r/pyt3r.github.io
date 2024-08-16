---
layout: post
title:  A Simple Trick to (De)serialize Any Pydantic Model
date:   2024-08-15 12:00:00 -0000
tags: pydantic, python, serializaton, typing
---

# Table of Contents
1. [Without The Trick](#without-any-tricks)
2. [With The Trick](#with-the-trick)
3. [One More Example](#one-more-example)



`Pydantic` provides serialization methods to export its model objects.

But what if a developer needs to import, or deserialize, the serialized form of a model object?

### Without the Trick

First, let’s see how a developer might do so using native `pydantic`:

( *excerpted from [practice/examples/pydantic/ser_des.py][example-code]* )

![snippet-native-code]

The process of serializing and deserializing `mulder` can be generalized into the following four steps.

Seems fine, *right*?

![snippet-native-chart]

Well, not exactly.

Upon closer inspection, **Step 4** proves to be inconvenient and problematic.

For instance, if a developer blindly encounters a serialized form of `mulder`, how would they know how to instantiate it?

In other words, only a developer with prior knowledge of the serialized data would understand that they need to import 
the `Character` class in order to instantiate the `mulder` object.


### With The Trick

Let’s revisit the previous example with a small adjustment.

This time, before serialization, we’ll embed a line of metadata into the json dump, as follows:

![snippet-enhanced-code-1]

By embedding the `pmodel` metadata, the developer no longer needs to be aware of the model class associated with the serialized data.

In turn, the trick — implemented under [practice/lib/pydantic/ser_des.py][example-code] — 
is to manage this association by dynamically importing the `pmodel` class and passing its serialized data as kwargs during deserialization.

The resulting (de)serialization process reduces from four steps to just two:


![snippet-enhanced-chart]


### One More Example

To demonstrate that the trick truly works for any model, let’s look at one more example:

![snippet-enhanced-code-2]

In this example, what’s especially elegant is that the developer only needs to include the top-level `pmodel`— in this case, 
`TvShow` — and `pydantic` natively takes care of the lower-level models, `mulder` and `scully`…

And there you have it! A simple trick to streamline your `pydantic` (de)serialization process.

Thanks for following along.

- Pete
  
[example-code]: https://github.com/pyt3r/practice-package/blob/master/practice/examples/pydantic/ser_des.py
[impl-code]: https://github.com/pyt3r/practice-package/blob/master/practice/lib/pydantic/ser_des.py
[snippet-native-code]: ../assets/2024-08-15-native-code.png
[snippet-native-chart]: ../assets/2024-08-15-native-chart.png
[snippet-enhanced-code-1]: ../assets/2024-08-15-enhanced-code-1.png
[snippet-enhanced-chart]: ../assets/2024-08-15-enhanced-chart.png
[snippet-enhanced-code-2]: ../assets/2024-08-15-enhanced-code-2.png