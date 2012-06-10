// Generated by CoffeeScript 1.3.1
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  BH.Views.Modal = (function(_super) {

    __extends(Modal, _super);

    Modal.name = 'Modal';

    function Modal() {
      return Modal.__super__.constructor.apply(this, arguments);
    }

    Modal.prototype.pulseClass = 'pulse';

    Modal.prototype.generalEvents = {
      'click .close-button': 'close',
      'click .overlay': 'pulse'
    };

    Modal.prototype.attachGeneralEvents = function() {
      return _.extend(this.events, this.generalEvents);
    };

    Modal.prototype.template = function(json) {
      var overlay;
      overlay = $($('#modal').html());
      $('.page', overlay).append(Mustache.render($("#" + this.templateId).html(), json));
      return overlay;
    };

    Modal.prototype.open = function() {
      $('body').append(this.render().el);
      this._globalBinds();
      return this.$('.overlay').fadeIn('fast', function() {
        return $(this).children().fadeIn('fast', function() {
          return $(window).trigger('resize');
        });
      });
    };

    Modal.prototype.pulse = function() {
      return this.$('.page').addClass('pulse');
    };

    Modal.prototype.close = function() {
      var _this = this;
      this.trigger('close');
      return this.$('.overlay').fadeOut('fast', function() {
        _this.remove();
        return _this._globalUnbinds();
      });
    };

    Modal.prototype._globalBinds = function() {
      $(window).resize(this._updateHeight);
      return $(window).keydown($.proxy(this._closeOnEscape, this));
    };

    Modal.prototype._globalUnbinds = function() {
      $(window).unbind('resize');
      return $(document).unbind('keydown');
    };

    Modal.prototype._updateHeight = function() {
      return this.$('.page').css({
        maxHeight: Math.min(0.9 * window.innerHeight, 640)
      });
    };

    Modal.prototype._closeOnEscape = function(e) {
      if (e.keyCode === 27) {
        return this.close();
      }
    };

    return Modal;

  })(BH.Views.BaseView);

}).call(this);
