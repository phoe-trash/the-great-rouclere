(defpackage #:the-great-rouclere/tests
  (:use #:cl)
  (:local-nicknames (#:a #:alexandria-2)
                    (#:d #:drakma)
                    (#:h #:hunchentoot)
                    (#:r #:the-great-rouclere))
  (:export #:magic!))

(in-package #:the-great-rouclere/tests)

(defun magic! ()
  (5am:run! 'the-great-rouclere))

(5am:def-suite the-great-rouclere)

(5am:in-suite the-great-rouclere)

(5am:test basics
  (r:with-magic (port)
    ;; Arrange
    (r:expect (:get "/ping")
      (r:with :header "Magic-Dust" "Imagination")
      (r:with :accept "application/magic-show")
      (r:answer (h:+http-ok+)
        (r:with :body "That's perfect!!!")
        (r:with :content-type "text/plain")
        (r:with :header "Magic-Dust" "Prestidigitation")))
    ;; Assert
    (5am:is (= 1 (length (r:expectations))))
    (let ((expectation (first (r:expectations))))
      (5am:is (eq :get (getf expectation :method)))
      (5am:is (= 1 (getf expectation :times)))
      (5am:is (equal "/ping" (getf expectation :url)))
      (5am:is (a:set-equal '(("Magic-Dust" . "Imagination")
                             ("Accept" . "application/magic-show"))
                           (getf expectation :headers)
                           :test #'equal))
      (5am:is (equal '() (getf expectation :accept)))
      (let ((response (getf expectation :response)))
        (5am:is (= 200 (getf response :code)))
        (5am:is (equal "That's perfect!!!" (getf response :body)))
        (5am:is (a:set-equal '(("Magic-Dust" . "Prestidigitation")
                               ("Content-Type" . "text/plain"))
                             (getf response :headers)
                             :test #'equal))))
    ;; Act
    (multiple-value-bind (body status-code headers)
        (d:http-request (format nil "http://localhost:~D/ping" port)
                        :accept "application/magic-show"
                        :additional-headers '(("Magic-Dust" . "Imagination")))
      ;; Assert
      (5am:is (equal "That's perfect!!!" body))
      (5am:is (=  200 status-code))
      (5am:is (equal "text/plain" (a:assoc-value headers :content-type)))
      (5am:is (equal "Prestidigitation" (a:assoc-value headers :magic-dust))))))
