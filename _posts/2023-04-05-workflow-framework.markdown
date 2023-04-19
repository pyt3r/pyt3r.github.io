---
layout: post
title:  A Data-Driven Workflow Framework in Python
date:   2023-04-05 12:00:00 -0000
tags: workflow, framework, python, data driven, data analytics, code as data
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
As the number of attempts increases, each version of code, and its respective result, 
becomes difficult to manage. 

Ultimately, the analyst acknowledges their need for a tool capable of managing, tracking, 
and re-creating the results of their previous attempts. 
The following post describes one such [framework-based solution][workflow-code]
that the analyst could benefit from.


### Analysis #1: Raw Visualization

Taking the previous example, the data analyst might have started with a 
simple workflow to visualize the raw timeseries data. 

Using the framework, the first analytical workflow could have been coded as follows:

(*The full snippet can be found under [practice/examples/workflow/analysis.py][workflow-example]*.)

<script src="https://gist.github.com/pyt3r/c47436e6b26448a95f53caf6e68e3d20.js"></script>

Prior to running the workflow object from the above snippet, 
the analyst could inspect and visualize the workflow as data by invoking the **.asDF()** method.
The resulting DataFrame-based representation would appear as follows:

![dataframe-1]

For each row in the DataFrame,

* The function specified by the **funcPath** column consumes the args and kwargs 
  specified by the **inputKeys** and **kwargs** columns, respectively. 

* The corresponding result of the function is, then, registered using the key 
  specified in the **outputKeys** column.

Once the calculation of the last row completes, then all **outputKeys** can be accessed.
Accessing the 'fig' **outputKey** from the registered results, for example, would yield the following figure:

![plot-1]

(*The data presented on this page is approved for commercial use, as evident by the [Quandl License][quandl].*)

### Analysis #2: Isolating the Test Period
The analyst might then decide to examine the economic downturn period more closely 
and work towards a strategy that minimizes downside risk.  

Accordingly, the analyst might adjust their prior workflow to isolate the downturn period, as follows:

![dataframe-2]

Accessing the 'fig' **outputKey** for this adjusted workflow would yield the following figure:

![plot-2]


### Analysis #3: Finalizing the Strategy

Through visually inspecting the sharp price fluctuations during the downturn period, 
the analyst thinks that a simple strategy using a long and short simple moving average (SMA) 
might perform well. 

As a result, the analyst tests this theory and codes the strategy as follows:

![dataframe-3]

This particular strategy involves 
buying when the short SMA crosses over the long SMA in the positive direction, 
and selling when the long SMA crosses over the short SMA in the negative direction, 
as depicted by the **crossover** indicator in the following chart:

![plot-3]

*[This page][read-the-docs] contains more information related to simple technical indicators,
such as the one described above.*

## Features

In addition to showcasing manageability, the previous examples uncover 
three more beneficial features of the framework.

#### 1) Serialization

Users can leverage the framework to transfer their workflow to a recipient, such as a colleague or manager,
as depicted in the following snippet:

{% highlight python %}
workflow = Analysis1.create()
DF = workflow.asDF()
DF.to_csv("workflow1.csv")
{% endhighlight %}

On the receiving end, the recipient can use the framework to seamlessly ingest, and run, the
transferred workflow, as follows:

{% highlight python %}
DF = pd.read_csv("workflow1.csv")
workflow = api.Workflow.createFromDF(DF)
data = {
    "ticker"   : "jpm",
    "dateCol"  : "Date",
    "valueCol" : "Close", }
results = workflow.run(data)
{% endhighlight %}


As an added benefit, the serialization feature allows workflow code to be saved and managed
as data in a database (or filesystem, for example), and not as source code in a VCS.


#### 2) Graphical Representation

Prior to invoking any workflow, users can generate the workflow's corresponding 
Directed Acyclic Graph (DAG), which helps to trace dependencies, as depicted in the following image:

![dag-123]


#### 3) Debug-ability

Users can step through any given workflow, as exemplified in the following snippet:

{% highlight python %}

workflow = Analysis1.create()

data0 = {
    "ticker"   : "jpm",
    "dateCol"  : "Date",
    "valueCol" : "Close", }

data1 = workflow.runNext(data0)
data2 = workflow.runNext(data1)
data3 = workflow.run(data2)

{% endhighlight %}


## Conclusion

When conducting analyses, data analysts and developers carry the burden of managing workflows,
configurations, and resulting datasets.I hope that the framework presented on this page remediates this burden,
or at the very least, promotes an awareness of the operational pitfalls that exist 
(and that I've too often encountered) in the analytics space.



[mini-conda]: https://docs.conda.io/en/latest/miniconda.html
[workflow-code]: https://github.com/pyt3r/practice-package/blob/master/practice/frameworks/workflow/workflow.py
[workflow-example]: https://github.com/pyt3r/practice-package/blob/master/practice/examples/workflow/analysis.py
[quandl]: https://github.com/quandl/quandl-python/blob/master/LICENSE.txt
[read-the-docs]: https://practice-package.readthedocs.io/en/latest/technical_analysis.html
[dataframe-1]: ../assets/2023-04-05-dataframe-1.png
[dataframe-2]: ../assets/2023-04-05-dataframe-2.png
[dataframe-3]: ../assets/2023-04-05-dataframe-3.png
[plot-1]: ../assets/2023-04-05-plot-1.png
[plot-2]: ../assets/2023-04-05-plot-2.png
[plot-3]: ../assets/2023-04-05-plot-3.png
[dag-123]: ../assets/2023-04-05-dag.png

