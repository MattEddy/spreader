# * Breaks w/o WPM
# * First word should happen immediately
# * Breaks at end of loop (words are finished)
# * Don't leave console.logs
# * Errors don't disappear

# Maybes
# * Instructions to top?
# * Error not super visible, maybe highlight the field the user needs to fix

# but think really carefully about a) the names of classes b) what I class should do
# duplicating logic = bad

class PageController
  constructor: ->
    trainer = new Trainer
    controls = new Controls

    $(controls).on("started", (event, words, interval) -> trainer.start(words, interval) )
    $(controls).on("paused", -> trainer.pause() )
    $(controls).on("resumed", (event, interval) -> trainer.resume(interval))

class ErrorChecker
  
  checkFields: ->
    @goodToGo = true
    @checkDelimiter()
    @goodToGo


  checkDelimiter: ->
    delimitWord = $("#worddelimiter", @el).val()
    if $("#delimit", @el).hasClass("active")
      if delimitWord.replace(/\s+$/g,' ') == ""
        @goodToGo = false
        @alertUser("Woah buddy,","Add Word Delimiter is toggled. You need to add a word to use as a delimiter if you want this to function. Also you're a horrible person.")

    @changeButtonLook("delimit", "delimitControl", @goodToGo)
    if @goodToGo == true
      @checkWPM()

  checkWPM: ->
    WPM = "" + $("#wpm", @el).val()
    if WPM.replace(/\s+$/g,' ') == ""
      @goodToGo = false
      @alertUser("Woah friend,","You need to enter how many words per minute you want this thing to run at. Also your wife tastes like honey nut cherrios.")

    if isNaN(WPM)
      @goodToGo = false
      @alertUser("Woah champ,","You need to enter a number in words per minute, not a fucking symbol. Also all your lovers find your performance to be sub par.")

    if WPM < 1
      @goodToGo = false
      @alertUser("Woah guy,","You need to enter a number greater than 1 in words per minute. Also there is no meaning in the universe.")

    @changeButtonLook("", "WPMcontrols", @goodToGo)
    if @goodToGo == true
      @checkTextArea()

  checkTextArea: ->
    textArea = $("textarea", @el).val()

    if textArea.replace(/\s+$/g,' ') == ""
      @goodToGo = false
      @alertUser("Woah dude,","You need to enter some text to read. Also you dress like a rube.")

    @changeButtonLook("", "textareaControls", @goodToGo)

    if @goodToGo == true
      @eraseAlertMessage()

  eraseAlertMessage: ->
    $("#message").alert('close')
  checkWords: (@words) -> 

    @approvedWords = [] 
    @approvedWords.push(word) for word in @words.getWordsArray() when word 
    @words.setWordsArray(@approvedWords)

  alertUser: (header, alertMessage) ->
    $("#message").remove()
    $("#messageContainer").append('<div class="alert alert-block alert-error fade in" id="message"><button type="button" class="close" data-dismiss="alert">×</button>
    <h4 class="alert-heading">' + header + '</h4>
    <p>' + alertMessage + '</p>
    </div>')

  changeButtonLook: (id, controlId, isGood) ->
    if !(id == "") && isGood == false
      $("#" + id, @el).addClass("btn-danger")
      $("#" + id, @el).removeClass("btn-primary")

    if !(id == "") && isGood == true
      $("#" + id, @el).addClass("btn-primary")
      $("#" + id, @el).removeClass("btn-danger")

    if isGood == false
      $("#" + controlId).addClass("error")

    if isGood == true
      $("#" + controlId).removeClass("error")


class Controls
  constructor: ->
    @el = $("#controls")
    $("#start", @el).on("click", @start)
    $("#pause", @el).on("click", @togglePause)
    @errorChecker = new ErrorChecker

  start: =>
    @isPaused = false
    $("#pause", @el).html("Pause")
    if @errorChecker.checkFields()
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
    @getWords().getWordsArray()

  getWords: ->
    @words = @getWordsCollection()
    @errorChecker.checkWords(@words)
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

  setWordsArray: (@words) ->

  getWordsArray: ->
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

    if (@currentWordIndex + 1) == @words.length
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