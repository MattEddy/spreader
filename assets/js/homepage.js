// Generated by CoffeeScript 1.4.0
(function() {
  var Controls, ErrorChecker, PageController, Trainer, WordsCollection,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  PageController = (function() {

    function PageController() {
      var controls, trainer;
      trainer = new Trainer;
      controls = new Controls;
      $(controls).on("started", function(event, words, interval) {
        return trainer.start(words, interval);
      });
      $(controls).on("paused", function() {
        return trainer.pause();
      });
      $(controls).on("resumed", function(event, interval) {
        return trainer.resume(interval);
      });
    }

    return PageController;

  })();

  ErrorChecker = (function() {

    function ErrorChecker() {}

    ErrorChecker.prototype.checkFields = function() {
      this.goodToGo = true;
      this.checkDelimiter();
      return this.goodToGo;
    };

    ErrorChecker.prototype.checkDelimiter = function() {
      var delimitWord;
      delimitWord = $("#worddelimiter", this.el).val();
      if ($("#delimit", this.el).hasClass("active")) {
        if (delimitWord.replace(/\s+$/g, ' ') === "") {
          this.goodToGo = false;
          this.alertUser("Woah buddy,", "Add Word Delimiter is toggled. You need to add a word to use as a delimiter if you want this to function. Also you're a horrible person.");
        }
      }
      this.changeButtonLook("delimit", "delimitControl", this.goodToGo);
      if (this.goodToGo === true) {
        return this.checkWPM();
      }
    };

    ErrorChecker.prototype.checkWPM = function() {
      var WPM;
      WPM = "" + $("#wpm", this.el).val();
      if (WPM.replace(/\s+$/g, ' ') === "") {
        this.goodToGo = false;
        this.alertUser("Woah friend,", "You need to enter how many words per minute you want this thing to run at. Also your wife tastes like honey nut cherrios.");
      }
      if (isNaN(WPM)) {
        this.goodToGo = false;
        this.alertUser("Woah champ,", "You need to enter a number in words per minute, not a fucking symbol. Also all your lovers find your performance to be sub par.");
      }
      if (WPM < 1) {
        this.goodToGo = false;
        this.alertUser("Woah guy,", "You need to enter a number greater than 1 in words per minute. Also there is no meaning in the universe.");
      }
      this.changeButtonLook("", "WPMcontrols", this.goodToGo);
      if (this.goodToGo === true) {
        return this.checkTextArea();
      }
    };

    ErrorChecker.prototype.checkTextArea = function() {
      var textArea;
      textArea = $("textarea", this.el).val();
      if (textArea.replace(/\s+$/g, ' ') === "") {
        this.goodToGo = false;
        this.alertUser("Woah dude,", "You need to enter some text to read. Also you dress like a rube.");
      }
      this.changeButtonLook("", "textareaControls", this.goodToGo);
      if (this.goodToGo === true) {
        return this.eraseAlertMessage();
      }
    };

    ErrorChecker.prototype.eraseAlertMessage = function() {
      return $("#message").alert('close');
    };

    ErrorChecker.prototype.checkWords = function(words) {
      var word, _i, _len, _ref;
      this.words = words;
      this.approvedWords = [];
      _ref = this.words.getWordsArray();
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        word = _ref[_i];
        if (word) {
          this.approvedWords.push(word);
        }
      }
      return this.words.setWordsArray(this.approvedWords);
    };

    ErrorChecker.prototype.alertUser = function(header, alertMessage) {
      $("#message").remove();
      return $("#messageContainer").append('<div class="alert alert-block alert-error fade in" id="message"><button type="button" class="close" data-dismiss="alert">×</button>\
    <h4 class="alert-heading">' + header + '</h4>\
    <p>' + alertMessage + '</p>\
    </div>');
    };

    ErrorChecker.prototype.changeButtonLook = function(id, controlId, isGood) {
      if (!(id === "") && isGood === false) {
        $("#" + id, this.el).addClass("btn-danger");
        $("#" + id, this.el).removeClass("btn-primary");
      }
      if (!(id === "") && isGood === true) {
        $("#" + id, this.el).addClass("btn-primary");
        $("#" + id, this.el).removeClass("btn-danger");
      }
      if (isGood === false) {
        $("#" + controlId).addClass("error");
      }
      if (isGood === true) {
        return $("#" + controlId).removeClass("error");
      }
    };

    return ErrorChecker;

  })();

  Controls = (function() {

    function Controls() {
      this.togglePause = __bind(this.togglePause, this);

      this.start = __bind(this.start, this);
      this.el = $("#controls");
      $("#start", this.el).on("click", this.start);
      $("#pause", this.el).on("click", this.togglePause);
      this.errorChecker = new ErrorChecker;
    }

    Controls.prototype.start = function() {
      this.isPaused = false;
      $("#pause", this.el).html("Pause");
      if (this.errorChecker.checkFields()) {
        return $(this).trigger("started", [this.getWordsArray(), this.getInterval()]);
      }
    };

    Controls.prototype.pause = function() {
      this.isPaused = true;
      $("#pause", this.el).html("Resume");
      return $(this).trigger("paused");
    };

    Controls.prototype.resume = function() {
      this.isPaused = false;
      $("#pause", this.el).html("Pause");
      return $(this).trigger("resumed", [this.getInterval()]);
    };

    Controls.prototype.togglePause = function(event) {
      if (this.isPaused) {
        return this.resume();
      } else {
        return this.pause();
      }
    };

    Controls.prototype.getWordsArray = function() {
      return this.getWords().getWordsArray();
    };

    Controls.prototype.getWords = function() {
      this.words = this.getWordsCollection();
      this.errorChecker.checkWords(this.words);
      this.prepareWordsCollection();
      return this.words;
    };

    Controls.prototype.prepareWordsCollection = function() {
      if (this.parseSelectedOptions().delimiter) {
        this.words.delimit($("#worddelimiter", this.el).val());
      }
      if (this.parseSelectedOptions().reverse) {
        return this.words.reverse();
      }
    };

    Controls.prototype.getWordsCollection = function() {
      return new WordsCollection($("textarea", this.el).val().split(" "));
    };

    Controls.prototype.getInterval = function() {
      return 60 / parseInt($("#wpm", this.el).val()) * 1000;
    };

    Controls.prototype.parseSelectedOptions = function() {
      return {
        delimiter: this.getDelimiterOption(),
        reverse: this.getReverseOption()
      };
    };

    Controls.prototype.getDelimiterOption = function() {
      return $("#delimit", this.el).hasClass("active");
    };

    Controls.prototype.getReverseOption = function() {
      return $("#backwards", this.el).hasClass("active");
    };

    return Controls;

  })();

  WordsCollection = (function() {

    function WordsCollection(words) {
      this.words = words;
    }

    WordsCollection.prototype.delimit = function(delimiter) {
      return this.words = this.words.join(" " + delimiter + " ").split(" ");
    };

    WordsCollection.prototype.reverse = function() {
      return this.words.reverse();
    };

    WordsCollection.prototype.setWordsArray = function(words) {
      this.words = words;
    };

    WordsCollection.prototype.getWordsArray = function() {
      return this.words;
    };

    return WordsCollection;

  })();

  Trainer = (function() {

    function Trainer() {
      this.displayNextWord = __bind(this.displayNextWord, this);
      this.el = $("#trainer");
      this.colors = ["greenColor", "redColor", "tealColor", "purpleColor", "yellowColor", "blueColor", "maroonColor"];
    }

    Trainer.prototype.start = function(words, interval) {
      if (this.interval) {
        clearInterval(this.interval);
      }
      this.currentWordIndex = 0;
      this.words = words;
      this.endingIndex = this.words.length;
      return this.interval = setInterval(this.displayNextWord, interval);
    };

    Trainer.prototype.pause = function() {
      return clearInterval(this.interval);
    };

    Trainer.prototype.resume = function(interval) {
      return this.interval = setInterval(this.displayNextWord, interval);
    };

    Trainer.prototype.displayNextWord = function() {
      $("#word", this.el).html(this.words[this.currentWordIndex]);
      if ((this.currentWordIndex + 1) === this.words.length) {
        clearInterval(this.interval);
      }
      if (this.words[this.currentWordIndex].toUpperCase() === "CAPITALISM") {
        $("#colorSelector").removeClass();
        $("#colorSelector").addClass("redColor");
      } else {
        if ($("#crayon").hasClass("active")) {
          $("#colorSelector").removeClass();
          $("#colorSelector").addClass(this.colors[Math.floor(Math.random() * 7)]);
          $("#trainer").addClass("crayon");
        } else {
          $("#colorSelector").removeClass();
          $("#trainer").removeClass("crayon");
        }
      }
      return this.currentWordIndex += 1;
    };

    return Trainer;

  })();

  new PageController();

}).call(this);
