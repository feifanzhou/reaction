Reaction.Router = {
  # Routes will be an object in this format:
  # {
  #   '_root': 'RootComponent'
  #   'about': 'AboutComponent'
  #   'contact': 'ContactComponent'
  # }
  _routes: {}
  _t: this
  getCurrentPath: ->
    window.location.pathname.slice(1)
  renderComponent: (componentName, params) ->
    params = if (typeof params == 'undefined') then {} else params
    component = callFunctionByName(componentName, Reaction, params)
    # TODO: If component is undefined, render generic error
    React.renderComponent(component, document.getElementById('root'))
  renderError: (errorCode) ->
    componentName = 'Error' + errorCode  # Error components should be named Error404, Error403, etc
    renderComponent(componentName)
  renderRoute: (routeName, shouldPush) ->
    shouldPush = if (typeof shouldPush == 'undefined') then true else shouldPush  # Push by default
    state = { currPath: getCurrentPath() }
    window.history.pushState(state, '', routeName) if shouldPush
    componentName = if (routeName.length == 0 or routeName == '/') then _t._routes._root else _t.routes[pathname]
    if typeof componentName == 'undefined'  # No direct match
      # Try to find matching pattern
      param_map = {} # Map from param name to corresponding parameter in routeComponents
      for key of _t._routes
        if _t._routes.hasOwnProperty(key)
          components = key.split('/')
          routeComponents = routeName.split('/')
          if components.length != routeComponents.length
            renderError(404)
            return
          for comp, index of components
            if comp.charAt(0) == ':'
              # comp[index] = /\w/i   # Replace with component position with regex
              param_map[comp.substring(1)] = routeComponents[index] # Get name of param, assign it value from URL
            else # Must be direct match
              if comp != routeComponents[index] # Not direct match
                renderError(404)
                return
    renderComponent(componentName, param_map)
  route: (routes) ->
    _t._routes = routes
  start: ->
    pathName = getCurrentPath()
    renderRoute(pathName)
    
    # popped = ('state' in window.history)
    # initialURL = location.href
    # $(window).bind('popstate', (event) ->
    #   initialPop = !popped && location.href == initialURL
    #   popped = true
    #   return if initialPop
    #   renderRoute('/')
    # )
    
    window.onpopstate = (event) ->
      lastPath = event.state.currPath  # event.state will be state from target page, not current page
      if typeof lastPath == 'undefined'  # No previous path
        renderRoute('/', false)  # Probably should render root rather than 404, right?  # Don't push old state again
        return
      currPath = getCurrentPath()
      if lastPath == currPath  # Same path
        return
      renderRoute(lastPath)
}