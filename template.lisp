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
      :color "light-dark(#000000, #eeeeee)"
      :font-size "1.25em"))
    (.title
     ((:parent -container)
      :display flex
      :flex-direction column
      :align-items center
      :justify-content center
      :gap "8px"
      :padding "24px 0"
      :border-bottom "2px solid #e0e0e0"
      (a
       :color inherit
       :text-decoration inherit
       :cursor text))
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
      :line-height 1.2))
    (.footnote-modal-overlay
     :position "absolute"
     :bottom "1.4em"
     :left "50%"
     :transform "translateX(-50%)"
     :width "50vw"
     :background "light-dark(#f8f8f8, #19242a)"
     :color "light-dark(#000000, #eeeeee)"
     :border "1px solid #ccc"
     :border-radius "4px"
     :padding ".5em .75em"
     ;:font-size "0.75em"
     :font-weight "normal"
     :vertical-align "baseline"
     :z-index 1000
     :box-shadow "0 2px 8px rgba(0,0,0,.15)"
     :height "fit-content")
    (:media "(hover: none)"
            (.footnote-modal-overlay
             :display "flex"
             :justify-content "center"
             :position "fixed"
             :bottom 0
             :width "100vw"))
    (.hidden
     :display "none")))

(defstruct blog title date body)

(defun render-footnotes ()
  (spinneret:with-html
    (:ol.footnotes
     (loop for pair in (reverse *footnotes*)
           for n = (car pair)
           and thunk = (cdr pair)
           do (:li :id (format nil "fn-~a" n)
                   (:a :href (format nil "#fnref-~a" n) "ʌ")
                   (funcall thunk))))))

(defmacro footnote (&body content)
  (alexandria:with-gensyms (n)
    `(let ((,n (incf *footnote-counter*)))
       (push (cons ,n (lambda () (spinneret:with-html ,@content))) *footnotes*)
       (spinneret:with-html
         (:sup.fnref
           (:a :href (format nil "#fn-~a" ,n)
               :id  (format nil "fnref-~a" ,n)
               :_ (format nil "on mouseenter
                                 put innerHTML of #fn-~a into #footnote-popup-box then
                                   remove .hidden from #footnote-popup-box then
                                   if (window.matchMedia('(hover: hover)').matches)
                                   measure #footnote-popup-box then set :popheight to result.height
                                   then set *top of #footnote-popup-box to (event.clientY - :popheight) + 'px'
                                   then set *left of #footnote-popup-box to (event.clientX - 25) + 'px'
                                 end
                               end
                               on mouseout wait 100ms then if (not $isTooltipHovered) add .hidden to #footnote-popup-box end end
                               on click
                                 put innerHTML of #fn-~0@*~a into #footnote-popup-box then
                                 remove .hidden from #footnote-popup-box
                               end" ,n)
               (format nil "[~a]" ,n)))))))

(defmacro with-footnote-context (&body body)
  `(let ((*footnotes* nil)
         (*footnote-counter* 0))
     ,@body
     (render-footnotes)
     (spinneret:with-html
      (:div :id "footnote-popup-box"
            :class "footnote-modal-overlay hidden"
            :_ "on click from body
                  if event.target is not in me and not event.target.matches('.fnref a')
                    add .hidden to me
                  end
                end
                on keyup from window
                  if event.key is 'Escape' or event.target.id is 'footnote-popup-box'
                    add .hidden to me
                  end
                end
                on mouseenter remove .hidden from me then set $isTooltipHovered to true end
                on mouseleave wait 150ms then add .hidden to me then set $isTooltipHovered to false end"
            :style "position: fixed;"))))

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
                 (:a :href "/" (:h1 :class "title-text" (blog-title blog)))
                 (:span :class "title-date" (blog-date blog)))
        (funcall (blog-body blog))
        (:script :src "https://cdn.jsdelivr.net/npm/hyperscript.org@0.9.93/dist/_hyperscript.min.js" :integrity "sha384-/6HsqTiz02YfFBUhzTwlH/yxe68DhfnkdHiWytM3nxAzs/yvG+3FZY0f4KLnNoov" :crossorigin "anonymous"))))))

(defun make-page (blog)
  (let* ((title (blog-title blog))
         (slug (format nil "~A.html" (title->slug title))))
    (push (cons title slug) *blogs*)
    (with-open-file (stream (format nil "out/~A" slug)
                     :direction :output
                     :if-exists :supersede)
      (write-string (compile-page blog) stream))))
