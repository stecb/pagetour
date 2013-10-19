# step declaration
guide = [
  {'selector': '#element', 'description': 'description', position: 'bottom', fixed: true}
  {'selector': '#element1', 'description': 'description', position: 'top', fixed: true}
  {'selector': '#element2', 'description': 'description', position: 'top', fixed: true}
]

# pagetour instance
pt = $.pageTour(guide)

# start it
pt.start()
