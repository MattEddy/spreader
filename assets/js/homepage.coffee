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
    console.log(@words)
    if @words.errorCheck()
      @prepareWordsCollection()
      @words

  prepareWordsCollection: ->
    if @parseSelectedOptions().delimiter then @words.delimit($("#worddelimiter", @el).val())
    if @parseSelectedOptions().reverse then @words.reverse()

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

  toArray: ->
    @words

  errorCheck: ->
    @checkWords()
    @checkFields()

  checkWords: -> 
    @approvedWords = [] 
    @approvedWords.push(word) for word in @words when word 
    @words = @approvedWords

  checkFields: ->
    delimitWord = $("#worddelimiter", @el).val()
    WPM = "" + $("#wpm", @el).val()
    textArea = $("textarea", @el).val()
    goodToGo = true
    if $("#delimit", @el).hasClass("active")
      if delimitWord.replace(/\s+$/g,' ') == ""
        goodToGo = false
        @alertUser("Woah buddy,","Add Word Delimiter is toggled. You need to add a word to use as a delimiter if you want this to function. Also you're a horrible person.")

    if WPM.replace(/\s+$/g,' ') == ""
      goodToGo = false
      @alertUser("Woah friend,","You need to enter how many words per minute you want this thing to run at. Also your wife tastes like honey nut cherrios.")

    if isNaN(WPM)
      goodToGo = false
      @alertUser("Woah champ,","You need to enter a number in words per minute, not a fucking symbol. Also all your lovers find your performance to be sub par.")

    if WPM < 1
      goodToGo = false
      @alertUser("Woah guy,","You need to enter a number greater than 1 in words per minute. Also there is no meaning in the universe.")

    if textArea.replace(/\s+$/g,' ') == ""
      goodToGo = false
      @alertUser("Woah dude,","You need to enter some text to read. Also you dress like a rube.")

    goodToGo




  alertUser: (header, alertMessage) ->
    $("#message").remove()
    $("#messageContainer").append('<div class="alert alert-block alert-error fade in" id="message"><button type="button" class="close" data-dismiss="alert">×</button>
            <h4 class="alert-heading">' + header + '</h4>
            <p>' + alertMessage + '</p>
            </div>')

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

    if @currentWordIndex == @words.length
      clearInterval(@interval)

# Checks if the words is capitalism and changes the color to red if it is
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