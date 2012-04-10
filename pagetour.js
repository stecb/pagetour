/* 
	
	Pagetour Class, an inline guide for your pages. Yes, inline.
	
	Requires mootools-core, mootools-more (Fx.Scroll)
	
	@author Stefano Ceschi Berrini (@stecb | stefano.ceschib@gmail.com)
	
*/

Fitmo.Pagetour = new Class({
  
  Implements : [Options, Events],
  
  options : {
    maskPrefix : "guide-mask",
    stepPrefix : "guide-step",
    labelNext : "next",
    labelPrev : "prev",
    labelFinish : "Ok, start to use Fitmo!",
    labelHideAll : "Hide all tips",
    autoStart : false,
    mainContent : false,
    fadeTo : 0.8,
    showMasks : false
  },
  
  started : false,
  
  masks : {},
  steps : {},
  
  currentStep : -1,
  currentElement : null,
  currentStepElement : null,
  
  /*
  * initialize method (when the new Pagetour element is instatiated)
  *
  * @param steps, an array of objects : each object is a pair of { id : 'id_of_the_item_to_be_displayed', description : 'guide html message' }
  * @param options, object of options
  *
  */
  
  initialize : function( steps, options ){ 
    
    this.setOptions(options);
    
    this.steps = steps;
    
    this._buildMask();
    this._setDelegation();
    
    if(this.options.autoStart){
      this.start();
    }
    
  },
  
  /*
  * _setDelegation, internal method, for prev/next controls (delegation to the wrapper)
  *
  */
  
  _setDelegation : function(){
    
    var evts = {}
      , o    = this.options
    ;
    
    evts['click:relay(.'+o.stepPrefix+'-next)'] = this._nextStep.bind(this);
    evts['click:relay(.'+o.stepPrefix+'-prev)'] = this._prevStep.bind(this);
    evts['click:relay(.'+o.stepPrefix+'-close)'] = this.closeTour.bind(this);
    evts['click:relay(.'+o.stepPrefix+'-hide)'] = this.closeTour.bind(this);
    
    this.masks.wrapper.addEvents(evts);
    
  },
  
  /*
  * _buildMask, internal method, for first mask creation (wrapper, top, left, right)
  *
  */
  
  _buildMask : function(){
    
    var o = this.options;
    
    this.masks.wrapper = new Element('div.'+o.maskPrefix+'-wrapper').inject($(document.body),'top');
    this.masks.top = new Element('div.'+o.maskPrefix+'-top').inject(this.masks.wrapper);
    this.masks.left = new Element('div.'+o.maskPrefix+'-left').inject(this.masks.wrapper);
    this.masks.right = new Element('div.'+o.maskPrefix+'-right').inject(this.masks.wrapper);
    this.masks.bottom = new Element('div.'+o.maskPrefix+'-bottom').inject(this.masks.wrapper);
    
    return this;
    
  },
  
  /*
  * _setMask, internal method, to set the proper offset to each mask
  *
  * @param position, the position object of the current element
  * @param size, the size object of the current element
  *
  */
  
  _setMask : function( position, size ){
    
    var bottomTop = position.y + size.y
      , o         = this.options
    ;
    
    if( this.options.showMasks ){
    
      this.masks.top.setStyles({
        top : 0,
        height : position.y
      }).fade(o.fadeTo);
    
      this.masks.bottom.setStyles({
        height : $(document.body).getScrollSize().y - bottomTop,
        top : bottomTop
      }).fade(o.fadeTo);
    
      this.masks.left.setStyles({
        height : size.y,
        top : position.y,
        width : position.x
      }).fade(o.fadeTo);
    
      this.masks.right.setStyles({
        height : size.y,
        top : position.y,
        width: $(document.body).getSize().x - position.x - size.x
      }).fade(o.fadeTo);
    
    }
    this._setTooltip(position, size);
    
  },
  
  /*
  * _recalculateSides, internal method, needed when the window is resized (left/right masks change)
  *
  */
  
  _recalculateSides : function(){
    
    var originalPosition = this.currentElement.getPosition()
      , computedSize     = this.currentElement.getComputedSize()
      , marginTop        = ( this.currentStepElement.margin_top !== undefined ) ? this.currentStepElement.margin_top : 0
      , marginBottom     = ( this.currentStepElement.margin_bottom !== undefined ) ? this.currentStepElement.margin_bottom : 0
      , size             = { x : computedSize.totalWidth, y : computedSize.totalHeight + marginBottom + marginTop}
      , position         = { x : originalPosition.x, y : originalPosition.y - marginTop}
    ;  
    
    this.masks.left.setStyles({
      width : position.x
    });

    this.masks.right.setStyles({
      width: $(document.body).getSize().x - position.x - size.x
    });
    
    this._setTooltipPosition(size, position);
    
  },
  
  /*
  * _setTooltipPosition, internal method, to set the tooltip position
  *
  * @param position, the position object of the current element
  * @param size, the size object of the current element
  *
  */
  
  _setTooltipPosition : function(size, position){
    
    var left         = (size.x <= 50) ? position.x : position.x+50
      , originalTop  = position.y - this.currTooltip.getSize().y - 12
      , top          = ((originalTop) < 0) ? position.y + size.y + 15 : originalTop
    ;
        
    this.currTooltip.setStyles({
      left : left + (this.currentStepElement.offsetLeft || 0),
      top : top + (this.currentStepElement.offsetTop || 0)
    });
    
    if((originalTop) < 0){
      ttip.addClass('bottom');
    }else{
      ttip.removeClass('bottom');
    }
    
  },
  
  /*
  * _setTooltip, internal method, to set the tooltip guide for the element to the proper offset
  *
  * @param position, the position object of the current element
  * @param size, the size object of the current element
  *
  * NOTE: this could be optimized, without re-creating each time the tooltip, make a general html and then fill with step data
  *
  */
  
  _setTooltip : function( position, size ){
    
    var  o          = this.options
       , currStep   = this.steps[this.currentStep]
       , guide      = currStep.description
       , tooltipTpl = "<div class='"+o.stepPrefix+"-tooltip'>\
                        <div class='"+o.stepPrefix+"-hide'>"+o.labelHideAll+"</div>\
                        <div class='"+o.stepPrefix+"-tooltip-content'>"+guide+"</div>\
                        <div class='"+o.stepPrefix+"-tooltip-controls'>\
                        </div>\
                      </div>"
        , ttip      = Elements.from(tooltipTpl)[0].inject(this.masks.wrapper)
    ;
      
    ttip.getElement('.'+o.stepPrefix+'-tooltip-controls').set('html',(this.currentStep === 0) ? "<input type='button' value='"+o.labelNext+"' class='button lightblue "+o.stepPrefix+"-next' />" 
                                                                                              : (this.currentStep === this.steps.length - 1) ? "<input type='button' value='"+o.labelFinish+"' class='button orange "+o.stepPrefix+"-close' />\
                                                                                                <input type='button' value='"+o.labelPrev+"' class='button lightgray "+o.stepPrefix+"-prev' />"
                                                                                              : "<input type='button' value='"+o.labelNext+"' class='button lightblue "+o.stepPrefix+"-next' />\
                                                                                              <input type='button' value='"+o.labelPrev+"' class='button lightgray "+o.stepPrefix+"-prev' />" );
    
    this.currTooltip = ttip;
    
    this._setTooltipPosition(size, position);
    
  },
  
  /*
  * _doStep, internal method, to create the step for each element
  *
  */
  
  _doStep : function(){
    
    var currStep = this.steps[this.currentStep];
    
    this.currentStepElement = currStep;
    this.currentElement = $(currStep.id);
    
    this.masks.wrapper.getElements('div.guide-step-tooltip').destroy();
    
    var originalPosition = this.currentElement.getPosition()
      , computedSize     = this.currentElement.getComputedSize()
      , marginTop        = ( currStep.margin_top !== undefined ) ? currStep.margin_top : 0
      , marginBottom     = ( currStep.margin_bottom !== undefined ) ? currStep.margin_bottom : 0
      , size             = { x : computedSize.totalWidth, y : computedSize.totalHeight + marginBottom + marginTop}
      , position         = { x : originalPosition.x, y : originalPosition.y - marginTop}
    ;
    
    this._setMask(position, size);
    
    var tooltip = this.currTooltip,
        scrollTopOffset = (tooltip.hasClass('bottom')) ? tooltip.getPosition().y - size.y - 20 : tooltip.getPosition().y - 10;
    
    var myFx = new Fx.Scroll($(document.body), {
        offset: {
            x: 0,
            y: scrollTopOffset
        }
    }).toTop();
    
    //var elemScroll = new Fx.Scroll().toElement(this.masks.wrapper.getElement('.guide-step-tooltip')); //need Fx.Scroll
    
  },
  
  /*
  * _nextStep, internal method, to go to the next tour step
  *
  */
  
  _nextStep : function(){
    
    if( this.currentStep < this.steps.length - 1 ){
    
      this.currentStep++;
      
      this._doStep();
      
    }
    
  },
  
  /*
  * _prevStep, internal method, to go to the previous tour step
  *
  */
  
  _prevStep : function(){
    
    if( this.currentStep >= 0 ){
      
      this.currentStep--;
      
      this._doStep();
      
    }
    
  },
  
  
  /*
  * PUBLIC METHODS
  *
  * Pretty self explanatory
  */
  
  start : function(){
    
    if( !this.started ){
      this.started = true;
      this._nextStep();
      window.addEvent('resize', this._recalculateSides.bind(this));
    }
    
  },
  
  restart : function(){
    
    this.masks.wrapper.fade(1);
    this.masks.wrapper.setStyle('display','block');
    
    this.currentStep = -1;
    this.currentElement = null;
    this.currentStepElement = null;
    
    this._nextStep();
    
  },
  
  closeTour : function(){
    
    this.masks.wrapper.fade(0).get('tween').chain(function(){
      this.masks.wrapper.setStyle('display','none');
      this.fireEvent('closed');
    }.bind(this));

  }
  
});