source("kats-backoff.R")

sample_corpus <-loadRawCorpus("data/en_US/all-data/", random=T, n=5, seed=12345)
katzmodel <- buildmodel(sample_corpus)