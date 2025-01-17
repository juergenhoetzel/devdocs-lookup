;;; devdocs-lookup.el --- jump to documentation on devdocs.io -*- lexical-binding: t; -*-

;; This is free and unencumbered software released into the public domain.

;; Author: Christopher Wellons <wellons@nullprogram.com>
;; URL: https://github.com/skeeto/devdocs-lookup

;;; Commentary:

;; This package provides an interactive function `devdocs-lookup' to
;; quickly jump to documentation on a particular API at devdocs.io
;; with your browser.

;; https://devdocs.io/

;; Currently supported subjects:

;; Angular.js, Apache HTTP Server, Backbone.js, Bower, C, Chai,
;; Clojure, CoffeeScript, Cordova, C++, CSS, D3.js, Django, Dojo, DOM,
;; DOM Events, Drupal, Elixir, Ember.js, Express, Flow, Git, Go,
;; Grunt, Haskell, HTML, HTTP, io.js, JavaScript, jQuery, jQuery
;; Mobile, jQuery UI, Knockout.js, Laravel, Less, lodash, Lua,
;; Marionette.js, Markdown, Meteor, Ruby / Minitest, mocha, Modernizr,
;; Moment.js, Mongoose, nginx, Node.js, Node.js (LTS), Nokogiri, npm,
;; OpenTSDB, Phalcon, Phaser, Phoenix, PHP, PHPUnit, PostgreSQL,
;; Python, Q, Ruby on Rails, React, React Native, Redis, Relay,
;; RequireJS, RethinkDB, Ruby, Rust, Sass, Sinon, Socket.IO, SVG,
;; Symfony, Underscore.js, Vagrant, Vue.js, webpack, XPath, Yii.

;; To bypass indicating the subject on each lookup, devdocs-lookup can
;; generate interactive commands for each of the individual subjects
;; by calling `devdocs-setup'.

;; (devdocs-setup)
;; (global-set-key (kbd "C-h C-c") #'devdocs-lookup-c)
;; (global-set-key (kbd "C-h C-p") #'devdocs-lookup-python)

;;; Code:

(require 'url)
(require 'json)
(require 'cl-lib)

(defvar devdocs-base-url "https://devdocs.io"
  "Base url for devdocs.io.")

(defvar devdocs-base-index-url "https://documents.devdocs.io"
  "Base url for devdocs.io.")

(defvar devdocs-subjects
  '(("Angular 2" "angular~2")
    ("Angular 4" "angular~4")
    ("Angular 5" "angular~5")
    ("Angular" "angular")
    ("Angular.js 1.2" "angularjs~1.2")
    ("Angular.js 1.3" "angularjs~1.3")
    ("Angular.js 1.4" "angularjs~1.4")
    ("Angular.js 1.5" "angularjs~1.5")
    ("Angular.js 1.6" "angularjs~1.6")
    ("Angular.js" "angularjs~1.6")
    ("Ansible 2.4" "ansible~2.4")
    ("Ansible 2.5" "ansible~2.5")
    ("Ansible 2.6" "ansible~2.6")
    ("Ansible 2.7" "ansible~2.7")
    ("Ansible" "ansible~2.7")
    ("Apache HTTP Server" "apache_http_server")
    ("Apache Pig 0.13" "apache_pig~0.13")
    ("Apache Pig 0.14" "apache_pig~0.14")
    ("Apache Pig 0.15" "apache_pig~0.15")
    ("Apache Pig 0.16" "apache_pig~0.16")
    ("Apache Pig 0.17" "apache_pig~0.17")
    ("Apache Pig" "apache_pig~0.17")
    ("Async" "async")
    ("Babel" "babel")
    ("Backbone.js" "backbone")
    ("Bash" "bash")
    ("Bluebird" "bluebird")
    ("Bootstrap 3" "bootstrap~3")
    ("Bootstrap 4" "bootstrap~4")
    ("Bootstrap" "bootstrap~4")
    ("Bottle 0.11" "bottle~0.11")
    ("Bottle 0.12" "bottle~0.12")
    ("Bottle" "bottle~0.12")
    ("Bower" "bower")
    ("C" "c")
    ("C++" "cpp")
    ("CMake 3.10" "cmake~3.10")
    ("CMake 3.11" "cmake~3.11")
    ("CMake 3.12" "cmake~3.12")
    ("CMake 3.5" "cmake~3.5")
    ("CMake 3.6" "cmake~3.6")
    ("CMake 3.7" "cmake~3.7")
    ("CMake 3.8" "cmake~3.8")
    ("CMake 3.9" "cmake~3.9")
    ("CMake" "cmake~3.12")
    ("CSS" "css")
    ("CakePHP 2.10" "cakephp~2.10")
    ("CakePHP 2.7" "cakephp~2.7")
    ("CakePHP 2.8" "cakephp~2.8")
    ("CakePHP 2.9" "cakephp~2.9")
    ("CakePHP 3.1" "cakephp~3.1")
    ("CakePHP 3.2" "cakephp~3.2")
    ("CakePHP 3.3" "cakephp~3.3")
    ("CakePHP 3.4" "cakephp~3.4")
    ("CakePHP 3.5" "cakephp~3.5")
    ("CakePHP 3.6" "cakephp~3.6")
    ("CakePHP" "cakephp~3.6")
    ("Chai" "chai")
    ("Chef 11" "chef~11")
    ("Chef 12" "chef~12")
    ("Chef" "chef~12")
    ("Clojure 1.7" "clojure~1.7")
    ("Clojure 1.8" "clojure~1.8")
    ("Clojure 1.9" "clojure~1.9")
    ("Clojure" "clojure~1.9")
    ("CodeIgniter 3" "codeigniter~3")
    ("CodeIgniter" "codeigniter~3")
    ("CodeceptJS" "codeceptjs")
    ("Codeception" "codeception")
    ("CoffeeScript 1" "coffeescript~1")
    ("CoffeeScript 2" "coffeescript~2")
    ("CoffeeScript" "coffeescript~2")
    ("Cordova 6" "cordova~6")
    ("Cordova 7" "cordova~7")
    ("Cordova 8" "cordova~8")
    ("Cordova" "cordova~8")
    ("Crystal" "crystal")
    ("D" "d")
    ("D3.js 3" "d3~3")
    ("D3.js 4" "d3~4")
    ("D3.js 5" "d3~5")
    ("D3.js" "d3~5")
    ("DOM Events" "dom_events")
    ("DOM" "dom")
    ("Dart 1" "dart~1")
    ("Dart 2" "dart~2")
    ("Dart" "dart~2")
    ("Django 1.10" "django~1.10")
    ("Django 1.11" "django~1.11")
    ("Django 1.8" "django~1.8")
    ("Django 1.9" "django~1.9")
    ("Django 2.0" "django~2.0")
    ("Django 2.1" "django~2.1")
    ("Django" "django~2.1")
    ("Docker 1.10" "docker~1.10")
    ("Docker 1.11" "docker~1.11")
    ("Docker 1.12" "docker~1.12")
    ("Docker 1.13" "docker~1.13")
    ("Docker 17" "docker~17")
    ("Docker" "docker~17")
    ("Dojo" "dojo")
    ("Drupal 7" "drupal~7")
    ("Drupal 8" "drupal~8")
    ("Drupal" "drupal~8")
    ("ESLint" "eslint")
    ("Electron" "electron")
    ("Elixir 1.3" "elixir~1.3")
    ("Elixir 1.4" "elixir~1.4")
    ("Elixir 1.5" "elixir~1.5")
    ("Elixir 1.6" "elixir~1.6")
    ("Elixir 1.7" "elixir~1.7")
    ("Elixir" "elixir~1.7")
    ("Ember.js" "ember")
    ("Erlang 18" "erlang~18")
    ("Erlang 19" "erlang~19")
    ("Erlang 20" "erlang~20")
    ("Erlang 21" "erlang~21")
    ("Erlang" "erlang~21")
    ("Express" "express")
    ("Falcon 1.2" "falcon~1.2")
    ("Falcon 1.3" "falcon~1.3")
    ("Falcon 1.4" "falcon~1.4")
    ("Falcon" "falcon~1.4")
    ("Fish 2.2" "fish~2.2")
    ("Fish 2.3" "fish~2.3")
    ("Fish 2.4" "fish~2.4")
    ("Fish 2.5" "fish~2.5")
    ("Fish 2.6" "fish~2.6")
    ("Fish 2.7" "fish~2.7")
    ("Fish" "fish~2.7")
    ("Flow" "flow")
    ("GCC 4 CPP" "gcc~4_cpp")
    ("GCC 4" "gcc~4")
    ("GCC 5 CPP" "gcc~5_cpp")
    ("GCC 5" "gcc~5")
    ("GCC 6 CPP" "gcc~6_cpp")
    ("GCC 6" "gcc~6")
    ("GCC 7 CPP" "gcc~7_cpp")
    ("GCC 7" "gcc~7")
    ("GCC" "gcc~7")
    ("GNU Fortran 4" "gnu_fortran~4")
    ("GNU Fortran 5" "gnu_fortran~5")
    ("GNU Fortran 6" "gnu_fortran~6")
    ("GNU Fortran 7" "gnu_fortran~7")
    ("GNU Fortran" "gnu_fortran~7")
    ("Git" "git")
    ("Go" "go")
    ("Godot 2.1" "godot~2.1")
    ("Godot 3.0" "godot~3.0")
    ("Godot" "godot~3.0")
    ("Graphite" "graphite")
    ("Grunt" "grunt")
    ("HTML" "html")
    ("HTTP" "http")
    ("Handlebars.js" "handlebars")
    ("Haskell 7" "haskell~7")
    ("Haskell 8" "haskell~8")
    ("Haskell" "haskell~8")
    ("Haxe C#" "haxe~cs")
    ("Haxe C++" "haxe~cpp")
    ("Haxe Flash" "haxe~flash")
    ("Haxe HashLink" "haxe~hashlink")
    ("Haxe Java" "haxe~java")
    ("Haxe JavaScript" "haxe~javascript")
    ("Haxe Lua" "haxe~lua")
    ("Haxe Neko" "haxe~neko")
    ("Haxe PHP" "haxe~php")
    ("Haxe Python" "haxe~python")
    ("Haxe Sys" "haxe~sys")
    ("Haxe" "haxe")
    ("Homebrew" "homebrew")
    ("Immutable.js" "immutable")
    ("InfluxData" "influxdata")
    ("JSDoc" "jsdoc")
    ("Jasmine" "jasmine")
    ("JavaScript" "javascript")
    ("Jekyll" "jekyll")
    ("Jest" "jest")
    ("Julia 0.5" "julia~0.5")
    ("Julia 0.6" "julia~0.6")
    ("Julia 0.7" "julia~0.7")
    ("Julia 1.0" "julia~1.0")
    ("Julia" "julia~1.0")
    ("Knockout.js" "knockout")
    ("Koa" "koa")
    ("Kotlin" "kotlin")
    ("Laravel 4.2" "laravel~4.2")
    ("Laravel 5.1" "laravel~5.1")
    ("Laravel 5.2" "laravel~5.2")
    ("Laravel 5.3" "laravel~5.3")
    ("Laravel 5.4" "laravel~5.4")
    ("Laravel 5.5" "laravel~5.5")
    ("Laravel 5.6" "laravel~5.6")
    ("Laravel 5.7" "laravel~5.7")
    ("Laravel" "laravel~5.7")
    ("Leaflet 1.0" "leaflet~1.0")
    ("Leaflet 1.1" "leaflet~1.1")
    ("Leaflet 1.2" "leaflet~1.2")
    ("Leaflet 1.3" "leaflet~1.3")
    ("Leaflet" "leaflet~1.3")
    ("Less" "less")
    ("Liquid" "liquid")
    ("Lua 5.1" "lua~5.1")
    ("Lua 5.2" "lua~5.2")
    ("Lua 5.3" "lua~5.3")
    ("Lua" "lua~5.3")
    ("LÖVE" "love")
    ("Marionette.js 2" "marionette~2")
    ("Marionette.js 3" "marionette~3")
    ("Marionette.js 4" "marionette~4")
    ("Marionette.js" "marionette~4")
    ("Markdown" "markdown")
    ("Matplotlib 1.5" "matplotlib~1.5")
    ("Matplotlib 2.0" "matplotlib~2.0")
    ("Matplotlib 2.1" "matplotlib~2.1")
    ("Matplotlib 2.2" "matplotlib~2.2")
    ("Matplotlib 3.0" "matplotlib~3.0")
    ("Matplotlib" "matplotlib~3.0")
    ("Meteor 1.3" "meteor~1.3")
    ("Meteor 1.4" "meteor~1.4")
    ("Meteor 1.5" "meteor~1.5")
    ("Meteor" "meteor~1.5")
    ("Mocha" "mocha")
    ("Modernizr" "modernizr")
    ("Moment.js" "moment")
    ("Mongoose" "mongoose")
    ("Nim" "nim")
    ("Node.js 10 LTS" "node~10_lts")
    ("Node.js 4 LTS" "node~4_lts")
    ("Node.js 6 LTS" "node~6_lts")
    ("Node.js 8 LTS" "node~8_lts")
    ("Node.js" "node")
    ("Nokogiri" "nokogiri")
    ("NumPy 1.10" "numpy~1.10")
    ("NumPy 1.11" "numpy~1.11")
    ("NumPy 1.12" "numpy~1.12")
    ("NumPy 1.13" "numpy~1.13")
    ("NumPy 1.14" "numpy~1.14")
    ("NumPy" "numpy~1.14")
    ("OpenJDK 8 GUI" "openjdk~8_gui")
    ("OpenJDK 8 Web" "openjdk~8_web")
    ("OpenJDK 8" "openjdk~8")
    ("OpenJDK" "openjdk~8")
    ("OpenTSDB" "opentsdb")
    ("PHP" "php")
    ("PHPUnit 4" "phpunit~4")
    ("PHPUnit 5" "phpunit~5")
    ("PHPUnit 6" "phpunit~6")
    ("PHPUnit" "phpunit~6")
    ("Padrino" "padrino")
    ("Perl 5.20" "perl~5.20")
    ("Perl 5.22" "perl~5.22")
    ("Perl 5.24" "perl~5.24")
    ("Perl 5.26" "perl~5.26")
    ("Perl" "perl~5.26")
    ("Phalcon 2" "phalcon~2")
    ("Phalcon 3" "phalcon~3")
    ("Phalcon" "phalcon~3")
    ("Phaser" "phaser")
    ("Phoenix" "phoenix")
    ("PostgreSQL 11" "postgresql~11")
    ("PostgreSQL 10" "postgresql~10")
    ("PostgreSQL 9.4" "postgresql~9.4")
    ("PostgreSQL 9.5" "postgresql~9.5")
    ("PostgreSQL 9.6" "postgresql~9.6")
    ("PostgreSQL" "postgresql~11")
    ("Pug" "pug")
    ("Puppeteer" "puppeteer")
    ("Pygame" "pygame")
    ("Python 2.7" "python~2.7")
    ("Python 3.5" "python~3.5")
    ("Python 3.6" "python~3.6")
    ("Python 3.7" "python~3.7")
    ("Python" "python~3.7")
    ("Q" "q")
    ("Qt 5.11" "qt~5.11")
    ("Qt 5.6" "qt~5.6")
    ("Qt 5.9" "qt~5.9")
    ("Qt" "qt~5.11")
    ("Ramda" "ramda")
    ("React" "react")
    ("ReactNative" "react_native")
    ("Redis" "redis")
    ("Redux" "redux")
    ("Relay" "relay")
    ("RequireJS" "requirejs")
    ("RethinkDB Java" "rethinkdb~java")
    ("RethinkDB JavaScript" "rethinkdb~javascript")
    ("RethinkDB Python" "rethinkdb~python")
    ("RethinkDB Ruby" "rethinkdb~ruby")
    ("RethinkDB" "rethinkdb~javascript")
    ("Ruby / Minitest" "minitest")
    ("Ruby 2.2" "ruby~2.2")
    ("Ruby 2.3" "ruby~2.3")
    ("Ruby 2.4" "ruby~2.4")
    ("Ruby 2.5" "ruby~2.5")
    ("Ruby 2.6" "ruby~2.6")
    ("Ruby on Rails 4.1" "rails~4.1")
    ("Ruby on Rails 4.2" "rails~4.2")
    ("Ruby on Rails 5.0" "rails~5.0")
    ("Ruby on Rails 5.1" "rails~5.1")
    ("Ruby on Rails 5.2" "rails~5.2")
    ("Ruby on Rails" "rails~5.2")
    ("Ruby" "ruby~2.5")
    ("Rust" "rust")
    ("SQLite" "sqlite")
    ("SVG" "svg")
    ("Sass" "sass")
    ("Sinon.JS 1" "sinon~1")
    ("Sinon.JS 2" "sinon~2")
    ("Sinon.JS 3" "sinon~3")
    ("Sinon.JS 4" "sinon~4")
    ("Sinon.JS 5" "sinon~5")
    ("Sinon.JS 6" "sinon~6")
    ("Sinon.JS 7" "sinon~7")
    ("Sinon.JS" "sinon~7")
    ("Socket.IO" "socketio")
    ("Statsmodels" "statsmodels")
    ("Support Tables" "browser_support_tables")
    ("Symfony 2.7" "symfony~2.7")
    ("Symfony 2.8" "symfony~2.8")
    ("Symfony 3.0" "symfony~3.0")
    ("Symfony 3.1" "symfony~3.1")
    ("Symfony 3.2" "symfony~3.2")
    ("Symfony 3.3" "symfony~3.3")
    ("Symfony 3.4" "symfony~3.4")
    ("Symfony 4.0" "symfony~4.0")
    ("Symfony 4.1" "symfony~4.1")
    ("Symfony" "symfony~4.1")
    ("Tcl/Tk" "tcl_tk")
    ("TensorFlow C++" "tensorflow~cpp")
    ("TensorFlow Guide" "tensorflow~guide")
    ("TensorFlow Python" "tensorflow~python")
    ("TensorFlow" "tensorflow~python")
    ("Terraform" "terraform")
    ("Twig 1" "twig~1")
    ("Twig 2" "twig~2")
    ("Twig" "twig~2")
    ("TypeScript" "typescript")
    ("Underscore.js" "underscore")
    ("Vagrant" "vagrant")
    ("Vue.js 1" "vue~1")
    ("Vue.js 2" "vue~2")
    ("Vue.js" "vue~2")
    ("Vulkan" "vulkan")
    ("XSLT & XPath" "xslt_xpath")
    ("Yarn" "yarn")
    ("Yii 1.1" "yii~1.1")
    ("Yii 2.0" "yii~2.0")
    ("Yii" "yii~2.0")
    ("jQuery Mobile" "jquerymobile")
    ("jQuery UI" "jqueryui")
    ("jQuery" "jquery")
    ("lodash 2" "lodash~2")
    ("lodash 3" "lodash~3")
    ("lodash 4" "lodash~4")
    ("lodash" "lodash~4")
    ("nginx / Lua Module" "nginx_lua_module")
    ("nginx" "nginx")
    ("npm" "npm")
    ("pandas 0.18" "pandas~0.18")
    ("pandas 0.19" "pandas~0.19")
    ("pandas 0.20" "pandas~0.20")
    ("pandas 0.21" "pandas~0.21")
    ("pandas 0.22" "pandas~0.22")
    ("pandas 0.23" "pandas~0.23")
    ("pandas" "pandas~0.23")
    ("scikit-image" "scikit_image")
    ("scikit-learn" "scikit_learn")
    ("webpack 1" "webpack~1")
    ("webpack" "webpack"))
  "List of subjects supported by devdocs.io.")

(defvar-local devdocs--default-subject nil
  "Remembers the subject for the given buffer.")

(defvar devdocs-index (make-hash-table :test 'equal)
  "Hash table for indexes for various subjects.")

(defun devdocs-index (subject &optional callback)
  "Return the devdocs.io index for SUBJECT, optionally async via CALLBACK."
  (cl-declare (special url-http-end-of-headers))
  (let ((index (gethash subject devdocs-index))
        (url (format "%s/%s/index.json" devdocs-base-index-url subject)))
    (cond ((and index callback)
           (funcall callback index))
          ((and index (not callback))
           index)
          ((and (not index) (not callback))
           (with-current-buffer (url-retrieve-synchronously url nil t)
             (goto-char url-http-end-of-headers)
             (setf (gethash subject devdocs-index) (json-read))))
          ((and (not index) callback)
           (url-retrieve
            url
            (lambda (_)
              (goto-char url-http-end-of-headers)
              (setf (gethash subject devdocs-index) (json-read))
              (funcall callback (gethash subject devdocs-index))))))))

(defun devdocs-entries (subject)
  "Return an association list of the entries in SUBJECT."
  (cl-loop for entry across (cdr (assoc 'entries (devdocs-index subject)))
           collect (cons (cdr (assoc 'name entry))
                         (cdr (assoc 'path entry)))))

(defvar devdoc--hist-subjects nil)

(defun devdocs-read-subject ()
  "Interactively ask the user for a subject."
  (let* ((subjects (mapcar #'car devdocs-subjects))
         (hist 'devdoc--hist-subjects)
         (subject (completing-read "Subject: " subjects nil t nil hist)))
    (cadr (assoc subject devdocs-subjects))))

(defun devdocs--best-match (string names)
  "Return the best match for STRING in NAMES, if any.
An exact match takes the highest priority, then a partial match
on symbol boundaries, then any partial match. Matches are
case-sensitive."
  (let* ((best-match nil)
         (best-score 0)
         (case-fold-search nil)
         (re-float (regexp-quote string))
         (re-symbol (concat "\\_<" re-float "\\_>")))
    (dolist (name names)
      (cond
       ;; Exact match
       ((and (< best-score 100)
             (string= string name))
        (setf best-match name
              best-score 100))
       ;; Symbol-boundary match
       ((and (< best-score 80)
             (string-match-p re-symbol name))
        (setf best-match name
              best-score 80))
       ;; Loose match
       ((and (< best-score 60)
             (let ((case-fold-search t))
               (string-match-p re-float name)))
        (setf best-match name
              best-score 60))))
    best-match))

(defun devdocs-read-entry (subject)
  "Interactively ask the user for an entry in SUBJECT."
  (let* ((names (mapcar #'car (devdocs-entries subject)))
         (hist (intern (format "devdocs--hist-%s" subject)))
         (symbol (symbol-at-point))
         (best-match
          (and symbol (devdocs--best-match (symbol-name symbol) names)))
         (prompt (if best-match
                     (format "Entry (%s) [%s]: " best-match subject)
                   (format "Entry [%s]: " subject))))
    (completing-read prompt names nil :require-match nil hist best-match)))

;;;###autoload
(defun devdocs-lookup (subject entry)
  "Visit the documentation for ENTRY from SUBJECT in a browser."
  (interactive
   ;; Try to guess the subject from the major mode.
   (let* ((case-fold-search t)
          (major-mode-string
           (replace-regexp-in-string "-mode$" "" (symbol-name major-mode)))
          (subject-dwim (cadr (cl-assoc major-mode-string devdocs-subjects
                                        :test #'string-match-p)))
          (subject (if current-prefix-arg
                       (devdocs-read-subject)
                     (or devdocs--default-subject
                         subject-dwim
                         (devdocs-read-subject))))
          (entry (devdocs-read-entry subject)))
     (when subject
       (setf devdocs--default-subject subject))
     (list subject entry)))
  (let ((path (cdr (assoc entry (devdocs-entries subject)))))
    (when path
      (browse-url (format "%s/%s/%s" devdocs-base-url subject path))
      :found)))

;;;###autoload
(defun devdocs-setup ()
  "Generate an interactive command for each subject (`devdocs-subjects')."
  (dolist (pair devdocs-subjects)
    (cl-destructuring-bind (name subject) pair
      (let ((symbol (intern (format "devdocs-lookup-%s" subject))))
        (defalias symbol
          (lambda ()
            (interactive)
            (devdocs-lookup subject (devdocs-read-entry subject)))
          (format "Look up documentation for %s on devdocs.io." name))))))

(provide 'devdocs-lookup)

;;; devdocs-lookup.el ends here
