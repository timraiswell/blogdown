blogdown::new_site("raiswell", theme = "eueung/hugo-casper-two")
library(blogdown)
?new_site
?hugo_build # local = TRUE call to make sure it drags in all new drafts 
?serve_site # does not rebuild the site but starts a web server
?stop_server
olOwOlo/hugo-theme-even

#Git code for terminal

# git commit -m "first commit"
# git remote add origin https://github.com/timraiswell/blogdown.git
# git push -u origin master

# blogdown::new_site("raiswell", theme = "olOwOlo/hugo-theme-even")

###Log in
setwd("/Users/timraiswell/Blog/raiswell")
blogdown::hugo_build(local=TRUE)
blogdown::serve_site()
blogdown::stop_server()
blogdown::update_hugo()

# # Declare Twitter API Credentials
# api_key <- "TEt0KZ4RddAOre4GsbOdbupOT" # From dev.twitter.com
# api_secret <- "nUt2O4PUSDdAl6cZ2GvWW9mzrUL5J3g1eeiolhHo52sSFPXBbe" # From dev.twitter.com
# token <- "742737889809838080-CtQrGFnDUF2c4VrpnFLQssmVuwhO3fP" # From dev.twitter.com
# token_secret <- "RxryAiaY1DuxSdQ6873b6TiuX48fZvgtIAj2mPdKTixG4" # From dev.twitter.com
# 
# # Create Twitter Connection
# setup_twitter_oauth(api_key, api_secret, token, token_secret)

