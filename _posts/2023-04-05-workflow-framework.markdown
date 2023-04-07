---
layout: post
title:  A Data-Driven Workflow Framework in Python
date:   2023-04-05 12:00:00 -0000
tags: workflow, data science, analytics, python, software framework, code as data
---

Often, data analysts and developers find themselves writing code that can be represented 
as a linear sequence of functions. Whether it be a data processing pipeline, 
or an ordered set of tasks, the sequence progresses from one function to the next, 
registering and consuming intermediate results along the way. 
Such sequences can be difficult to maintain, especially should one wish to apply changes 
and observe the updated results. 

Consider the case of a data analyst that processes and 
visualizes historical price data in order to devise a trading strategy.
The analyst attempts different data cleansing and statistical techniques before
formulating the final strategy. 
As the number of attempts increases, each version of code, and corresponding result,
becomes difficult to organize. 
Ultimately, the analyst acknowledges that their efforts would have benefited from a 
framework capable of both tracking, and re-creating the results of, their previous attempts.

The following post describes one [framework-based solution][workflow-code] that this particular 
data analyst wishes they had during their quest for a trading strategy.


#### Analysis #1

<script src="https://gist.github.com/pyt3r/c47436e6b26448a95f53caf6e68e3d20.js"></script>


#### Analysis #2

#### Analysis #3

#### Analysis #4

## Features

#### Serialization

The data analyst can use the framework to transfer their workflow to a recipient. 
Similarly, the recipient can use the framework to import, and run, the 
transferred workflow.

{% highlight python %}
# == Export ==
workflow = Analysis1.create()
DF = workflow.asDF()
DF.to_csv("workflow1.csv")

# == Import ==
DF = pd.read_csv("workflow1.csv")
workflow = api.Workflow.createFromDF(DF)
results = workflow.run(data)
{% endhighlight %}


As an added benefit, the serialization feature allows workflow code to be saved and managed
as data in a database or filesystem, for example, and not as source code in a version control system.




[mini-conda]: https://docs.conda.io/en/latest/miniconda.html
[workflow-code]: https://github.com/pyt3r/practice-package/blob/master/practice/frameworks/workflow/workflow.py
[asset-1]: ../assets/2023-04-05-workflow-1.png
[asset-2]: ../assets/2023-04-05-workflow-2.png
[asset-3]: ../assets/2023-04-05-workflow-3.png
[asset-4]: ../assets/2023-04-05-workflow-4.png
