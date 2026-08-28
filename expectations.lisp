(in-package #:the-great-rouclere)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Expectations

;; Assures that all EXPECT blocks and all request handlers don't conflict.
(defvar *expectations-lock* (bt:make-lock "The Great Rouclere expectations lock"))

(defvar *expectation*)

(defmacro expect ((method url &key (times 1)) &body body)
  `(if (boundp '*expectation*)
       (error "The Great Rouclere is already listening to your expectation! ~S"
              *expectation*)
       (let ((*expectation* (list :method ,method :url ,url :times ,times)))
         (bt:with-lock-held (*expectations-lock*)
           (multiple-value-prog1 ,@body
             (a:nconcf (expectations *port*) (list *expectation*)))))))

(defgeneric add-to-expectation (key data expectation)
  (:method ((key (eql :header)) data expectation)
    (destructuring-bind (header value) data
      (a:when-let ((actual (a:assoc-value (getf expectation :headers) header :test #'equal)))
        (error "The Great Rouclere will already expect header ~S as ~S!"
               header actual))
      (push (cons header value) (getf expectation :headers))
      expectation))
  (:method ((key (eql :basic-authorization)) data expectation)
    (destructuring-bind (username password) data
      (flet ((base64-encode (string)
               (base64:usb8-array-to-base64-string
                (babel:string-to-octets string :encoding (babel:make-external-format :utf-8)))))
        (let ((value (base64-encode (format nil "~A:~A" username password))))
          (add-to-expectation :header (list "Authorization" (format nil "Basic ~A" value))
                              expectation)))))
  (:method ((key (eql :accept)) data expectation)
    (add-to-expectation :header (cons "Accept" data) expectation))
  (:method ((key (eql :predicate)) data expectation)
    (destructuring-bind (function) data
      (push function (getf expectation :predicates))
      expectation))
  (:method ((key (eql :body)) data expectation)
    (destructuring-bind (value) data
      (a:when-let ((actual (getf expectation :body)))
        (error "The Great Rouclere will already expect body ~S!" actual))
      (setf (getf expectation :body) value)
      expectation)))
