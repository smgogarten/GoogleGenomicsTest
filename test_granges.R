library(GoogleGenomics)

authenticate("client_secrets.json")

system.time({
granges <- getVariants(datasetId="10473108253681171589",
                       chromosome="22",
                       start=50300077,
                       end=50303000, 
                       converter=variantsToGRanges)
})
