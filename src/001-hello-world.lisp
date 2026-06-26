(make-page
 (make-blog
  :title "Hello World!"
  :date "2026-06-26"
  :body (lambda ()
          (spinneret:with-html
            (:h2 "Hello world!")
            (:p "This is the first blog I have made, and also the test for my static site generator.")
            (:p "Why did I make a static site generator instead of using the billion already out there? Uhh... Why not, I guess. Making a blog was just an excuse to mess around.")
            (:p "God, this is boring. I don't know what to type. It uses Spinneret" (footnote "A Common Lisp library to generate HTML from sexprs") ", and LASS" (footnote "Another library to generate CSS in CL") "to create the files, iterating through a directory (src/) and loading every .lisp file in it. It's cursed, probably.")))))
