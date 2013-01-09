class PageController
  constructor: ->
    trainer = new Trainer
    controls = new Controls

    $(controls).on("started", (event, words, interval) -> trainer.start(words, interval) )
    $(controls).on("paused", -> trainer.pause() )
    $(controls).on("resumed", (event, interval) -> trainer.resume(interval))

class Controls
  constructor: ->
    @el = $("#controls")
    $("#start", @el).on("click", @start)
    $("#pause", @el).on("click", @togglePause)

  start: =>
    @isPaused = false
    $("#pause", @el).html("Pause")
    $(@).trigger("started", [@getWordsArray(), @getInterval()])

  pause: ->
    @isPaused = true
    $("#pause", @el).html("Resume")
    $(@).trigger("paused")

  resume: ->
    @isPaused = false
    $("#pause", @el).html("Pause")
    $(@).trigger("resumed", [@getInterval()])

  togglePause: (event) =>
    if @isPaused then @resume() else @pause()

  getWordsArray: ->
    @getWords().toArray()

  getWords: ->
    @words = @getWordsCollection()
    @prepareWordsCollection()
    @words

  prepareWordsCollection: ->
    console.log("Prepare words happened")
    if @parseSelectedOptions().delimiter then @words.delimit("hello")
    if @parseSelectedOptions().reverse then @words.reverse()

  getWordsCollection: ->
    new WordsCollection($("textarea", @el).val().split(" "))

  getInterval: ->
    60 / parseInt($("#wpm", @el).val()) * 1000

  errorCheckText: (words) ->
    # have yet to implement
    for word, i in words
      if word = " " then words = words[i..i]

  parseSelectedOptions: ->
    {
      delimiter: @getDelimiterOption()
      reverse: @getReverseOption()
    }

  getDelimiterOption: ->
    $("#delimit", @el).hasClass("active")

  getReverseOption: ->
    $("#backwards", @el).hasClass("active")

class WordsCollection
  constructor: (@words) ->

  delimit: (delimiter) ->
    console.log(delimiter)
    @words = @words.join(" #{delimiter} ").split(" ")
    console.log(@words)
  reverse: ->
    @words.reverse();
    console.log("Reverse ran")

  toArray: ->
    @words




class Trainer
  constructor: ->
    @el = $("#trainer")

  start: (words, interval) ->
    clearInterval(@interval) if @interval
    @currentWordIndex = 0
    @words = words
    @interval = setInterval(@displayNextWord, interval)

  pause: ->
    clearInterval(@interval)

  resume: (interval) -> 
    @interval = setInterval(@displayNextWord, interval)

  displayNextWord: =>
    $("#word", @el).html(@words[@currentWordIndex])
    @currentWordIndex += 1


new PageController()