vows = require 'vows'
assert = require 'assert'
util = require 'util'
facebook = require 'passport-facebook'

vows.describe("passport-facebook").addBatch(

  "should report a version": (x) ->
    assert.isString facebook.version
).export module

