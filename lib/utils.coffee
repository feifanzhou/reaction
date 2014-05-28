# http://stackoverflow.com/a/359910/472768
# TODO: Trigger error (404, 500, whatever) if this function throws an error
callFunctionByName = (funcName, ctxt) ->
  # args = [].splice.call(arguments).splice(2)
  args = arguments[2]
  namespaces = funcName.split('.')
  func = namespaces.pop()
  ctxt = ctxt[namespaces[i]] for i in namespaces
  if typeof ctxt[func] == 'undefined' or ctxt[func] == null
    return
  else
    return ctxt[func].apply(this, args)

hasLocalStorage = ->
  return typeof(Storage) != `void(0)` || typeof(Storage) != 'undefined'