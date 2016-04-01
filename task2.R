require(tm)
require(ngram)
require(NLP)
require(ggplot2)
require(dplyr)
require(tidyr)
library(stringr)
library(igraph)


source("utils.R")

# basic sanitation
# - remove all punctuation
# - remove stop words
# - lower-case everything
#
# intermediate sanitation
# - lemmanize words (english)
# - process text sentence by sentence rather than word by word
# - parts of speech
# - remove filler words
#

# good resource:
# https://rstudio-pubs-static.s3.amazonaws.com/31867_8236987cf0a8444e962ccd2aec46d9c3.html

# load the corpi
blog_corpus <-loadRawCorpus("~/Coursera/DataScience/Capstone/data/en_US/us-blogs", random=F, n=10, seed=12345)
twitter_corpus <-loadRawCorpus("~/Coursera/DataScience/Capstone/data/en_US/us-twitter", random=F, n=1, seed=12345)
news_corpus <-loadRawCorpus("~/Coursera/DataScience/Capstone/data/en_US/us-news", random=F, n=1, seed=12345)
test_corpus <-loadRawCorpus("~/Coursera/DataScience/Capstone/data/en_US/test-data/", random=F, n=1, seed=12345)

# datasets to perform word counts on
wc_blog_corpus <- sanitizeCorpus(blog_corpus, keepPunctuation = F, keepStopWords = F)
wc_twitter_corpus <- sanitizeCorpus(twitter_corpus, keepPunctuation = F, keepStopWords = F)
wc_news_corpus <- sanitizeCorpus(news_corpus, keepPunctuation = F, keepStopWords = F)



# # start working with the data
working_corpus <- tm_map(blog_corpus, removeWords, stopwords("english"))
global_tf <- globalTermFrequency(working_corpus)
df <- data.frame(word=as.factor(names(global_tf)), occurrences=as.numeric(unname(global_tf)))
df <- transform(df, word = reorder(word, order(occurrences, decreasing=T)))

ggplot() +
    geom_bar(data=df[1:20, ], aes(x=word, y=occurrences), stat='identity') +
    labs(title="Top 20 Frequent Words")



# ngram counting

# TODO: future stuff: parts-of-speech annotation
NLP::annotate(s, pos_word_annotator, sent_structure)
# -- end future stuff

globalNGramFrequency <- function(raw_corpus, ng=2, stopWords=F){
    corpus <- sanitizeCorpus(raw_corpus, keepPunctuation = T, keepStopWords = stopWords)

    corpus_ngrams <- lapply(corpus, function(document){
        sent_token_annotator <- openNLP::Maxent_Sent_Token_Annotator()
        word_token_annotator <- openNLP::Maxent_Word_Token_Annotator()

        document_ngrams <- lapply(document$content, function(line){
            sline <- trimws(as.String(line))
            if(length(strsplit(sline, "\\s+", fixed = F)[[1]]) == 0){
                return(vector())
            }
            sent_structure <- NLP::annotate(sline, list(sent_token_annotator, word_token_annotator))

            sent_structure <- data.frame(sent_structure)
            sentences <- sent_structure %>% dplyr::filter(type=="sentence") %>% select(start, end)

            # 1 means apply function row-wise
            ngrams <- apply(sentences, 1, function(bounds){
                start <- bounds[1]
                end <- bounds[2]
                sub_s <- substr(line, start, end)
                sub_s <- gsub("[[:punct:]]", "", sub_s)
                sub_s <- trimws(sub_s)
                if( length(strsplit(sub_s, "\\s+", fixed = F)[[1]]) >= ng) {
                    ng_obj <- ngram::ngram(sub_s, n=ng)
                    results <- ngram::get.ngrams(ng_obj)
                }
                else{
                    results <- vector()
                }
                return(results)
            })
            return(unlist(ngrams))
        })
        return(unlist(document_ngrams))
    })
    all_ngrams <- unname(unlist(corpus_ngrams))
    # results <- table(all_ngrams)
    # results <- results[order(results, decreasing=T)]
    # df <- data.frame(ngram=names(results), occurrences=unname(results))
    # return(df)
}

start_t <- Sys.time()
x <- globalNGramFrequency(blog_corpus)
end_t <- Sys.time() - start_t


edges <- str_split_fixed(x, " ", n=2)
df <- data.frame(s=edges[,1], t=edges[, 2])
g <- graph.data.frame(df, directed=T)