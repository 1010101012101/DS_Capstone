source("/home/ubuntu/ds-capstone/requirements.R")
source("/home/ubuntu/ds-capstone/utils.R")

pword <- function(model, string, word){
    # return the probability of the given word and words leading up to it.
    #
    # model  -- the model object returned by build
    # word   -- the word your curious about
    # string -- a space delimited string with at most the same number of words as the highest order
    #   markov chain in the model
    #
    # returns a probability [0-1]

    for(order in seq(model$order, 1, -1)) {
        phrase = strtail(string, order)

        result <- tryCatch({
            print(phrase)
            ngram_node <- model$model[[order]][phrase, ]
            if(is.na(ngram_node[word]) || ngram_node[word] == 0){
                ngram_node = NULL
            }
            ngram_node
        }, error = function(e){
            # we need to backoff here. n-th order ngram returned nothing so move down to (n-1 gram)
            NULL
        })

        if(!is.null(result)) {
            # occurences of word given the phrase
            count_word = result[word]

            # occurence of the phrase
            count_phrase = sum(result)

            # discount coefficient
            d = 1
            if(count_word <= 5) {
                d = ((count_word + 1) * sum(model$ngram_freq[[1]] == (count_word + 1))) /
                    ((count_word) * sum(model$ngram_freq[[1]] == (count_word)))
            }

            return(d * count_word / count_phrase)
        }
    }
    return(-1)
}

parallel_nextwords <- function(model, string, cores=1){
    # parallelized version of allnextwords
    
    string = sanitizeString(string, keepPunctuation = F, keepStopWords = T)
    
    predictions <- parallel::mcmapply(function(order){
        phrase = strtail(string, order)
        beta = .005
        rankings <- data.frame(word=c("null"), p=c(-1))
        # ngram_node <- model$model[[order]][phrase, ]
        result <- tryCatch({
            ngram_node <- model$model[[order]][phrase, ]
        }, error = function(e){
            # we need to backoff here. n-th order ngram returned nothing so move down to (n-1 gram)
            NULL
        })
        if(!is.null(result)){
            flags = result > 0
            word_dist <- beta^(model$order - order) * (result[flags] / sum(result[flags]))
            df <- data.frame(word=names(word_dist), p=unname(word_dist))
            rankings <- rbind(rankings, df)
        }
        return(rankings)

    }, 1:model$order, mc.cores=cores)
    
    # combine all the returned dataframes into a single dataframe sorted by probability
    # descending
    do.call(rbind, apply(predictions, MARGIN=2, FUN=data.frame)) %>% arrange(desc(p))
}


allnextwords <- function(model, string){
    # return the word with the highest MLE given the input model and string
    #
    # model  -- the model object returned by build
    # string -- a space delimited string with at most the same number of words as the highest order
    #   markov chain in the model.
    #
    # returns a word

    beta = .01 # penalty for dropping down to lower orders

    rankings <- data.frame(word=c(), p=c(), w=c())

    for(order in seq(model$order, 1, -1)) {
        phrase = strtail(string, order)

        result <- tryCatch({
            print(phrase)
            ngram_node <- model$model[[order]][phrase, ]
        }, error = function(e){
            # we need to backoff here. n-th order ngram returned nothing so move down to (n-1 gram)
            NULL
        })

        if(!is.null(result)){
            flags = result > 0
            
            word_dist <- beta * (result[flags] / sum(result[flags])) 
            df <- data.frame(word=names(word_dist), p=unname(word_dist), w=0)
            rankings <- rbind(rankings, df) %>% head(20)
            
            weights <- apply(model$model[[order]][, rankings$word], FUN=sum, MARGIN=2)
            rankings <- rankings %>% mutate(w= p * unname(sum(weights) / weights))
            
        }

        beta = beta * beta
    }
    predictions <- rankings %>% arrange(desc(w)) %>% head(100)
}


nextwords <- function(model, string){
    # return all words with a non-zero probability of appearing after the given string
    return
}


buildmodel <- function(corpus, highest_order=2, cores=1){
    # build a text-prediction model based on the katz-backoff algorithm.
    # corpus -- a Corpus object from the 'tm' package

    chains = list()
    ngram_counts = list()

    for(order in seq(highest_order, 1, -1)){
        print("finding ngrams...")
        start_t <- Sys.time()

        # parallelized AF
        ngrams <-extractNGrams(corpus, punctuation = F, stopWords = T, ng=order+1, cores=cores)

        delta_t <- Sys.time() - start_t
        print(paste0(order,"-grams found in:"))
        print(delta_t)

        print("building markov chain...")
        df <- data.frame(str_split_fixed(ngrams, " ", n=order+1), stringsAsFactors = F)

        rm(ngrams)

        if(order > 1){
            map_df <- data.frame(ngram=do.call(paste, df[, 1:order]), next_word=trimws(df[, order+1]), stringsAsFactors = F)
        } else {
            map_df <- df %>% rename(ngram=X1, nextword=trimws(X2))
        }

        # ngram_counts[[order]] <- table(map_df$ngram)
        # get rid of ngrams that only show up once. these aren't that useful and are probably mispellings
        map_df <- map_df[duplicated(map_df$ngram) | duplicated(map_df$ngram, fromLast = T),]

        start_t <- Sys.time()
        g <- graph.data.frame(map_df, directed=T)
        delta_t <- Sys.time() - start_t
        print(paste0("markov chain built in:"))
        print(delta_t)

        chains[[order]] <- as_adjacency_matrix(g)


        print("--------------------------------------")
    }

    # result = list(model=chains, ngram_freq=ngram_counts, corpus=corpus, order=highest_order)
    result = list(model=chains, corpus=corpus, order=highest_order)
    return(result)
}


