;;(read-char *terminal-io* nil nil t)
;;(princ (peek-char nil *terminal-io*))
;;(princ (read-char-no-hang *terminal-io*))
;;(princ (read-delimited-list #\space *terminal-io*))
;;Функция считывания команды от сервера dc-read-command
(defun aiku-cheme-translate (input)
    (let ((one-char nil)
	  (out-char nil))
	(princ "sda ")
	(with-open-stream (inp input) (setq one-char (read inp t #\newline)))))
(aiku-cheme-translate (make-two-way-stream *standard-input* *standard-output*))
