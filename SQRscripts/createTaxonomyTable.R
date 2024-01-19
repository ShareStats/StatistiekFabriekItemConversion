source("SQRscripts/DBconnect.R")

n.items = 1949
taxonomy.path.nl = vector()

for (item_id in 1:n.items) {

query = "select items_tags.tag_id,
                tags.description
         from   items_tags,
                tags
         where  items_tags.item_id = %s
         and    items_tags.tag_id = tags.id"

query = sprintf(query, item_id)

res     <- dbSendQuery(con, query)
tag.ids <- dbFetch(res)

dbClearResult(res)

# Select only taxonomy tags which have tag id < 156
taxonomy <- tag.ids[which(tag.ids$tag_id<151), "description"]
exsection.nl = paste(taxonomy, collapse = ",")

taxonomy.path.nl[item_id] = exsection.nl

}

# Limit to unique paths
taxonomy.path.nl <- unique(taxonomy.path.nl)
# Order taxonomy
taxonomy.path.nl <- taxonomy.path.nl[order(taxonomy.path.nl)]

# Write to file
write.csv2(taxonomy.path.nl, file = "SQRscripts/taxonomy_from_tags_table_sql.csv")
