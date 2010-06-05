(eval-when (compile load eval)
  (require :aserve)
  (require :webactions)
  (require :pxml)
  )

(defpackage #:qooxlisp
  (:nicknames :qxl)
  (:use #:cells #:utils-kt #:cl #:excl #:net.aserve)
  (:export #:*qxdoc* #:oid
    #:k-word #:whtml #:req-val
    #:with-plain-text-response
    #:with-html-response #:qxl-request-session
    #:with-js-response #:mk-layout
    #:with-json-response #:table-model
    #:json$ #:jsk$ #:cvtjs #:session-id
    #:qxl-session #:qx-callback #:qx-select-box
    #:qx-composite #:qx-table-model-remote
    #:qx-combo-box #:qx-table #:qx-grid #:qx-radio-button-group #:qx-radio-button
    #:qx-button #:qx-label #:label #:button #:qx-html #:qx-html-math
    #:qx-hbox #:qx-vbox #:qx-list-item #:qx-check-box #:combobox
    #:qxfmt #:qx-reset #:vbox #:hbox #:lbl #:radiobuttongroup #:radiobutton #:checkbox
    #:groupbox #:checkgroupbox #:radiogroupbox #:selectbox))

#+adhoc
(unintern 'mathx::qx-html-math :mathx)



