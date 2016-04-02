require(tm)
require(ngram)
require(NLP)
require(ggplot2)
require(dplyr)
require(tidyr)

## define some useful functions
loadRawCorpus <- function(path, n, random=T, seed=NA){
    # if random = False then just select the first n files

    path = file.path(path)
    source <- DirSource(path)
    source$length <- n
    if(random){
        if(!is.na(seed)) {
            set.seed(seed)
        }
        source$filelist <- sample(source$filelist, n)
    }
    else {
        source$filelist <- source$filelist[1:n]
    }
    corpus <- Corpus(source)
    return(corpus)
}

sanitizeCorpus <- function(corpus, keepPunctuation=F, keepStopWords=F) {
    if(!keepPunctuation){
        corpus <- tm_map(corpus, removePunctuation)
    }
    if(!keepStopWords){
        corpus <- tm_map(corpus, removeWords, stopwords("english"))
    }
    corpus <- tm_map(corpus, removeNumbers)
    corpus <- tm_map(corpus, tolower)
    corpus <- tm_map(corpus, stripWhitespace)
    corpus <- tm_map(corpus, PlainTextDocument)
    return(corpus)
}

globalTermFrequency <- function(corpus){
    # dtm - a document-term matrix representing a corpus to analyze
    # returns: a sorted term-frequency (decreasing) list
    dtm = DocumentTermMatrix(corpus)
    global_tf <- colSums(as.matrix(dtm))
    idx <- order(global_tf, decreasing=T)
    return(global_tf[idx])
}


extractNGrams <- function(raw_corpus, ng=2, stopWords=F, cores=2){
    print(paste("using cores: ", cores))
    corpus <- sanitizeCorpus(raw_corpus, keepPunctuation = T, keepStopWords = stopWords)

    corpus_ngrams <- parallel::mclapply(corpus, function(document){
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
    }, mc.cores=cores)
    all_ngrams <- unname(unlist(corpus_ngrams))
    return(all_ngrams)
}
