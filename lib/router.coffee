Reaction.Router = {
  # Routes will be an object in this format:
  # {
  #   '_root': 'RootComponent'
  #   'about': 'AboutComponent'
  #   'contact': 'ContactComponent'
  # }
  _routes: {}
  getCurrentPath: ->
    window.location.pathname.slice(1)
  renderComponent: (componentName, params) ->
    params = if (typeof params == 'undefined') then {} else params
    component = callFunctionByName(componentName, Reaction, params)
    # TODO: If component is undefined, render generic error
    React.renderComponent(component, document.getElementById('root'))
  renderError: (errorCode) ->
    componentName = 'Error' + errorCode  # Error components should be named Error404, Error403, etc
    @renderComponent(componentName)
  renderRoute: (routeName, shouldPush) ->
    shouldPush = if (typeof shouldPush == 'undefined') then true else shouldPush  # Push by default
    state = { currPath: @getCurrentPath() }
    window.history.pushState(state, '', routeName) if shouldPush
    componentName = if (routeName.length == 0 or routeName == '/') then @_routes['_root'] else @routes[pathname]
    if typeof componentName == 'undefined'  # No direct match
      # Try to find matching pattern
      param_map = {} # Map from param name to corresponding parameter in routeComponents
      for key of @_routes
        if @_routes.hasOwnProperty(key)
          components = key.split('/')
          routeComponents = routeName.split('/')
          if components.length != routeComponents.length
            @renderError(404)
            return
          for comp, index of components
            if comp.charAt(0) == ':'
              # comp[index] = /\w/i   # Replace with component position with regex
              param_map[comp.substring(1)] = routeComponents[index] # Get name of param, assign it value from URL
            else # Must be direct match
              if comp != routeComponents[index] # Not direct match
                @renderError(404)
                return
    @renderComponent(componentName, param_map)
  route: (routes) ->
    @_routes = routes
  start: ->
    pathName = @getCurrentPath()
    @renderRoute(pathName)
    
    window.onpopstate = (event) ->
      return if (typeof event.state == 'undefined') or (typeof event.state.currPath == 'undefined') # No last state (maybe on page load, fired by Webkit)
      console.log('Onpopstate state: ' + JSON.stringify(event.state))
      console.log('Onpopstate currPath: ' + JSON.stringify(event.state.currPath))
      lastPath = event.state.currPath  # event.state will be state from target page, not current page
      if typeof lastPath == 'undefined'  # No previous path
        @renderRoute('/', false)  # Probably should render root rather than 404, right?  # Don't push old state again
        return
      currPath = @getCurrentPath()
      return if lastPath == currPath  # Same path
      @renderRoute(lastPath)
}