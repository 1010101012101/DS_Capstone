library(tm)
library(ngram)
library(markovchain)
library(igraph)
library(ggplot2)
library(dplyr)
library(tidyr)
library(stringr)
source("utils.R")
source("kats-backoff.R")
ngram_len = 1

# leave one core open so the system doesn't die
ncores = parallel::detectCores() - 1

# load some data to play around with
sample_corpus <-loadRawCorpus("data/en_US/all-data/", random=T, n=5, seed=12345)
katzmodel <- buildmodel(sample_corpus)


# extract all n+1 grams so we can build mappings of (n-gram) -> next word
start_t <- Sys.time()
ngrams <-extractNGrams(sample_corpus, stopWords = T, ng=ngram_len+1, cores=1)
end_t <- Sys.time() - start_t
print(end_t)

df <- data.frame(str_split_fixed(ngrams, " ", n=ngram_len+1), stringsAsFactors = F)
if(ngram_len > 1){
    map_df <- data.frame(ngram=do.call(paste, df[, 1:ngram_len]), next_word=df[, ngram_len+1], stringsAsFactors = F)
} else {
    map_df <- df %>% rename(ngram=X1, nextword=X2)
}

start_t <- Sys.time()
g <- graph.data.frame(map_df, directed=T)
end_t <- Sys.time() - start_t
print(end_t)




s = "miss u too"
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
