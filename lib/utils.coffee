# http://stackoverflow.com/a/359910/472768
callFunctionByName = (funcName, ctxt) ->
  args = [].splice.call(arguments).splice(2)
  namespaces = funcName.split('.')
  func = namespaces.pop()
  ctxt = ctxt[namespaces[i]] for i in namespaces
  return ctxt[func].apply(this, args)