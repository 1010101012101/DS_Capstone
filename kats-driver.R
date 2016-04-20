source("kats-backoff.R")

sample_corpus <-loadRawCorpus("data/en_US/all-data/", random=T, n=50, seed=12345)
model <- buildmodel(sample_corpus, highest_order = 3, cores = 3)


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