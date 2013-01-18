# PageTour

## A _tooltipized_ guide for your website/webapp. Implement it a blink of an eye!

### **Important:** Demo + Css coming soon! (see template inside the code if you don't want to wait)

---

#### To use it, create a simple array of steps:

```JavaScript
  // a step is an Object:
  var step_one = {
      'selector' : '#element_id' // or whatever selector (must match 1 and only 1 element of the DOM)
    , 'description' : 'The guide text/html for that particular element'
    /* optional */
    , 'position' : 'left|right|top|bottom' // if you want to override the *smart* calculation and force the position of the guide tooltip
    , 'padding' : Number // > 0 ..if you want to give some padding to the current step element, i.e. if the selector matches a label/link
    , 'offsetLeft' : Number // Can be negative. Force the tooltip to move X px to the left
    , 'offsetTop' : Number // Can be negative. Force the tooltip to move X px to the top
  };
  
  // once you created your array of steps, just instantiate your guide:
  var my_page_guide = $.pageTour([step_one, step_two /* ... */], {/* options */});
  // start it
  my_page_guide.start();
```

#### Options

* ```prefix : String``` // needed for css and custom events, default set to 'pagetour'
* ```labelNext : String``` // next step label, default set to 'next'
* ```labelPrev : String``` // next step label, default set to 'prev'
* ```labelFinish : String``` // next step label, default set to 'Done!'
* labelHideAll : 'x'
* autoStart : false
* mainContent : false
* fadeTo : 0.8
* showMasks : true


