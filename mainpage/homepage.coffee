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
    $(@).trigger("started", [@getWords(), @getInterval()])

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

  getWords: ->
    @checkWordDelimited(@checkBackwards($("textarea", @el).val().split(" "))))

  getInterval: ->
    60 / parseInt($("#wpm", @el).val()) * 1000

  checkBackwards: (words) ->
    if $("#backwards").hasClass("active")
      words.reverse() 
    else 
      words

  checkWordDelimited: (words) ->
    delimitWord = $("#worddelimiter").val()
    if $("#delimit").hasClass("active")
      words.join(" #{delimitWord} ").split(" ")
    else 
      words
      
  errorCheckText: (words) ->
    console.log("ran")
    for word in words 
      if word = " " then words = words[i..i]
    console.log(words)
  removeBadWords: (words) ->

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