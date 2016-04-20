source("kats-backoff.R")

sample_corpus <-loadRawCorpus("data/en_US/all-data/", random=T, n=50, seed=12345)
model <- buildmodel(sample_corpus, highest_order = 3, cores = 2)
# save(comp_katzmodel_2000_3, file="comp_katzmodel_2000_3.cha")

# load("comp_katzmodel_2000.cha")

start_t <- Sys.time()
f <- allnextwords(comp_katzmodel_2000_3, "if this is")
print(Sys.time() - start_t)

start_t <- Sys.time()
pword(model = comp_katzmodel_2000_3, string = "if this is", word = "the")
print(Sys.time() - start_t)