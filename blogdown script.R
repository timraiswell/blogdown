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

