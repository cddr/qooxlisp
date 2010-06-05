(in-package :qooxlisp)


(defun serve-apropos ()
  (let ((port 8000))
    
    (when *wserver* (shutdown))
    (qx-reset)
    (net.aserve:start :debug t :port port)
    (flet ((pfl (p f)
             (publish-file :port port
               :path p
               :file f))
           (pdr (p d)
             (publish-directory :port port
               :prefix p
               :destination d))
           (pfn (p fn)
             (publish :path p :function fn)))
      
      (pdr "/qx/" "/devel/qx/")
      (pfn "/begin" 'qx-begin) ;; <=== qx-begin (below) gets customized
      (pfn "/callback" 'qx-callback-js)
      (pfn "/cbjson" 'qx-callback-json)
      
      (let* ((app-root "/devel/qooxlisp/ide") ;; <=== change this to point to your qooxdoo app
             (app-source (format nil "~a/source/" app-root)))
        (flet ((src-ext (x)
                 (format nil "~a~a" app-source x)))
          (pfl "/" (src-ext "index.html"))
          (pdr "/source/" app-source)
          (pdr "/script/" (src-ext "script/")))))))

(defun qx-begin (req ent)
  (ukt::stop-check :qx-begin)
  ;(trace md-awaken make-qx-instance)
  (with-js-response (req ent)
    (print :beginning-request)
    (with-integrity ()
      (qxfmt "
clDict[0] = qx.core.Init.getApplication().getRoot();
sessId=~a;" (session-id  
             ;; this is awkward: it might seem like there is no
             ;; point in assigning to *qxdoc*, but with-integrity 
             ;; runs its form then /with *qxdoc* set/ finishes up 
             ;; the deferred queue where a response gets built.
             ;;
             (setf *qxdoc*
               #+notthis (make-instance 'apropos-session-classic ;; ACL version
                           :theme "qx.theme.Classic")
               (make-instance
                   'apropos-session-makeover ;; kenny's makeover, step one
                 :theme "qx.theme.Modern")
               #+notthis (make-instance
                             'apropos-session-kt ;; kenny's makeover, step one
                           theme "qx.theme.Modern")))))))


(defmd apropos-session (qxl-session)
  (sym-seg (c-in nil))
  (syms-unfiltered (c? (b-when seg (^sym-seg)
                         (symbol-info-raw seg))))
  (syms-filtered (c? (symbol-info-filtered (^syms-unfiltered)
                       (value (fm-other :type-filter))
                       (value (fm-other :exported-only))
                       (not (value (fm-other :all-packages)))
                       (value (fm-other :selected-pkg)))))
  (sym-sort-spec (c-in nil))
  (sym-info (c? (let ((si (^syms-filtered)))
                  (mprt :sym-info-fires)
                  (b-if sort (^sym-sort-spec)
                    (destructuring-bind (sort-key order) sort
                      (sort (copy-list si)
                        (if (equal order "asc")
                            'string-lessp 'string-greaterp)
                        :key (if (equal sort-key "pkg")
                                 (lambda (si) (package-name (symbol-info-pkg si)))
                               (qxl-sym (conc$ 'symbol-info- sort-key)))))
                    si)))))

(defobserver sym-info ()
  (mprt :sym-info-observer-fires)
  (with-integrity (:client `(:post-make-qx ,self))
    (mprt :sym-info-observer-runs (fm-other :sym-info-table) (oid (table-model (fm-other :sym-info-table))))
    (let ((tbl (fm-other :sym-info-table)))
      (assert tbl)
      (b-when oid (oid (table-model tbl))
        (qxfmt "clDict[~a].reloadData();" oid)))))