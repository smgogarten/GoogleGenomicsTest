library(bigrquery)
library(ggplot2)

project <- "booming-argon-821"

# histogram of quality
query <- paste("SELECT vt as variant_type, quality, COUNT(1) as cnt",
                "FROM [genomics-public-data:1000_genomes.variants]",
                "GROUP BY variant_type, quality")
dat <- query_exec(query, project)
print(ggplot(dat, aes(x=quality, weight=cnt)) +
      geom_histogram(binwidth=25) +
      facet_grid(variant_type~., scale="free_y") +
        xlim(0, 1000) +
          xlab("Call Quality Score") +
            ylab("Count"))

table(dat$quality[dat$variant_type == 'SNP'])
## SNPs all have quality=100

## what filters have been applied?
query <- paste("SELECT filter, COUNT(1) as filter_count",
               "FROM [genomics-public-data:1000_genomes.variants]",
               "GROUP BY filter")
dat <- query_exec(query, project)
##   filter filter_count
## 1   PASS     39728241
## 2   <NA>           36


# sample info
query <- paste("SELECT Sample as sample_id,",
               "Family_ID as family,",
               "Gender as sex,", 
               "Population, Super_Population",
               "FROM [genomics-public-data:1000_genomes.sample_info]",
               "ORDER BY Population, family")
samp <- query_exec(query, project)
head(samp)

# get genotypes
query <- paste("SELECT reference_name as chromosome, start,",
               "reference_bases as ref,",
               "GROUP_CONCAT(alternate_bases) WITHIN RECORD AS alt,",
               "call.call_set_id as sample_id,",
               "NTH(1, call.genotype) WITHIN call as allele1,",
               "NTH(2, call.genotype) WITHIN call as allele2,",
               "FROM [genomics-public-data:1000_genomes.variants]",
               "WHERE vt='SNP'",
               "AND chromosome='17'",
               "AND start BETWEEN 41196362 AND 41196581",
               "HAVING sample_id IN ('HG00100', 'HG00101')",
               "ORDER BY sample_id, chromosome, start",
               "LIMIT 1000")
dat <- query_exec(query, project)
head(dat)
