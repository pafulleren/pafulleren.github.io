(defpackage :blog.build
  (:use :cl)
  (:shadowing-import-from :blog.template
                          #:compile-page
                          #:make-page
                          #:make-blog
                          #:footnote))
(in-package :blog.build)

(with-open-file (stream "out/style.css"
                        :direction :output
                        :if-exists :supersede)
  (dolist (style blog.template:*style*)
    (write-string (lass:compile-and-write style) stream)))
(dolist (f (uiop:directory-files "src/" "*.lisp"))
  (load f))
(defvar *blogs* blog.template::*blogs*)
(load "home.lisp")
(with-open-file (stream "out/index.html"
                 :direction :output
                 :if-exists :supersede)
  (write-string (gen-home) stream))
