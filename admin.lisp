#|
 This file is a part of TyNETv5/Radiance
 (c) 2014 Shirakumo http://tymoon.eu (shinmera@tymoon.eu)
 Author: Nicolas Hafner <shinmera@tymoon.eu>
|#

(in-package #:radiance-user)
(define-module #:manage-users
  (:use #:cl #:radiance))
(in-package #:manage-users)

(admin:define-panel users manage (:access (perm radiance admin users view) :icon "fa-user")
  (r-clip:process
   (plump:parse (@template "manage.ctml"))
   :users (user:list)))

(admin:define-panel users edit (:access (perm radiance admin users edit) :icon "fa-edit")
  (let* ((username (post/get "username"))
         (user (user:get username))
         (action (post/get "action"))
         (confirm (post/get "confirm")))
    (if (or user (string-equal action "add"))
        (cond
          ((and (not confirm) (string-equal action "delete"))
           (r-clip:process
            (plump:parse (@template "confirm.ctml"))
            :username username))
          ((and confirm (not (string-equal confirm "yes")))
           (redirect "/users/manage"))
          ((string= action "Add")
           (let ((user (user:get (post-var "username") :if-does-not-exist :create))
                 (displayname (post-var "displayname"))
                 (email (post-var "email")))
             (unless (string= email "")
               (setf (user:field "email" user) email))
             (unless (string= displayname "")
               (setf (user:field "displayname" user) displayname)))
           (redirect "/users/manage"))
          ((string= action "Save")
           (loop for field in (user:fields user)
                 do (setf (user:field field user) (post-var field)))
           (redirect "/users/manage"))
          ((string= action "Delete")
           (user:remove user)
           (redirect "/users/manage"))
          (T
           (when (string= action "Add")
             (setf (user:field (post-var "key") user) (post-var "val")))           
           (r-clip:process
            (plump:parse (@template "edit.ctml"))
            :user user
            :fields (user:fields user))))
        (redirect "/users/manage"))))
