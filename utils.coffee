window.Tether ?= {}

getScrollParent = (el) ->
  position = getComputedStyle(el).position

  if position is 'fixed'
    return el

  scrollParent = undefined

  parent = el
  while parent = parent.parentNode
    unless style = getComputedStyle parent
      return parent

    if /(auto|scroll)/.test(style['overflow'] + style['overflow-y'] + style['overflow-x'])
      if position isnt 'absolute' or style['position'] in ['relative', 'absolute', 'fixed']
        return parent

  return document.body

getSize = (el, outer=false) ->
  style = getComputedStyle el
  boxModel = style['box-sizing']

  out = {}
  for dim in ['height', 'width']
    if dim is 'height'
      edges = ['top', 'bottom']
    else
      edges = ['left', 'right']

    size = parseFloat style[dim]

    if outer
      for edge in edges
        if boxModel isnt 'border-box'
          size += parseFloat style["padding-#{ edge }"]
          size += parseFloat style["border-#{ edge }-width"]
    else
      for edge in edges
        if boxModel is 'border-box'
          size -= parseFloat style["padding-#{ edge }"]
          size -= parseFloat style["border-#{ edge }-width"]

    out[dim] = size

  out

getOuterSize = (el) ->
  getSize el, true

getOffset = (el) ->
  doc = el.ownerDocument.documentElement

  box = el.getBoundingClientRect()

  {
    top: box.top + window.pageYOffset - doc.clientTop
    left: box.left + window.pageXOffset - doc.clientLeft
  }

getOffsetParent = (el) ->
  el.offsetParent or document.documentElement

extend = (out={}) ->
  args = []
  Array::push.apply(args, arguments)

  for obj in args[1..] when obj
    for own key, val of obj
      out[key] = val

  out

removeClass = (el, name) ->
  if el.classList?
    el.classList.remove(cls) for cls in name.split(' ')
  else
    el.className = el.className.replace new RegExp("(^| )#{ name.split(' ').join('|') }( |$)", 'gi'), ' '

addClass = (el, name) ->
  if el.classList?
    el.classList.add(cls) for cls in name.split(' ')
  else
    removeClass el, name
    el.className += " #{ name }"

hasClass = (el, name) ->
  if el.classList?
    el.classList.contains(name)
  else
    new RegExp("(^| )#{ name }( |$)", 'gi').test(el.className)

class Evented
  on: (event, handler, ctx, once=false) ->
    @bindings ?= {}
    @bindings[event] ?= []
    @bindings[event].push {handler, ctx, once}

  once: (event, handler, ctx) ->
    @on(event, handler, ctx, true)

  off: (event, handler) ->
    return unless @bindings?[event]?

    if not handler?
      delete @bindings[event]
    else
      i = 0
      while i < @bindings[event].length
        if @bindings[event][i].handler is handler
          @bindings[event].splice i, 1
        else
          i++

  trigger: (event, args...) ->
    if @bindings?[event]
      i = 0
      while i < @bindings[event].length
        {handler, ctx, once} = @bindings[event][i]

        handler.apply(ctx ? @, args)

        if once
          @bindings[event].splice i, 1
        else
          i++

Tether.Utils = {getScrollParent, getSize, getOuterSize, getOffset, getOffsetParent, extend, addClass, removeClass, hasClass, Evented}
