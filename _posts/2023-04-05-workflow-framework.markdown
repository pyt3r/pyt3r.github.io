---
layout: post
title:  A Data-Driven Workflow Framework in Python
date:   2023-04-05 12:00:00 -0000
tags: workflow, data science, analytics, python, software framework, code as data
---

Often, I find myself writing code that can be represented as a linear sequence of functions.  
Whether it be a data processing pipeline, or an ordered set of tasks, 
the sequence progresses from one function to the next, 
registering and consuming intermediate results along the way.  

Such sequences can be difficult to maintain, especially should one wish to apply changes 
and observe the updated results. Consider the case of a data analyst that processes and 
visualizes historical price data in an effort to devise a trading strategy:

* The analyst attempts different data cleansing and statistical techniques before
arriving at a strategy.
* As the number of attempts increases, the workflow becomes 
difficult to organize.
* The analyst soon realizes that they would benefit from a 
framework capable of both tracking, and re-creating the results of the previous attempts.

The following post describes one framework-based solution for these types of problems. 
The corresponding source code for the framework is under [practice/frameworks/workflow/workflow.py][workflow-code].


### Analysis #1

<script src="https://gist.github.com/pyt3r/c47436e6b26448a95f53caf6e68e3d20.js"></script>


### Analysis #2

### Analysis #3

### Analysis #4

### Features


[mini-conda]: https://docs.conda.io/en/latest/miniconda.html
[workflow-code]: https://github.com/pyt3r/practice-package/blob/master/practice/frameworks/workflow/workflow.py
[asset-1]: ../assets/2023-04-05-workflow-1.png
[asset-2]: ../assets/2023-04-05-workflow-2.png
[asset-3]: ../assets/2023-04-05-workflow-3.png
[asset-4]: ../assets/2023-04-05-workflow-4.png
