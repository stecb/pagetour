# jQuery pageTour

## A _tooltipized_ guide for your website/webapp. Implement it a blink of an eye!

### *Important:* Demo + Css coming soon! (see template inside the code if you don't want to wait)

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

* ```prefix : 'pagetour' // needed for css and custom events, default set to 'pagetour' ```
* ```labelNext : 'next' // next step label, default set to 'next' ```
* ```labelPrev : 'prev' // next step label, default set to 'prev' ```
* ```labelFinish : 'done!' // laste step done label, default set to 'done!' ```
* ```labelHideAll : 'x' // close the tour label, default set to 'x'.. can also be an img, by css ```
* ```autoStart : false // if you want to automatically start the tour, default set to false```
* ```fadeTo : 0.8 // target opacity for the mask, default set to 0.8```
* ```showMasks : true // if you want to show mask or not, default set to true```

  To override default options, just pass as second argument an object with your custom options

#### Events
  coming soon

#### Styling
  coming soon
