require("tm")
require("openNLP")
require("wordnet")


blog_us = file("data/en_US/en_US.blogs.txt")
twitter_us = file("data/en_US/en_US.twitter.txt")
news_us = file("data/en_US/en_US.news.txt")

readLines(blog_us)