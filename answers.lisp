(in-package #:the-great-rouclere)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Answers

(defvar *answer*)

(defmacro answer ((code) &body body)
  `(cond ((not (boundp '*expectation*))
          (error "The Great Rouclere cannot answer if there is no expectation!"))
         ((boundp '*answer*)
          (error "The Great Rouclere is already preparing an answer! ~S"
                 *answer*))
         (t
          (let ((*answer* (list :code ,code)))
            (multiple-value-prog1 ,@body
              (setf *expectation* (list* :answer *answer* *expectation*)))))))

(defgeneric add-to-answer (key data answer)
  (:method ((key (eql :header)) data answer)
    (destructuring-bind (header value) data
      (a:when-let ((actual (a:assoc-value (getf answer :headers) header :test #'equal)))
        (error "The Great Rouclere will already respond with header ~S as ~S!"
               header actual))
      (push (cons header value) (getf answer :headers))
      answer))
  (:method ((key (eql :content-type)) data answer)
    (destructuring-bind (value) data
      (add-to-answer :header (list "Content-Type" value) answer)))
  (:method ((key (eql :side-effects)) data answer)
    (destructuring-bind (function) data
      (push function (getf answer :side-effects))
      answer))
  (:method ((key (eql :body)) data answer)
    (destructuring-bind (value) data
      (a:when-let ((actual (getf answer :body)))
        (error "The Great Rouclere will already respond with body ~S!" actual))
      (setf (getf answer :body) value)
      answer)))
