library("networkD3")
library("igraph")

data <- read_graph("perl6-ecosystem.net",format="pajek")
issues <-  igraph_to_networkD3(data)
sn <- sankeyNetwork(Links = issues$links, Nodes = issues$nodes, Source = "source",
                    Target = "target", Value = "value", NodeID = "name",
                    units = "commits", fontSize = 20, nodeWidth=30)
sn %>% saveNetwork( file= 'sankey.html' )
