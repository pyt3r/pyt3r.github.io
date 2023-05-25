---
layout: post
title:  A Data-Driven Workflow Framework in Python
date:   2023-04-05 12:00:00 -0000
tags: workflow, framework, python, data driven, data analytics, code as data
---

# Table of Contents
1. [Introduction](#motivation)
2. [Analysis #1: Raw Visualization](#analysis-1-raw-visualization)
3. [Analysis #2: Isolating the Test Period](#analysis-2-isolating-the-test-period)
4. [Analysis #3: Finalizing the Strategy](#analysis-3-finalizing-the-strategy)
5. [Features](#features)
6. [Conclusion](#conclusion)

### Introduction

Data analysts and developers often find themselves writing code that can be represented as a sequence of functions, 
or *workflow* of *tasks*.
Whether it be a data processing pipeline, or an ordered set of logic, the workflow progresses from one task to the next, 
registering and consuming intermediate results along the way.
In the analytics space, such workflows are difficult to maintain due to the frequency with which code and data changes.

Consider the case of a data analyst that processes and visualizes historical price data in order to devise a trading strategy.
The analyst attempts different data cleansing and statistical techniques before finalizing the strategy.
As the attempts grow, each version of code, and its respective result, becomes increasingly challenging to manage.

To remediate this challenge, the following post introduces a [framework-based solution][workflow-code] that streamlines the development,
tracking, and reproduction of any given analytical workflow.


### Analysis #1: Raw Visualization

Taking the previous example of devising a trading strategy, the analyst would begin by acquiring historical price 
data for experimentation. For example, the analyst could use the Quandl API to acquire the historical stock prices of JPMorgan:

![snippet-0]

Next, the analyst might devise a simple workflow to visualize the acquired data.
By utilizing the suggested framework, the workflow could be implemented as follows:

![snippet-1a]

From inspecting the snippet, the framework becomes embedded with the *Analysis1* class through inheritance.
By inheriting the *api.Workflow* class, the child class can declare a sequence of *TASKS*, which
become validated and viewable upon instantiation:

![snippet-1b]

The resulting view would appear in the following tabular form:

![dataframe-1]

With the *Analysis1* workflow object instantiated, 
the analyst can proceed to run its *TASKS* by invoking the following code:

![snippet-1c]

For each row (or *TASK*), in the workflow,

* The function specified by the **funcPath** column consumes the args and kwargs 
  specified by the **inputKeys** and **kwargs** columns, respectively. 

* The corresponding result of the function is, then, registered using the key 
  specified in the **outputKeys** column.
  
* The framework treats *TASKS* of the same **order** with equal priority in the execution order.

Once the calculation of the last row completes, then all **outputKeys** become accessible.
For example, accessing the *fig* **outputKey** from the registered results would yield the following figure:


![plot-1]


### Analysis #2: Isolating the Test Period
The analyst might then decide to examine the economic downturn period more closely 
and work towards a strategy that minimizes downside risk.  

Accordingly, they might adjust their prior workflow to isolate the downturn period
by adding start and end masks:

![snippet-2]

Accessing the *fig* **outputKey** for this adjusted workflow would yield the following figure:

![plot-2]


### Analysis #3: Finalizing the Strategy

Through visually inspecting the sharp price fluctuations during the downturn period, 
the analyst thinks that a simple strategy using a long and short simple moving average (SMA) 
might perform well. 

As a result, the analyst tests this theory and codes the following strategy:

![snippet-3]

This particular strategy involves 
buying when the short SMA crosses over the long SMA in the positive direction, and 
selling when the long SMA crosses over the short SMA in the negative direction, 
as depicted by the following **crossover** indicator:

![plot-3]

## Features

#### Feature #1. Serialization

Users can leverage the framework to transfer their workflow to a recipient, such as a colleague or manager:
 
![snippet-features-1a]

On the receiving end, the receipt can seamlessly ingest and execute the workflow:

![snippet-features-1b]

The serialization feature also allows workflows to be saved and managed as data in a database or filesystem,
eliminating the need to treat them as source code in a version control system.

#### Feature #2. Graphical Representation

Before running a workflow, users can represent the workflow as a Directed Acyclic Graph (DAG),
which helps to trace dependencies and track the progression of results: 

![snippet-features-2]


#### Feature #3. Debug-ability

Users can step through each task in the workflow and inspect the intermediate results: 

![snippet-features-3]


## Conclusion

The proposed framework offers a solution for managing workflows that are prone to frequent code and data changes. 
By adopting the framework, users can easily organize their code, reproduce the results of any prior change, 
and ultimately, boost their overall productivity.



[mini-conda]: https://docs.conda.io/en/latest/miniconda.html
[workflow-code]: https://github.com/pyt3r/practice-package/blob/master/practice/frameworks/workflow/workflow.py
[snippet-0]: ../assets/2023-04-05-snippet-0.png
[snippet-1a]: ../assets/2023-04-05-snippet-1a.png
[snippet-1b]: ../assets/2023-04-05-snippet-1b.png
[snippet-1c]: ../assets/2023-04-05-snippet-1c.png
[snippet-2]: ../assets/2023-04-05-snippet-2.png
[snippet-3]: ../assets/2023-04-05-snippet-3.png
[snippet-features-1a]: ../assets/2023-04-05-snippet-features-1a.png
[snippet-features-1b]: ../assets/2023-04-05-snippet-features-1b.png
[snippet-features-2]: ../assets/2023-04-05-snippet-features-2.png
[snippet-features-3]: ../assets/2023-04-05-snippet-features-3.png
[dataframe-1]: ../assets/2023-04-05-dataframe-1.png
[plot-1]: ../assets/2023-04-05-plot-1.png
[plot-2]: ../assets/2023-04-05-plot-2.png
[plot-3]: ../assets/2023-04-05-plot-3.png
