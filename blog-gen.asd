(asdf:defsystem "blog-gen"
  :description "Blog static site generator"
  :version "0.1.0"
  :author "bshaerk"
  :serial t
  :depends-on (#:spinneret
               #:lass
               #:alexandria)
  :components
  (
    (:file "template")
    (:file "home")
    (:file "build")
  )
)
