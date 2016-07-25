library(quantmod)

pepsi <- getSymbols("PEP", from="2013-01-01", to="2016-01-01", adjust = T, auto.assign = FALSE)
coke <- getSymbols("COKE", from="2013-01-01", to="2016-01-01", adjust = T, auto.assign = FALSE)

Sys.setenv(TZ = "UTC")

prices <- cbind(pepsi[, 6], coke[, 6])
price_changes <- apply(prices, 2, diff)


plot(price_changes[, 1], 
     price_changes[, 2],
     xlab = "Coke price changes",
     ylab = "Pepsi price changes",
     main = "Pepsi vs. Coke",
     cex.main = 0.8,
     cex.lab = 0.8,
     cex.axis = 0.8)

grid()

abline(lm(price_changes[,1] ~ price_changes[,2]))
abline(lm(price_changes[,2] ~ price_changes[,1]))

ans <- lm(price_changes[,1] ~ price_changes[,2])
beta <- ans$coefficients[2]


dev.new()
plot(price_changes[,2])
plot(coke[,6])
str(pepsi)
head(pepsi)
plot(pepsi[, "PEP.Adjusted"])
