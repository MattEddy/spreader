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
    # TODO - move this method out of the WordsCollection and decompose into smaller, 'sharper' methods
    # The WordsCollection is supposed to be a fancy array, yet we have it picking out page elements (e.g. #wpm),
    # and it is holding all the logic about what constitutes 'valid' options (e.g. WPM must be a number).
    #
    # Maybe we're missing a TrainerOptions class?  Maybe we could ask the Controls for a set of TrainerOptions (that is,
    # the Controls class turn textareas and inputs into TrainerOptions), and the TrainerOptions has a @isValid method,
    # which does the logic that this method currently implements.

    delimitWord = $("#worddelimiter", @el).val()
    WPM         = "" + $("#wpm", @el).val()
    textArea    = $("textarea", @el).val()
    goodToGo    = true

    if $("#delimit", @el).hasClass("active") and delimitWord.replace(/\s+$/g,' ') == ""
      goodToGo = false
      @displayError("delimiterRequired")

    if WPM.replace(/\s+$/g,' ') == ""
      goodToGo = false
      @displayError("wpmRequired")

    if isNaN(WPM)
      goodToGo = false
      @displayError("wpmInvalid")

    if WPM < 1
      goodToGo = false
      @displayError("wpmInvalidNumber")

    if textArea.replace(/\s+$/g,' ') == ""
      goodToGo = false
      @displayError("textRequired")

    goodToGo

  displayError: (errorName) ->
    @alertUser(AppConfiguration.errorMessages[errorName])

  alertUser: (error) ->
    $("#message").remove()
    $("#messageContainer").append("""
      <div class="alert alert-block alert-error fade in" id="message"><button type="button" class="close" data-dismiss="alert">×</button>
        <h4 class="alert-heading">#{error.title}</h4>
        <p>#{error.body}</p>
      </div>
    """)

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
    # TODO - decompose this method into smaller, 'sharper' methods.

    $("#word", @el).html(@words[@currentWordIndex])

    # Naming your logic can help you reason with code.
    # For example, if this was called @checkIfFinished(), we wouldn't have to figure out what the code is doing,
    # we could assume it does what the name claims
    if @currentWordIndex == @words.length
      clearInterval(@interval)

    # Same thing here with naming.  I would call this @stylizeWord() and extract the entire thing to its own method
    # The idea here is to decompose our code into tiny, independent pieces.
    if @words[@currentWordIndex].toUpperCase() == "CAPITALISM"
      $("#colorSelector").removeClass()
      $("#colorSelector").addClass("redColor")
    else
      # I thought our Controls class parsed User input into options, not the Trainer?
      # The fact the we can't scope our selector here via $("#crayon", @el) should tell us
      # that maybe this question (is crayon mode on?) should live elsewhere
      if  $("#crayon").hasClass("active")
        $("#colorSelector").removeClass()
        $("#colorSelector").addClass(@colors[Math.floor(Math.random() * 7)])
        $("#trainer").addClass("crayon")
      else
        $("#colorSelector").removeClass()
        $("#trainer").removeClass("crayon")

    @currentWordIndex += 1

new PageController()