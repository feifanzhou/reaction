Reaction.Router = {
  # Routes will be an object in this format:
  # {
  #   '_root': 'RootComponent'
  #   'about': 'AboutComponent'
  #   'contact': 'ContactComponent'
  # }
  _routes: {}
  _target: null
  getCurrentPath: ->
    window.location.pathname.slice(1)
  initialize: (routes, target) ->
    @_target = target
    @route(routes)
    @start()
  linkTo: (routeName) ->  # Programatically trigger link
    @renderRoute(routeName, true)
  renderComponent: (componentName, params) ->
    params = if (typeof params == 'undefined') then {} else params
    component = callFunctionByName(componentName, Reaction, params)
    # TODO: If component is undefined, render generic error
    React.renderComponent(component, @_target || document.getElementById('root'))
  renderError: (errorCode) ->
    componentName = 'Error' + errorCode  # Error components should be named Error404, Error403, etc
    @renderComponent(componentName)
  renderRoute: (routeName, shouldPush) ->
    shouldPush = if (typeof shouldPush == 'undefined') then true else shouldPush  # Push by default
    state = { currPath: @getCurrentPath() }
    if shouldPush
      window.history.pushState(state, '', routeName)
    else
      window.history.replaceState(state, '', routeName)  # Going to a new route — still need to change the location!
    componentName = if (routeName.length == 0 or routeName == '/') then @_routes['_root'] else @_routes[routeName]
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
    _this = this
    
    # Hijack all links
    # Hijacking: https://gist.github.com/tbranyen/1142129
    # Adding event listener: http://wordpressapi.com/add-event-image-elements-javascript/
    # Because it's getting all anchor elements on page
    # reaction should be included at bottom of page
    links = document.getElementsByTagName('a')
    anchor.addEventListener('click', (event) ->
      href = event.target.getAttribute('href')
      _this.renderRoute(href) if href.length > 0
    ) for anchor in links

    # Handle popstate 
    window.onpopstate = (event) ->
      return if (typeof event.state == 'undefined') or (event.state == null) or (typeof event.state.currPath == 'undefined') # No last state (maybe on page load, fired by Webkit)
      lastPath = event.state.currPath  # event.state will be state from target page, not current page
      if typeof lastPath == 'undefined'  # No previous path
        _this.renderRoute('/', false)  # Probably should render root rather than 404, right?  # Don't push old state again
        return
      currPath = _this.getCurrentPath()
      return if lastPath == currPath  # Same path
      _this.renderRoute(lastPath, false)
}