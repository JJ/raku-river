library("networkD3")
library("igraph")

data <- read_graph("perl6-ecosystem.net",format="pajek")
distros <-  igraph_to_networkD3(data)
sn <- sankeyNetwork(Links = distros$links, Nodes = distros$nodes, Source = "source",
                    Target = "target", Value = "value", NodeID = "name",
                    units = "commits", fontSize = 20, nodeWidth=30)
sn %>% saveNetwork( file= 'sankey.html' )

tree <- forceNetwork(Links = distros$links, Nodes = distros$nodes, Source = "source",
                     Target = "target", Value = "value", NodeID = "name", Group="1",
                      fontSize = 20)
