autoswagger.lua
===============

This Lua module can learn from a set of "raw" server traces and build a [swagger spec](https://github.com/wordnik/swagger-core/wiki) with them.

It is intelligent enough to deduce common parameters from numbers or ids on the urls.

installation and usage
======================

Copy the `autoswagger` folder inside your app. Then:

    local autoswagger = require 'autoswagger' -- or 'autoswagger.init', depending on your package.path config

    local brain = autoswagger.Brain:new()

    brain:learn('GET', 'google.com', '/users/1/app/5')
    brain:learn('GET', 'google.com', '/users/2/app/4')
    brain:learn('GET', 'google.com', '/users/3/app/3')
    brain:learn('GET', 'google.com', '/users/4/app/2')
    brain:learn('GET', 'google.com', '/users/5/app/1')

    brain.hosts['google.com']:get_swagger()

specs
=====

This project uses [busted](http://olivinelabs.com/busted/) for its specs. Just execute `busted` inside the root of the repo.
