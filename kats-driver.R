source("kats-backoff.R")

datasets <- createDataSets("data/en_US/all-data/", p_training = .15, seed = 12345)
cv_idx <- createCVSets(datasets$training, folds=30)
cv_results = rep(0, 30)

for(i in 1:30){
    cv_training <- datasets$training[cv_idx != i]
    cv_testing <- datasets$training[cv_idx == i]
    cv_model <-buildmodel(createCorpus(cv_training), highest_order = 3, cores = 15)

    # load a text file and test the model
    fin <- file(cv_testing[1], "r")
    lines <- sample(readLines(fin), replace = F, size = 500)
    close(fin)

    correct = 0
    for(line in lines){
        line <- sanitizeString(line, keepPunctuation = F, keepStopWords = T)
        phrase <- strhead(line, 5)
        x <- strhead(phrase, 4)
        y <- strtail(phrase, 1)

        prediction <- parallel_nextwords(cv_model, x, cores = 15)[1, "word"]
        if(trimws(y) == trimws(prediction)){
            correct = correct + 1  
        }
        # print(phrase)
        # print(paste("actual:", y, ", predicted:", prediction))
    }
    print(paste("fold =", i, "--", correct / 500))
    cv_results[i] = correct / 500
}





datasets <- createDataSets("data/en_US/all-data/", p_training = .15, seed = 12345)
print(length(datasets$training))
training_corpus <- createCorpus(datasets$training)
comp_katzmodel_500_3 <- buildmodel(training_corpus, highest_order = 3, cores = 15)



# model <- buildmodel(training_corpus, highest_order = 3, cores = 3)
# save(comp_katzmodel_2000_3, file="comp_katzmodel_2000_3.cha")
# load("comp_katzmodel_2000.cha")

start_t <- Sys.time()
f <- allnextwords(comp_katzmodel_2000_3, "it may be a few days")
print(Sys.time() - start_t)

start_t <- Sys.time()
f2 <- parallel_nextwords(comp_katzmodel_2000_3, "rights belong to", cores=3)
print(Sys.time() - start_t)



start_t <- Sys.time()
pword(model = comp_katzmodel_2000_3, string = "if this is", word = "the")
print(Sys.time() - start_t)