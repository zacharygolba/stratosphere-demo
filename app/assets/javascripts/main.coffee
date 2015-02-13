class @StratosphereDemo
  constructor: -> return this

class @StratosphereDemo.Object
  set: (property, value=null) => @[property] = value
 
  incrementProperty: (property, value=1) => @[property] += value if @hasOwnProperty property and typeof @[property] is 'number'

  get: (property='') =>
    result = this
    if property.search '.' > 0
      properties = property.split '.'
      for prop in properties
        break if result is null
        result = if result.hasOwnProperty prop then result[prop] else null
    else
      result = if @hasOwnProperty property then @[property] else null
    return result
    
class @StratosphereDemo.InfiniteScroll extends StratosphereDemo.Object
  model: ''
  element: null
  hasRows: false
  isLoading: false
  totalPages: null
  currentPage: 1

  @getPage: (model, page) ->
    self = this
    return new RSVP.Promise (resolve, reject) ->
      $.ajax
        type: 'GET'
        url: model.pluralize()
        data:
          page: page
        headers:
          'X-CSRF-Token': self.csrfToken
        success: (e, data, xhr) ->
          resolve xhr.responseText
        error: (xhr, status, error) ->
          reject error
    
  constructor: (container) ->
    @set 'element', container
    @set 'didPaginate', new Event('did-paginate')
    @set 'hasRows', @get('element.dataset.hasRows') is 'true'
    @set 'currentPage', 1
    @set 'totalPages', parseInt @get('element.dataset.totalPages')
    @set 'model', @get('element.dataset.model')

    $(window).on 'scroll', @handleScroll

  handleScroll: =>
    if !@get('isLoading') and @get('currentPage') < @get('totalPages')
      $window = $(window)
      if $window.scrollTop() + $window.height() >= document.body.scrollHeight - 300
        @set 'isLoading', true
        @nextPage().then (instance) ->
          instance.set 'isLoading', false
          document.dispatchEvent instance.get 'didPaginate'

  nextPage: =>
    self = this
    $container = $( @get('element') )
    return new RSVP.Promise (resolve, reject) ->
      if self.get('currentPage') < self.get('totalPages')
        self.set 'currentPage', self.get('currentPage') + 1
        self.constructor.getPage(self.get('model'), self.get('currentPage')).then (html) ->
          if self.get 'hasRows'
            $res        = $(document.createElement 'div').html html
            $row        = $(document.createElement 'div').addClass('row animated fadeInUp').css 'opacity', 0
            $lastRow    = $('.row:last-of-type')
            $lrChildren = $lastRow.find('.col-sm-4')
            index       = 0
            elements    = $.makeArray $res.find('.col-sm-4')
            $row.one 'webkitAnimationEnd mozAnimationEnd MSAnimationEnd oanimationend animationend', -> $row.removeClass 'animated fadeInUp'
            if $lrChildren.length < 3
              while 3 - $lrChildren.length > index
                break if elements.length is 0
                $lastRow.append elements.shift()
                index++
            for element, i in elements
              $row.append element
              if (i + 1) % 3 is 0
                $container.append $row
                $row.imagesLoaded -> $row.css 'opacity', ''
                $row = $(document.createElement 'div').addClass('row animated fadeInUp').css 'opacity', 0
                $row.one 'webkitAnimationEnd mozAnimationEnd MSAnimationEnd oanimationend animationend', -> $row.removeClass 'animated fadeInUp'
              else if (i + 1) % 3 isnt 0 and (i + 1) is elements.length
                $container.append $row
                $row.imagesLoaded -> $row.css 'opacity', ''
          else
            $container.append html
          resolve self
        , (error) ->
          resolve error
            
class @StratosphereDemo.App extends StratosphereDemo.Object
  videoPlayer: null
  isMobile: false
  isPaginated: false
  infiniteScroll: null
  csrfToken: null
  currentRoute:
    controller: null
    action: null

  constructor: ->
    @set 'isMobile', /android|iphone|ipod|ipad|blackberry|mini|windows phone|kf|palm|blackberry|bb/i.test window.navigator.userAgent
    @set 'csrfToken', $('meta[name=csrf-token]').attr 'content'
    @set 'isPaginated', $('*[data-paginated]').length > 0
    @set 'infiniteScroll', new StratosphereDemo.InfiniteScroll( $('*[data-paginated]')[0] ) if @get 'isPaginated'
    @set 'currentRoute', {
      controller: document.body.dataset.controllerName
      action: document.body.dataset.controllerAction
    }

  doAction: (e) =>
    e.preventDefault()
    $target = $(e.target)
    switch $target.data 'perform'
      when 'edit'
        Turbolinks.visit "/#{$target.data('model').pluralize()}/#{$target.data('id')}/edit"
      when 'create'
        @createRecord $target.data('model')
      when 'delete'
        @destroyRecord $target.data('model'), $target.data('id')
      when 'back'
        if @get('currentRoute.action') is 'edit'
          if @get('currentRoute.controller') is 'documents'
            Turbolinks.visit '/documents'
          else
            Turbolinks.visit window.location.pathname.replace('/edit', '')
        else
          Turbolinks.visit "/#{@get('currentRoute.controller')}"

  positionFooter: =>
    $footer = $('#footer')
    if window.innerHeight < document.body.scrollHeight
      $footer.removeClass 'fixed'
    else
      $footer.addClass 'fixed'

  handleScroll: =>
    $window = $(window)
    $navbar = $('#navbar')
    if $window.scrollTop() > 0 and document.body.scrollHeight > $window.height()
      $navbar.addClass 'has-shadow'
    else
      $navbar.removeClass 'has-shadow'

  handleResize: =>
    @positionFooter()
    if !!@get 'videoPlayer'
      p = @get 'videoPlayer'
      w = $('.container').width()
      h = Math.round (9/16) * w
      p.width w
      p.height h

  handlePagination: =>
    self = this
    $('*[data-perform]').off 'click', @doAction
    $('*[data-perform]').on 'click', @doAction
    $( @get('infiniteScroll.element') ).imagesLoaded -> self.positionFooter()

  createRecord: (model) ->
    if !!model
      self = this
      data = {}
      switch model
        when 'document'
          data['document'] = 'name': 'New Document'
        when 'post'
          data['post'] = 'title': 'New Post'
        when 'music_video'
          data['music_video'] = 'title': 'New Music Video'
      $.ajax
        type: 'POST'
        url: "/#{model.pluralize()}"
        data: data
        headers:
          'X-CSRF-Token': self.get('csrfToken')
          'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'
        success: (e, data, xhr) ->
          json = JSON.parse xhr.responseText
          if !!json and json.hasOwnProperty 'id'
            Turbolinks.visit "/#{model.pluralize()}/#{json.id}/edit"

  destroyRecord: (model, id) ->
    if !!model and !!id
      self = this
      noty
        type: 'alert'
        text: "Are you sure you want to delete #{model.replace('_', ' ').titleize()}: #{id}?"
        theme: 'relax'
        layout: 'center'
        timeout: 3000
        animation:
          open: 'animated flipInX'
          close: 'animated flipOutX'
          speed: 300
        buttons: [
          {
            addClass: 'btn btn-xs btn-primary'
            text: 'Cancel'
            onClick: ($noty) ->
              didConfirm = false
              $noty.close()
          },
          {
            addClass: 'btn btn-xs btn-danger'
            text: 'Yes'
            onClick: ($noty) ->
              $noty.close()
              $.ajax
                type: 'DELETE'
                url: "/#{model.pluralize()}/#{id}"
                headers:
                  'X-CSRF-Token': self.get('csrfToken')
                success: ->
                  Turbolinks.visit "/#{model.pluralize()}"

                  $(document).one 'page:change', ->
                    setTimeout ->
                      noty
                        type: 'success'
                        text: " #{model.replace('_', ' ').titleize()}: #{id} successfully deleted!"
                        theme: 'relax'
                        layout: 'top'
                        timeout: 3000
                        animation:
                          open: 'animated flipInX'
                          close: 'animated flipOutX'
                          speed: 300
                    , 200
          }
        ]

$(document).on 'page:change', ->
  $body          = $('body')
  $window        = $(window)
  $document      = $(document)
  $buttons       = $('*[data-perform]')
  stratosphere   = new StratosphereDemo.App()
  currentRoute   = stratosphere.get('currentRoute')

  Turbolinks.enableProgressBar()

  if stratosphere.get('currentRoute.controller') isnt 'home'
    $body.addClass 'has-navbar'
    $.each $('#navbar a'), (idx, obj) ->
      $link = $(obj)
      if new RegExp("#{stratosphere.get('currentRoute.controller')}-.+", 'g').test $link.data('route')
        $link.addClass 'active'
      else
        $link.removeClass 'active'
  else
    $body.removeClass 'has-navbar'
    
  if stratosphere.get('currentRoute.controller') is 'music_videos' and ['show', 'edit'].indexOf stratosphere.get('currentRoute.action') >= 0
    $video = $('video')
    
    $video.addClass 'video-js vjs-default-skin vjs-big-play-centered' if stratosphere.get('currentRoute.action') is 'edit'
    
    $body.imagesLoaded ->
      if !!$video[0]
        videojs $video[0], {}, ->
          w = $('.container').width()
          h = Math.round (9/16) * w
          this.width w
          this.height h
          stratosphere.set 'videoPlayer', this

  $body.imagesLoaded -> stratosphere.positionFooter()

  $window.on 'resize', stratosphere.handleResize
  $window.on 'scroll', stratosphere.handleScroll
  $document.on 'did-paginate', stratosphere.handlePagination
  $buttons.on 'click', stratosphere.doAction

  $document.one 'page:before-unload', ->
    stratosphere.videoPlayer.dispose() if !!stratosphere.get('videoPlayer') and typeof stratosphere.get('videoPlayer.dispose') is 'function'
    $window.off 'resize'
    $window.off 'scroll'
    $document.off 'did-paginate'
    $buttons.off 'click', stratosphere.doAction