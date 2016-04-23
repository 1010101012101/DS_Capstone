strtail <- function(string, n){
    # return the last n words of a string as a string
    words <- strsplit(string, " ")[[1]]
    return(paste(tail(words, n), collapse = " "))
}

strhead <- function(string, n){
    # return the first n words of a string as a string
    words <- strsplit(string, " ")[[1]]
    return(paste(head(words, n), collapse = " "))
}

createDataSets <- function(path, p_training=.7, seed=12345){
    # split the text files contained in path into a training and test file list. p defines the
    # proportion of filenames that are assigned to training. returns a named list with two names:
    # training and testing. both map to vectors
    #
    path = file.path(path)
    source <- DirSource(path)

    set.seed(seed)
    trainIndex <- createDataPartition(1:length(source$filelist), p = p_training, list = F, times = 1)

    list(training=source$filelist[trainIndex], testing=source$filelist[-trainIndex])
}

createCVSets <- function(filelist, folds = 10) {
    # takes a DirSource object and returns a vector of cv groupings, 1:10. the groups are used to
    # partition the filelist in the dirsource
    createFolds(filelist, k = folds, list=F)
}

createCorpus <- function(filelist){
    # takes a DirSource object and creates a Corpus object out of them
    #
    source <- DirSource(".")
    source$filelist <- filelist
    source$length <- length(filelist)
    corpus <- Corpus(source)
    return(corpus)
}

sanitizeString <- function(s, keepPunctuation=F, keepStopWords=F) {
    s <- tolower(s)
    s <- stripWhitespace(s)
    s <- trimws(s)
    if(!keepStopWords){
        s <- removeWords(s, stopwords("english"))
    }
    if(!keepPunctuation){
        s <- removePunctuation(s, preserve_intra_word_dashes = T)
    }
    s <- removeNumbers(s)
    return(s)
}

sanitizeCorpus <- function(corpus, keepPunctuation=F, keepStopWords=F) {
    corpus <- tm_map(corpus, tolower)
    corpus <- tm_map(corpus, stripWhitespace)
    if(!keepStopWords){
        corpus <- tm_map(corpus, removeWords, stopwords("english"))
    }
    if(!keepPunctuation){
        corpus <- tm_map(corpus, removePunctuation, preserve_intra_word_dashes=T)
    }
    corpus <- tm_map(corpus, removeNumbers)
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


extractNGrams <- function(raw_corpus, ng=2, punctuation=F, stopWords=F, cores=2){
    print(paste("using cores: ", cores))
    corpus <- sanitizeCorpus(raw_corpus, keepPunctuation = punctuation, keepStopWords = stopWords)

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
