setwd("/home/cha/Coursera/DataScience/Capstone/NGramModel/")
library(tm)
library(ngram)
library(markovchain)
library(igraph)
library(ggplot2)
library(dplyr)
library(tidyr)
library(stringr)
source("../utils.R")
ngram_len = 3


# load some data to play around with
sample_corpus <-loadRawCorpus("~/Coursera/DataScience/Capstone/data/en_US/all-data/", random=T, n=1000, seed=12345)

# extract all n+1 grams so we can build mappings of (n-gram) -> next word
start_t <- Sys.time()
ngrams <-extractNGrams(sample_corpus, stopWords = T, ng=ngram_len+1)
end_t <- Sys.time() - start_t
print(end_t)

df <- data.frame(str_split_fixed(ngrams, " ", n=ngram_len+1), stringsAsFactors = F)
map_df <- data.frame(ngram=do.call(paste, df[, 1:ngram_len]), next_word=df[, ngram_len+1], stringsAsFactors = F)
start_t <- Sys.time()
g <- graph.data.frame(map_df, directed=T)
end_t <- Sys.time() - start_t
print(end_t)

s = "would mean the"
g[s][g[s] > 0]



test_sentence <- "president barack obama"
words = strsplit(test_sentence, " ")[[1]]
logprob = 0
for(i in 2:length(words)){
    s <- words[i-1] # start node
    t <- words[i]    # end node
    print(paste0(s, " -> ", t))
    likelihood = (g[s] + .001) / sum(g[s] + .001)
    logprob = log(likelihood[t])
    print( log(likelihood[t]))
}

# now find the most likely next word
last_word <- tail(words, n=1)



start_t <- Sys.time()
mc <- markovchainFit(data=words, parallel = T)
end_t <- Sys.time() - start_t
print(end_t)


node1 <- c("A", "B", "C", "D", "A")
node2 <- c("B", "A", "D", "B", "B")

df <- data.frame(node1=node1, node2=node2)
g <- graph.data.frame(df)
