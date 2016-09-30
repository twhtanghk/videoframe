frame = require '../index'
util = require 'util'

process.stdin
  .pipe frame({timestamps: [1], size: '640x480'}), end: false
  .on 'error', (err) ->
    process.stderr.write util.inspect err
  .pipe process.stdout
