# Luca Sanfilippo, 2019-04-24

#' Relative Strenght Index 
#' 
#' Compute the Relative Strenght Index indicator.    
#' 
#' @param closingPrice A vector of past closing prices or an xts object or
#' the column of a dataframe.
#' @param period It is a value (in days: usually it is 14days)
#' 
#' @return A vector or an xts object, accordingly to the input, of the same 
#' length of the input.
#' 
#' @export
#' @author Luca Sanfilippo <luca.sanfilippo@usi.ch>
#' @references \textsc{Welles Wilder, 1978}, \emph{New Concepts in Technical Trading Systems} 
#' @examples
#' library(quantmod)
#' getSymbols('AAPL',src = 'yahoo')
#' closingPrice <- AAPL$AAPL.Close
#' RSI(closingPrice)

RSI <- function(closingPrice, period = 14) {
  # Initialization of variables
  u               <- c(0)
  d               <- c(0)
  BullishAverage  <- c()
  BearishAverage  <- c()
  RS              <- c()
  rsi             <- c()
  dimension       <- c()
  # Data check
  if (length(closingPrice) < period) {
    stop(
      paste0(
        'Cannot compute the require RSI with so few datapoints \n',
        'datapoints:\t',
        length(closingPrice),
        '\n',
        'period length: \t',
        period
      )
    )
  }
  
  # Code to verify the type of data: (vector, xts)
  if ((class(closingPrice) == c('numeric')) &&
      (class(closingPrice) != c('xts', 'zoo'))) {
    ind = F
    dimension <- length(closingPrice)
    coreCP <- closingPrice
    
  } else if ((class(closingPrice) == c('xts', 'zoo')) &&
             (class(closingPrice) != c('numeric'))) {
    ind = T
    dimension = length(closingPrice[, 1])
    coreCP <- coredata(closingPrice[,])
  }
  
  # Computation of the changes (= Close_t – Close_t-1)
  for (i in 1:(dimension - 1)) {
    if (sum(coreCP[i + 1], -coreCP[i]) > 0) {
      u[i + 1] <- coreCP[i + 1] - coreCP[i]
      d[i + 1] <- 0
    } else if (sum(coreCP[i + 1], -coreCP[i]) < 0) {
      u[i + 1] <- 0
      d[i + 1] <- coreCP[i] - coreCP[i + 1]
    } else if (sum(coreCP[i + 1], -coreCP[i]) == 0) {
      u[i + 1] <- 0
      d[i + 1] <- 0
    }
  }
  # Computation of the Average gain and loss:
  for (i in 1:(dimension + 1 - period)) {
    BullishAverage[i]   <- mean(u[i:(i + period - 1)])
    BearishAverage[i]   <- mean(d[i:(i + period - 1)])
    RS[i]               <- BullishAverage[i] / BearishAverage[i]
    rsi[i]              <- 100 - (100 / (1 + RS[i]))
  }
  
  if (ind == T) {
    rsi <-
      xts(c(rep(NA, period - 1), rsi), order.by = index(closingPrice))
  } else{
    rsi <- c(rep(NA, period - 1), rsi)
  }
  
  return(rsi)
}
