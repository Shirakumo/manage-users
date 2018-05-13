#|
 This file is a part of TyNETv5/Radiance
 (c) 2014 Shirakumo http://tymoon.eu (shinmera@tymoon.eu)
 Author: Nicolas Hafner <shinmera@tymoon.eu>
|#

(in-package #:radiance-user)
(define-module #:manage-users
  (:use #:cl #:radiance))
(in-package #:manage-users)

(define-implement-trigger mail
  (admin:define-panel users email (:access (perm radiance admin users email) :icon "fa-envelope")
    (with-actions (error info)
        ((:send
          (ratify:with-errors-combined
            (dolist (to (post/get "to[]"))
              (r-ratify::with-field-error (to)
                (ratify:perform-test :email to))
              (mail:send to (post/get "subject") (post/get "message"))))
          (setf info "Message sent.")))
      (r-clip:process
       (@template "email.ctml")
       :error error :info info
       :to (or (post/get "email[]")
               (list ""))
       :subject (post/get "subject")
       :message (post/get "message")))))

(admin:define-panel users manage (:access (perm radiance admin users view) :icon "fa-user")
  (r-clip:process
   (plump:parse (@template "manage.ctml"))
   :users (user:list)))

(admin:define-panel users edit (:access (perm radiance admin users edit) :icon "fa-edit")
  (let ((users (if (post/get "username")
                   (list (post/get "username"))
                   (post/get "selected[]")))
        (action (post/get "action"))
        (confirm (post/get "confirm")))
    (if (or users (string-equal action "add"))
        (cond
          ((and (not confirm) (string-equal action "delete"))
           (r-clip:process
            (plump:parse (@template "confirm.ctml"))
            :username (first users)))
          ((and confirm (not (string-equal confirm "yes")))
           (redirect (resource :admin :page "users" "manage")))
          ((string= action "Add")
           (let ((user (user:get (post-var "username") :if-does-not-exist :create))
                 (displayname (post-var "displayname"))
                 (email (post-var "email")))
             (unless (string= email "")
               (setf (user:field "email" user) email))
             (unless (string= displayname "")
               (setf (user:field "displayname" user) displayname)))
           (redirect (resource :admin :page "users" "manage")))
          ((string= action "Save")
           (dolist (user users)
             (loop for field in (user:fields user)
                   for posted = (post-var field)
                   do (when posted (setf (user:field field user) posted))))
           (redirect (resource :admin :page "users" "manage")))
          ((string= action "Delete")
           (dolist (user users)
             (user:remove user))
           (redirect (resource :admin :page "users" "manage")))
          ((string= action "Email")
           (redirect (uri-to-url (resource :admin :page "users" "email")
                                 :representation :external
                                 :query (loop for user in users
                                              collect (cons "email[]" (user:field "email" user))))))
          (T
           (let ((user (first users)))
             (when (string= action "Add")
               (setf (user:field (post-var "key") user) (post-var "val")))
             (r-clip:process
              (plump:parse (@template "edit.ctml"))
              :user (user:get user)
              :fields (user:fields user)))))
        (redirect (resource :admin :page "users" "manage")))))
