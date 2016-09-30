Promise = require 'bluebird'
stream = require 'stream'
ffmpeg = require 'fluent-ffmpeg'
uuid = require 'node-uuid'
fs = require 'fs'
path = require 'path'
_ = require 'lodash'

module.exports = (opts = {timestamps: [0], size: '320x240'})->

  class Frame extends stream.Transform
    @folder: '/tmp'

    path: ->
      "#{Frame.folder}/#{uuid.v1()}"

    video: =>
      new Promise (resolve, reject) =>
        @on 'pipe', (src) =>
          src
            .on 'error', reject
            .pipe fs.createWriteStream @file.video
            .on 'error', reject
            .on 'finish', resolve

    png: =>
      new Promise (resolve, reject) =>
        ffmpeg @file.video
          .on 'error', reject
          .on 'end', ->
            resolve()
          .screenshots _.defaults opts,
            filename: path.basename @file.png
            folder: Frame.folder
          .on 'error', reject

    constructor: (opts) ->
      super opts
      @file =
        video: "#{@path()}.video"
        png: "#{@path()}.png"
      @video()
        .then @png
        .then =>
          new Promise (resolve, reject) =>
            fs.createReadStream @file.png
              .on 'data', (chunk) =>
                @push chunk
              .on 'end', =>
                @end()
                resolve()
        .catch (err) =>
          @emit 'error', err
        .finally =>
          rm = Promise.promisify fs.unlink
          rm @file.video
            .catch ->
          rm @file.png
            .catch ->

    _transform: (chunk, encoding, cb) ->
      cb()

  return new Frame()
