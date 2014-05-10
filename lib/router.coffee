Reaction.Router = {
  # Routes will be an object in this format:
  # {
  #   '_root': 'RootComponent'
  #   'about': 'AboutComponent'
  #   'contact': 'ContactComponent'
  # }
  _routes: {}
  _t: this
  renderComponent: (componentName) ->
    component = callFunctionByName(componentName, Reaction)
    # TODO: If component is undefined, render generic error
    React.renderComponent(component, document.getElementById('root'))
  renderError: (errorCode) ->
    componentName = 'Error' + errorCode  # Error components should be named Error404, Error403, etc
    renderComponent(componentName)
  renderRoute: (routeName) ->
    componentName = if (routeName.length == 0 or routeName == '/') then _t._routes._root else _t.routes[pathname]
    if typeof componentName == 'undefined'  # No route defined
      renderError(404)
      return
    renderComponent(componentName)
  route: (routes) ->
    _t._routes = routes
  start: ->
    pathName = window.location.pathname.slice(1)
    renderRoute(pathName)
    
    popped = ('state' in window.history)
    initialURL = location.href
    $(window).bind('popstate', (event) ->
      initialPop = !popped && location.href == initialURL
      popped = true
      return if initialPop
      renderRoute('/')
    )
}