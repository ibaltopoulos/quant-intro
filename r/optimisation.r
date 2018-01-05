#############################################################################
###
###  Webinar - Contemporary Portfolio Optimization Modeling with R
###  -------------------------------------------------------------
###  Ronald Hochreiter - http://www.finance-r.com/cpom/
###
#############################################################################

# This script enables a simple and easy Quick-Start to follow the content of 
# the Webinar, i.e. to replicate everthing presented using RStudio. 
# Simply open this file with RStudio and source it (e.g. Menu->Code->Source)

# If package devtools is not installed, install it. In any case, activate it.
if(!("devtools" %in% rownames(installed.packages()))) { install.packages("devtools") }
library(devtools)

# Install the latest version of the Webinar package from GitHub
install_github("rhochreiter/webinar-cpom/package")
library(webinar.cpom)

# Choose the version of the Webinar
version <- 1

# Run the setup package, which installs all necessary packages
source(paste0(path.package("webinar.cpom"), "/cpom.setup.", version, ".R"))

# Open the Webinar script in the editor pane
file.edit(paste0(path.package("webinar.cpom"), "/cpom.webinar.", version, ".R"))
