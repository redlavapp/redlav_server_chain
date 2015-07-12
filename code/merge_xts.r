multi.xts.merge <- function(listOguys) {
    require(xts)
    dat <- Reduce(function(x, y) {merge.xts(x, y)}, listOguys)
    names(dat) <- as.character(substitute(listOguys))[-1]
    return(dat)
}

multi.xts.merge(list(OIH, SU, SMH))