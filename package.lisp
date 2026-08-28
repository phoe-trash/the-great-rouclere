(uiop:define-package #:the-great-rouclere
  (:use #:cl)
  (:local-nicknames (#:a #:alexandria-2)
                    (#:h #:hunchentoot)
                    (#:m #:closer-mop)
                    (#:s #:split-sequence))
  (:export #:+http-unexpected-request+
           #:expectations #:surprises #:*failure-stream*
           #:with-magic-show #:with-wand-pointed-at
           #:expect #:answer #:with #:var))
