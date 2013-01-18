###

  PageTour: A guide through your website. In a simple and effective way!

  Copyright 2013, Stefano Ceschi Berrini
  
  @author  Stefano Ceschi Berrini <stefano.ceschib@gmail.com> @stecb
  @link    https://github.com/stecb/pagetour
  @license http://opensource.org/licenses/MIT
  @version 0.2.1
  
###

(($) ->

  class PageTour
  
    # default options
    options : 
      prefix        : 'pagetour' # needed for css and custom events
      labelNext     : 'next'
      labelPrev     : 'prev'
      labelFinish   : 'Done!'
      labelHideAll  : 'x'
      autoStart     : false
      mainContent   : false
      fadeTo        : 0.8
      showMasks     : true
      helpTitle     : 'Tips: use left|right arrow keys to navigate, esc to close it and ? key to open it'
      showHelp      : true
  
    # not started yet...
    started : false
  
    # cache masks (top, bottom, left, right)
    masks : {}
    
    # some instance props
    currentStep        : -1
    currentElement     : null
    currentStepElement : null
    documentHeight     : 0 # once guide starts (is opened), document height should always be constant (but not on window resizing, see recalculate method)
  
    ###
    *
    * initialize method (when the new Pagetour element is instatiated)
    *
    * @param steps, an array of objects : each object is composed by
    *   { 
    *     selector : 'id_of_the_item_to_be_displayed', 
    *     description : 'guide html message'
    *   }
    * @param options, object of options
    *
    ###
  
    constructor : ( steps, o ) ->
      $.extend @options, o
      @steps = steps

      @_buildMask()
      @_buildTooltip()
      @_setEvents()

      this.start() if @options.autoStart
      @
  
    _setDocumentHeight : ->
      @documentHeight = $(document).height()
      @
    
    ###
    *
    * _buildMask, internal method, for first mask creation (wrapper, top, left, right)
    *
    ###

    _buildMask : ->

      o = @options

      @masks.wrapper = $("<div class='#{o.prefix}-mask-wrapper'></div>")
      @masks.wrapper.append($("<div class='#{o.prefix}-mask-help' title='#{o.helpTitle}'>?</div>")) if o.showHelp
      @masks.top = $("<div class='#{o.prefix}-mask-top'></div>")
      @masks.left = $("<div class='#{o.prefix}-mask-left'></div>")
      @masks.right = $("<div class='#{o.prefix}-mask-right'></div>")
      @masks.bottom = $("<div class='#{o.prefix}-mask-bottom'></div>")
    
      $(document.body).append(@masks.wrapper.append(@masks.top).append(@masks.left).append(@masks.right).append(@masks.bottom))

      @
  
    ###
    *
    * _buildTooltip
    *
    ###

    _buildTooltip : ->

      o = @options
      tooltipTpl = o.template || """
                  <div class="#{o.prefix}-step-tooltip blue popover in">
                    <div class="arrow"></div>
                    <div class="popover-inner">
                      <div class="#{o.prefix}-step-hide" title="close guide" data-placement="right" data-animation="false">#{o.labelHideAll}</div>
                      <h3 class="popover-title"></h3>
                      <div class="#{o.prefix}-step-tooltip-content popover-content"><p class="#{o.prefix}-step-tooltip-description"></p></div>
                      <div class="#{o.prefix}-step-tooltip-controls">
                        <a href='#' class='arrowed floatright reverse #{o.prefix}-step-next'>#{o.labelNext}</a>
                        <a href='#' class='arrowed floatright reverse #{o.prefix}-step-close'>#{o.labelFinish}</a>
                        <a href='#' class='arrowed leftarrow reverse #{o.prefix}-step-prev'>#{o.labelPrev}</a>
                      </div>
                  </div>
                  """
      @tooltip = $(tooltipTpl)
      @tooltip.find(".#{o.prefix}-step-hide").tooltip()
      @masks.wrapper.append(@tooltip)
  
    ###
    *
    * _setEvents, internal method, for prev/next controls (delegation to the wrapper)
    *
    ###

    _setEvents : ->

      o = this.options
    
      @masks.wrapper.on('click', ".#{o.prefix}-step-next", @_nextStep.bind(@))
      @masks.wrapper.on('click', ".#{o.prefix}-step-prev", @_prevStep.bind(@))
      @masks.wrapper.on('click', ".#{o.prefix}-step-close", @close.bind(@))
      @masks.wrapper.on('click', ".#{o.prefix}-step-hide", @close.bind(@))
    
      $(window).resize @_recalculateSides.bind(this)
    
      $(document).keydown (e) =>
        if @started
          switch e.keyCode
            when 39 
              @_nextStep() if @currentStep < @steps.length - 1
              false
            when 37
              @_prevStep() if @currentStep > 0
              false
            when 27
              @close()
              false
        else
          if e.shiftKey and e.keyCode is 191
            @start()
          
    ###
    *
    * _setMask, internal method, to set the proper offset to each mask
    *
    * @param position, the position object of the current element
    * @param size, the size object of the current element
    *
    ###

    _setMask : ( position, size ) ->
    
      bottomTop = position.y + size.y
      o         = this.options
      
      if this.options.showMasks

        @masks.top.css
          top : 0
          height : position.y - (@currentStepElement.padding || 0)
        .fadeTo(100, o.fadeTo)

        @masks.bottom.css
          height : @documentHeight - bottomTop - (@currentStepElement.padding || 0)
          top : bottomTop + (@currentStepElement.padding || 0)
        .fadeTo(100, o.fadeTo)

        @masks.left.css
          height : size.y + ((@currentStepElement.padding || 0) * 2)
          top : position.y - (@currentStepElement.padding || 0)
          width : position.x - (@currentStepElement.padding || 0)
        .fadeTo(100, o.fadeTo)

        @masks.right.css
          height : size.y + ((@currentStepElement.padding || 0) * 2)
          top : position.y - (@currentStepElement.padding || 0)
          width: $(document.body).width() - position.x - size.x - (@currentStepElement.padding || 0)
        .fadeTo(100, o.fadeTo)

      @_setTooltip(position, size)
  
    ###  
    *
    * _recalculateSides, internal method, needed when the window is resized (left/right masks change)
    *
    ###

    _recalculateSides : ->
      
      if @started
        originalPosition = @currentElement.offset()
        marginTop        = if typeof @currentStepElement.margin_top isnt 'undefined' then @currentStepElement.margin_top else 0
        marginBottom     = if typeof @currentStepElement.margin_bottom isnt 'undefined' then @currentStepElement.margin_bottom else 0
        size             = { x : @currentElement.outerWidth(), y : @currentElement.outerHeight() + marginBottom + marginTop }
        position         = { x : originalPosition.left, y : originalPosition.top - marginTop}
    
        @_setDocumentHeight()
        @_setMask(position, size)
        this._setTooltipPosition(size, position)
  
    ###
    *
    * _setTooltipPosition, internal method, to set the tooltip position
    *
    * @param position, the position object of the current element
    * @param size, the size object of the current element
    *
    ###

    _setTooltipPosition : ( size, position ) ->
    
      pos = @currentStepElement.position
    
      # if no position override is given (or top/bottom), do automagically
      if typeof pos is 'undefined' or pos is 'top' or pos is 'bottom'
    
        left         = position.x - ~~(@tooltip.width()/2) + ~~(size.x/2)
        originalTop  = position.y - @tooltip.height() - 12
        top          = if originalTop < 0 then position.y + size.y + 10 else originalTop
  
        @tooltip.css
          left : left + (@currentStepElement.offsetLeft || 0)
          top : top + (@currentStepElement.offsetTop || 0)

        if originalTop < 0
          @tooltip.addClass('bottom').removeClass('top left right')
        else
          @tooltip.addClass('top').removeClass('bottom left right')
        
      else
        @tooltip.css
          top : position.y - ~~(@tooltip.height()/2) + ~~(size.y/2) + (@currentStepElement.offsetTop || 0)
        if pos is 'left'
          @tooltip.css
            left : position.x - @tooltip.width() - 10 + (@currentStepElement.offsetLeft || 0)
          @tooltip.addClass('left').removeClass('bottom top right')
        else
          @tooltip.css
            left : position.x + size.x + 10 + (@currentStepElement.offsetLeft || 0)
          @tooltip.addClass('right').removeClass('bottom top left')
      
  
    ###
    *
    * _setTooltip, internal method, to set the tooltip guide for the element to the proper offset
    *
    * @param position, the position object of the current element
    * @param size, the size object of the current element
    *
    *
    ###

    _setTooltip : ( position, size ) ->

      o          = @options
      step       = @steps[@currentStep]
      guide      = step.description
    
      @tooltip.show()
    
      @tooltip.find(".#{o.prefix}-step-prev, .#{o.prefix}-step-next, .#{o.prefix}-step-close").hide()
      @tooltip.find(".#{o.prefix}-step-next, .#{o.prefix}-step-prev").show() if @currentStep >= 0
      @tooltip.find(".#{o.prefix}-step-prev").hide() if @currentStep is 0
      @tooltip.find(".#{o.prefix}-step-close").show() and @tooltip.find(".#{o.prefix}-step-next").hide() if @currentStep is @steps.length - 1
      @tooltip.find(".#{o.prefix}-step-tooltip-description").html(guide)

      @_setTooltipPosition(size, position)


    ###
    *
    * _doStep, internal method, to create the step for each element
    *
    ###

    _doStep : ->
    
      # to re set if selector doesn't match
      _tmp_last_element = @currentElement 
      _tmp_last_step = @currentStepElement
    
      currStep = @steps[@currentStep]

      @currentStepElement = currStep
      @currentElement = $(currStep.selector)
    
      if @currentElement.length isnt 0
    
        originalPosition = @currentElement.offset()
        marginTop        = if typeof currStep.margin_top isnt 'undefined' then currStep.margin_top else 0
        marginBottom     = if typeof currStep.margin_bottom isnt 'undefined' then currStep.margin_bottom else 0
        size             = { x : @currentElement.outerWidth(), y : @currentElement.outerHeight() + marginBottom + marginTop }
        position         = { x : originalPosition.left, y : originalPosition.top - marginTop}

        @_setMask(position, size)

        scrollTopOffset = if @tooltip.hasClass('bottom') then @tooltip.offset().top - size.y - 20 else @tooltip.offset().top - 10
    
        $('html, body').stop().animate
          scrollTop: scrollTopOffset - 20
        , 500
    
      else
        # reset elems
        @currentStepElement = _tmp_last_step
        @currentElement = _tmp_last_element
        console.log('use a valid selector, luke!')
  
    ###  
    *
    * _nextStep, internal method, to go to the next tour step
    *
    ###

    _nextStep : ->

      if @currentStep < @steps.length - 1
        @currentStep++
        @_doStep()
    
      false

    ###
    *
    * _prevStep, internal method, to go to the previous tour step
    *
    ###

    _prevStep : ->

      if @currentStep >= 0 
        @currentStep--
        @_doStep()
      
      false
    
    ###
    *
    * PUBLIC METHODS
    *
    * Pretty self explanatory
    *
    ###

    start : ->
    
      unless @started
        $(document.body).trigger("#{@options.prefix}Started")
        @_setDocumentHeight()
        @started = true
        @masks.wrapper.show().stop().fadeTo(500,1)
        @currentStep-- if @currentStep isnt -1
        @_nextStep()
      @

    restart : ->
    
      $(document.body).trigger("#{@options.prefix}Restarted")
      @started = true
      @masks.wrapper.fadeTo(500, 1)
      @masks.wrapper.css('display','block')
      @currentStep = -1
      @currentElement = null
      @currentStepElement = null
      @_nextStep()
      @

    close : ->
    
      @started = false
      @tooltip.find(".#{@options.prefix}-step-hide").tooltip('hide')
      @masks.wrapper.stop().fadeTo 500, 0, => 
        @masks.wrapper.hide()
        $(document.body).trigger("#{@options.prefix}Closed")
      @
  
  # make it available by calling $.pageTour(steps /* [] <= Array*/, options /* {} <= Object*/)
  
  $.extend
    pageTour: (s, o = {}) ->
      new PageTour(s, o)
  
) jQuery