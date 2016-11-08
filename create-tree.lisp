;-*-mode: Lisp; coding: cp1251;-*-

;;���������� � ����� ������� �����
;;��� ����� ��� ����, ������� ������� � �� ����� ������� ����������
;;��� ������� ������
;;���� ����� 
(setq *print-circle* t)

(defparameter +cmd-chema+
  '(("" "" "���������: "
    ("�" "����" ". �������������? [�� ���]: " ("�" "�" "" . wm-close) ("�" "��" "" . -1))
    ("�" "�����" "" . wm-open-object))))

(defun create-tree (tree-list &aux (tail-list (if (listp (car tree-list)) tree-list (cdddr tree-list))) auxi)
    (declare (optimize (debug 3) (safety 3) (space 0) (speed 0)))
    (format *debug-io* "tail-list: ~s~%" tail-list)
    (cond ((numberp tail-list) (list (+ 1 tail-list) tail-list tree-list))
	  ((consp tail-list)
	   (create-tree (cdr tail-list))
	   (setq auxi (create-tree (car tail-list)))
	   (format *debug-io* "before auxi: ~s~%" auxi)
	   (cond ((symbolp auxi) auxi)
		 ((plusp (car auxi)) (nsubst tree-list (cadr auxi) (abs (cddr auxi))))
		 (t (rplaca auxi (1+ (car auxi))) auxi))
	   (format *debug-io* "after auxi: ~s~%" auxi)
	   auxi)))

(create-tree +cmd-chema+)


