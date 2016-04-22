---
title       : Text Prediction 
subtitle    : Data Science Capstone Project
author      : Cha Li
job         : 
framework   : io2012        # {io2012, html5slides, shower, dzslides, ...}
highlighter : highlight.js  # {highlight.js, prettify, highlight}
hitheme     : tomorrow      # 
widgets     : []            # {mathjax, quiz, bootstrap}
mode        : selfcontained # {standalone, draft}
knit        : slidify::knit2slides
---

## Introduction


--- .class #id 


##  Datasets and Preprocessing
The text dataset used for this project included large amounts of data taken from news stores, blog
posts, and Twitter. An exploratory analysis of the datasets can be found [here](http://rpubs.com/chavli/ds-capstone).
[SwiftKey](https://swiftkey.com/en) and [Coursera](www.coursera.com) provided the datasets.

### Preprocessing

1. normalized everything to lower-case  
2. removed symbols and punctuation, except apostrophes
3. removed redundant whitespace
4. split the data into 1000 line files for easier sampling

I decided to keep stopwords (words with little contextual meaning) since they have a bigger role in 
text prediction than in topic modelling. Stopwords are valid predictions!




--- 

## Models and Algorithms
this is a test

--- 

## Implementation and Optimization
Graph models are a natural way of representing relationships between entities. In this scenario, words
and phrases are vertices and the relationships are represented as edges connecting vertices. 

### Speed (Hardware)
This includes training time and prediction time. I was able to decrease both significantly by writing
parallelizable code capable of running on 1, 15, or more cores. 

### Memory (Software)
Relationships between phrases and words can be numerous but sparse. Choosing the right data structure
can not only reduce the memory footprint but also decrease prediction time. In my case, I chose to use
a sparse adjacency matrix to represent the graph model.




--- 

## Conclusion
this is a test

--- 
