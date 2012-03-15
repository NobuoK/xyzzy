;;; -*- mode:lisp; package:makelc -*-
;;;
;;; ### usage
;;;
;;; - M-x makelc --- compiler�p�b�P�[�W��lisp�p�b�P�[�W�̊֐����R���p�C����A~/lisp�t�H���_�ȉ���*.l���ăR���p�C��
;;; - (makelc:compile-files dirname) --- �w��f�B���N�g���ȉ���*.l���ăR���p�C��
;;; - (makelc:compile-package :packagename) --- �w��p�b�P�[�W���Œ�`����Ă��関�R���p�C���̊֐����R���p�C��

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "compile"))

(defpackage :makelc
  (:use :lisp :ed))

(in-package :makelc)
(export '(compile-package
	  compile-files))

(defmacro time (form)
  `(let ((start (get-internal-real-time))
	 (result (multiple-value-list ,form)))
     (format t "~&~V@{-~}~%~D msec~%~%" 30 (- (get-internal-real-time) start))
     (values-list result)))

(defun not-compiled-functions (pkg)
  (let ((fns nil)
	(p (find-package pkg)))
    (do-symbols (s p)
      (when (and (fboundp s)
		 (not (macro-function s))
		 (eq p (symbol-package s)))
	(let ((f (symbol-function s)))
	  (when (not (or (si:*builtin-function-p f)
			 (compiled-function-p f)
			 (not (functionp f))
			 (and (si:*closurep f)
			      (si:closure-variable f))))
	    (push s fns)))))
    (nreverse fns)))

(defun compile-package (pkg)
  (format t "compiling <~A> ...~%" pkg)
  (time
   (dolist (f (not-compiled-functions pkg))
     (format t "~A ..." f)
     (goto-char (point-max))
     (refresh-screen)
     (handler-case
	 (progn
	   (compile f)
	   (princ "ok"))
       (error (c)
	 (format t "error~%*****~%~A~%*****"
		 (si:*condition-string c))))
     (terpri))))

(defun compile-files (&optional (dir "~/lisp"))
  (let ((files (directory dir :absolute t :wild "*.l" :recursive t)))
    (time
     (dolist (f files)
       (compile-file f)
       (goto-char (point-max))
       (refresh-screen)))))

(defun user::makelc ()
  (interactive)
  (let ((buf (create-new-buffer "*compile log*")))
    (set-buffer buf)
    (setup-temp-buffer buf)
    (with-output-to-buffer (buf)
      (compile-package :compiler)
      (compile-package :lisp)
      (compile-files "~/lisp")
      (when (file-exist-p #0="~/xyzzy.wxp")
	(delete-file #0#)))))