(defpackage #:blog.template
  (:use :cl)
  (:export :*style*
   :make-page
           :footnote
   :blog
           :make-blog))
(in-package #:blog.template)
(defvar *blogs* nil)
(defvar *footnotes* nil)
(defvar *footnote-counter* 0)
(defvar *style*
  '((:root
     :color-scheme "dark")
    (:media "(prefers-color-scheme: dark)"
     (body
      :background-color "light-dark(#fafafa, #1b262c)"
      :color "light-dark(#000000, #eeeeee)"))
    (.fnref
     :position "relative"
     :cursor "pointer"
     ("a" :text-decoration "none")
     (".fn-preview"
      :display "none"
      :position "absolute"
      :bottom "1.4em"
      :left "50%"
      :transform "translateX(-50%)"
      :width "20em"
      :background "light-dark(#fafafa, #1b262c)"
      :color "light-dark(#000000, #eeeeee)"
      :border "1px solid #ccc"
      :border-radius "4px"
      :padding ".5em .75em"
      :font-size ".85em"
      :font-weight "normal"
      :vertical-align "baseline"
      :z-index 10
      :box-shadow "0 2px 8px rgba(0,0,0,.15)")
     ((:parent :hover)
      (.fn-preview
       :display block)))
    (:media "(hover: none)"
     (.fnref
      ((:parent :hover)
       (.fn-preview
        :display none)))
     ((.footnotes li)
      :display none
      ((:parent :target)
       :display block
       :position fixed
       :bottom 0
       :left 0
       :right 0
       :background "light-dark(#fafafa, #1b262c)"
       :border-top "2px solid #ccc"
       :padding "1em 1.25em"
       :z-index 100
       :font-size "1rem"
       :box-shadow "0 -4px 12px rgba(0,0,0,.2)")))
    (.title
     ((:parent -container)
      :display flex
      :flex-direction column
      :align-items center
      :justify-content center
      :gap "8px"
      :padding "24px 0"
      :border-bottom "2px solid #e0e0e0")
     ((:parent -date)
      :font-size "0.875rem"
      :font-weight 600
      :color "#667085"
      :text-transform uppercase
      :letter-spacing "0.05em")
     ((:parent -text)
      :margin 0
      :font-size "2rem"
      :color "light-dark(#1a1a1a, a1a1a1)"
      :line-height 1.2))))

(defstruct blog title date body)

(defun render-footnotes ()
  (spinneret:with-html
    (:ol.footnotes
     (loop for pair in (reverse *footnotes*)
           for n = (car pair)
           and thunk = (cdr pair)
           do (:li :id (format nil "fn-~a" n)
                   (:a :href (format nil "#fnref-~a" n) "↑")
                   (funcall thunk))))))

(defmacro footnote (&body content)
  (alexandria:with-gensyms (n)
    `(let ((,n (incf *footnote-counter*)))
       (push (cons ,n (lambda () (spinneret:with-html ,@content))) *footnotes*)
       (spinneret:with-html
         (:sup.fnref
           (:a :href (format nil "#fn-~a" ,n)
               :id  (format nil "fnref-~a" ,n)
             (format nil "[~a]" ,n)
             (:span.fn-preview ,@content)))))))

(defmacro with-footnote-context (&body body)
  `(let ((*footnotes* nil)
         (*footnote-counter* 0))
     ,@body
     (render-footnotes)))

(defun title->slug (title)
  (string-downcase
   (substitute #\- #\space title)))

(defun compile-page (blog)
  (spinneret:with-html-string
    (:doctype)
    (:html
     (:head (:title (blog-title blog))
            (:link :rel "stylesheet" :href "style.css")
            (:meta :name "viewport" :content "width=device-width, initial-scale=1"))
     (:body
      (with-footnote-context
        (:header :class "title-container"
                 (:h1 :class "title-text" (blog-title blog))
                 (:span :class "title-date" (blog-date blog)))
        (funcall (blog-body blog)))))))

(defun make-page (blog)
  (let* ((title (blog-title blog))
         (slug (format nil "~A.html" (title->slug title))))
    (push (cons title slug) *blogs*)
    (with-open-file (stream (format nil "out/~A" slug)
                     :direction :output
                     :if-exists :supersede)
      (write-string (compile-page blog) stream))))
