 ;;-*-common-lisp: sbcl -*-
(require 'cl-cffi-gtk)
(in-package :gtk)


 (defun demo-dialog-toplevel (message)
     (let ((response nil))
 	(within-main-loop
 	    (let (;; Create the widgets
 		  (dialog (gtk-dialog-new-with-buttons "Demo Toplevel Dialog"
 						       nil ; No Parent window
 						       '(:modal)
 						       "gtk-ok"
 						       :none
 						       "gtk-cancel"
 						       :cancel))
 		  (label (gtk-label-new message)))
 		;; Signal handler for the dialog to handle the signal "destroy".
 		(g-signal-connect dialog "destroy"
 				  (lambda (widget)
 				      (declare (ignore widget))
				      ;; Quit the main loop and destroy the thread.
 				      (leave-gtk-main)))
 		;; Get the response and destroy the dialog.
 		(g-signal-connect dialog "response"
 				  (lambda (dialog response-id)
				      (declare (ignore response-id))
 				      (setf response response-id)
 				      (gtk-widget-destroy dialog)))
		;; Add the label, and show everything we have added to the dialog.
 		(gtk-container-add (gtk-dialog-get-content-area dialog) label)
 		(gtk-widget-show-all dialog)))
 	;; Wait until the dialog is destroyed.
 	(join-gtk-main)
 	(when response
 	    (format t "The response ID is ~A" response))
	 ))
;;(demo-dialog-toplevel "wqeqweqweqweq")
(defun main ()
    (within-main-loop
	(let ((widget (gtk-window-new :toplevel)))
	   (g-signal-connect widget "destroy"
                        (lambda (widget)
                          (declare (ignore widget))
                          (leave-gtk-main)
                          (if (zerop gtk::*main-thread-level*)
                              (g-application-quit application))))
	    (gtk-widget-show-all widget)))
    (join-gtk-main))
(main)
;;(defun main ()
;;    (within-main-loop
;;	(let ((window (make-instance 'gtk-window :width-request 100 :height-request 100 :visible t)))
;;	    (gtk-widget-show-all widget)))
;;    (join-gtk-main))



