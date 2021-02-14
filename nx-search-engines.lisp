;;;; nx-search-engines.lisp

(in-package #:nx-search-engines)

(defmacro define-search-engine (name (&key shortcut fallback-url base-search-url documentation)
                                &body keywords)
  "Defines a new `nyxt:search-engine' called NAME and having FALLBACK-URL.
`nyxt:search-url' of the new engine is built from BASE-SEARCH-URL and KEYWORDS.

BASE-SEARCH-URL is a control string with one placeholder (e.g.,
\"example.com/?q=~a\") each keyword in KEYWORDS is a list of a
form (KEYWORD URI-PARAMETER VALUES), where VALUES is either
- an association list of possible values and their URI representations, or
- a function to process the value provided by the user.

Example:"
  (let ((keyword-names (mapcar #'first keywords)))
    `(defun ,name (&key
                     (fallback-url ,fallback-url)
                     (shortcut ,shortcut)
                     ,@keyword-names)
       ,documentation
       (make-instance 'nyxt:search-engine
                      :shortcut shortcut
                      :fallback-url fallback-url
                      :search-url (format nil "~a~{~a~}"
                                          ,base-search-url
                                          (remove-if
                                           #'null
                                           (list
                                            ,@(loop :for (name uri-parameter values)
                                                      :in keywords
                                                    :collect
                                                    `(when ,name
                                                       (format nil "&~a=~a"
                                                               ,uri-parameter
                                                               ,(if (eq (first values) :function)
                                                                    `(funcall ,(second values) ,name)
                                                                    `(cond
                                                                       ,@(dolist (value values)
                                                                           `((equal ,name ,(first value))
                                                                             ,(second value)))))))))))))))

(define-search-engine google
    (:shortcut "google"
     :fallback-url "google.com"
     :base-search-url "google.com/search?q=~a"
     :documentation "")
  (safe-search "safe" ((t   "strict")
                       (nil "images")))
  (object "tbm" ((:all      "")
                 (:image    "isch")
                 (:video    "vid")
                 (:news     "nws")
                 (:shopping "shop")
                 (:books    "bks")
                 (:finance  "fin"))))
