(defpackage #:org.tymoonnext.manage-users.asdf
  (:use #:cl #:asdf))
(in-package #:org.tymoonnext.manage-users.asdf)

(defsystem manage-users
  :defsystem-depends-on (:radiance)
  :class "radiance:virtual-module"
  :name "manage-users"
  :version "0.5.1"
  :license "zlib"
  :author "Yukari Hafner <shinmera@tymoon.eu>"
  :maintainer "Yukari Hafner <shinmera@tymoon.eu>"
  :description "Radiance administration interface to allow user management."
  :serial T
  :components ((:file "admin"))
  :depends-on ((:interface :user)
               (:interface :admin)
               :r-clip))
