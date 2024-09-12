Materia.O=rnorm(n=150, mean = 3, sd = 0.5)
xy=expand.grid(x=seq(1,10), y=seq(1,15))

mo.dist<-as.matrix(dist(cbind(xy)))
mo.dist.inv=1/mo.dist
diag(mo.dist.inv)<-0
mo.dist.inv[1:10, 1:10]

library(ape)
Moran.I((Materia.O), mo.dist.inv)