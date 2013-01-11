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
    @words.errorCheck()
    @prepareWordsCollection()
    @words

  prepareWordsCollection: ->
    if @parseSelectedOptions().delimiter then @words.delimit($("#worddelimiter", @el).val())
    if @parseSelectedOptions().reverse then @words.reverse()
    # if @parseSelectedOptions().crayon then $("#trainer").addClass("crayon") else $("#trainer").removeClass("crayon")

  getWordsCollection: ->
    new WordsCollection($("textarea", @el).val().split(" "))

  getInterval: ->
    60 / parseInt($("#wpm", @el).val()) * 1000

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
    @words = @words.join(" #{delimiter} ").split(" ")

  reverse: ->
    @words.reverse();

  errorCheck: ->
    @approvedWords = [] 
    @approvedWords.push(word) for word in @words when word 
    @words = @approvedWords

  toArray: ->
    @words




class Trainer
  constructor: ->
    @el = $("#trainer")
    @colors = ["greenColor", "redColor", "tealColor","purpleColor","yellowColor","blueColor","maroonColor"]
  start: (words, interval) ->


    clearInterval(@interval) if @interval
    @currentWordIndex = 0
    
    @words = words
    @endingIndex = @words.length

    @interval = setInterval(@displayNextWord, interval)


  pause: ->
    clearInterval(@interval)

  resume: (interval) -> 
    @interval = setInterval(@displayNextWord, interval)

  displayNextWord: =>
    $("#word", @el).html(@words[@currentWordIndex])
    

    if @words[@currentWordIndex].toUpperCase() == "CAPITALISM"
      $("#colorSelector").removeClass()
      $("#colorSelector").addClass("redColor")
    else 
      if  $("#crayon").hasClass("active") 
        $("#colorSelector").removeClass()
        $("#colorSelector").addClass(@colors[Math.floor(Math.random() * 7)])
        $("#trainer").addClass("crayon")
      else
        $("#colorSelector").removeClass()
        $("#trainer").removeClass("crayon")

    @currentWordIndex += 1


new PageController()