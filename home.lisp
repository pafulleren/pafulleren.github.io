(defpackage #:blog.home
  (:use :blog.template))

(defun gen-blogs-list (blogs)
  (spinneret:with-html
    (:ol.blogs
     (loop for (title . slug) in blogs
           do (:li (:a :href slug title))))))

(defun gen-home ()
  (compile-page
      (make-blog :title "Homepage"
                 :date "2026-06-26"
                 :body (lambda ()
                         (spinneret:with-html
                           (:p "AAAAAAAAAAAAAAA")
                           (gen-blogs-list *blogs*))))))

