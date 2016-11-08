(defparameter *object-path* "c:/Users/cglooschenko/Documents/automation/geo-project/")
(defparameter *object* "tester")
(defparameter *place* "testerer")
(defparameter *holst-list* '())
(defparameter *ground-list* '())
;;;читаем файл с каталогом координат скважин
(defun read-holst-from-catalog (stream &aux auxi name-holst)
    (when (setq auxi (read-line stream nil))
	(unless (member (set (setq name-holst (gensym)) (symbol-name (car (setq auxi (read-from-string (concatenate 'string "(" auxi ")"))))))
		      *holst-list*
		      :test #'string=
		      :key #'symbol-value)
	    (setq *holst-list* (cons name-holst *holst-list*))
	    (mapcar (function (lambda (slot value)
			  (cond ((not (get name-holst slot)) (setf (get name-holst slot) value)))))
		    '(object plase coordinate ground) (list *object* *place* (cdr auxi) '())))
	(read-holst-from-catalog stream)))
(defun ground-input (input-stream &optional ground))
(defun defined-holst-ground (input-stream holst-var &optional (ground-depth 0.0))
    (terpri)
    (princ (concatenate 'string "From depth " (write-to-string ground-depth) "m" )
    (if )
    (princ " defined-holst not yet")))

;;Функция считывания команды от сервера dc-read-command
(defun dc-read-command (socket)
  (let ((order-char nil)		;В эту переменную будет заноситься символ, прочитанный из потока
	(dc-command nil))		;В этой переменной будет формироваться команда от DC++ хаба
    (setf order-char (read-char socket)) ;Прочитываем первый символ
    (loop while (or (not order-char) (char-not-equal order-char #\space))   ;Повторяем до тех пор, пока не получим order-char равный разделителю "|"
       do (if order-char (progn
			   (setf dc-command (concatenate 'string dc-command
							 (string order-char))))) ;Если order-char не равен nil, то добавим его к dc-command 
	 (setf order-char (read-char socket)) ;Читаем следующий символ
	 (print dc-command)		;Печатаем получившуюся команду
	 (print order-char))		;Печатаем прочитанный символ
	 
    (print dc-command)
    dc-command))			;Возвращаем полную команду
