var guide, pt;

guide = [
  {
    'selector': '#element',
    'description': 'description',
    position: 'bottom',
    fixed: true
  }, {
    'selector': '#element1',
    'description': 'description',
    position: 'top',
    fixed: true
  }, {
    'selector': '#element2',
    'description': 'description',
    position: 'top',
    fixed: true
  }
];

pt = $.pageTour(guide);

pt.start();