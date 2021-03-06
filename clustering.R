
library(tidyr, dplyr)
library(ggplot2)
library(broom)
library(RColorBrewer)
library(cluster)
library(useful)
library(pvclust)
library(mclust)
library(fpc)

D1 <- read.table("online-tutor.csv", sep = ",", header = TRUE)
D2 <- dplyr::select(D1, height,score,hints)

mydata <- na.omit(D2) # listwise deletion of missing
mydata <- scale(mydata) # standardize variables

# Determine number of clusters
wss <- (nrow(mydata)-1)*sum(apply(mydata,2,var))
for (i in 2:15) wss[i] <- sum(kmeans(mydata, 
                                     centers=i)$withinss)
plot(1:15, wss, type="b", xlab="Number of Clusters",
     ylab="Within groups sum of squares")

# K-Means Cluster Analysis
fit <- kmeans(mydata, 5) # 5 cluster solution
# get cluster means 
aggregate(mydata,by=list(fit$cluster),FUN=mean)
# append cluster assignment
mydata <- data.frame(mydata, fit$cluster)

# Ward Hierarchical Clustering
d <- dist(mydata, method = "euclidean") # distance matrix
fit <- hclust(d, method="ward.D") 
plot(fit) # display dendogram
groups <- cutree(fit, k=5) # cut tree into 5 clusters
# draw dendogram with red borders around the 5 clusters 
rect.hclust(fit, k=5, border="red")

# Ward Hierarchical Clustering with Bootstrapped p values
library(pvclust)
fit <- pvclust(mydata, method.hclust="ward.D",
               method.dist="euclidean")
plot(fit) # dendogram with p values
# add rectangles around groups highly supported by the data
pvrect(fit, alpha=.95)

# Model Based Clustering
library(mclust)
fit <- Mclust(mydata)
plot(fit) # plot results 
summary(fit) # display the best model
  
  #----------------------------------------------------
#(without glasses)Gaussian finite mixture model fitted by EM algorithm 
#----------------------------------------------------

#  Mclust VEV (ellipsoidal, equal shape) model with 4 components:

#  log.likelihood    n df       BIC       ICL
#-3896.939 1000 50 -8139.266 -8139.268

#Clustering table:
#  1   2   3   4 
#222 199 364 215 

# K-Means Clustering with 5 clusters
fit1 <- kmeans(mydata, 4)

# Cluster Plot against 1st 2 principal components

# vary parameters for most readable graph

clusplot(mydata, fit1$cluster, color=TRUE, shade=TRUE, 
         labels=2, lines=0)

# Centroid Plot against 1st 2 discriminant functions

plotcluster(mydata, fit1$cluster)

fit2 <- kmeans(mydata, 5)

# Cluster Plot against 1st 2 principal components

# vary parameters for most readable graph

clusplot(mydata, fit2$cluster, color=TRUE, shade=TRUE, 
         labels=2, lines=0)

# Centroid Plot against 1st 2 discriminant functions

plotcluster(mydata, fit2$cluster)

# comparing 2 cluster solutions

cluster.stats(d, fit1$cluster, fit2$cluster)
