source("kats-backoff.R")

sample_corpus <-loadRawCorpus("data/en_US/all-data/", random=T, n=500, seed=12345)
katzmodel <- buildmodel(sample_corpus, highest_order = 3, cores = 15)
save(katzmodel, file="500_katzmodel.cha")