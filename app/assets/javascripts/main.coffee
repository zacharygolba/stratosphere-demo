class @Application
  videoPlayer: null
  isMobile: false
  didPaginate: null
  isPaginated: false
  isPaginating: false
  csrfToken: null
  currentPage: 1
  currentRoute: 
    controller: null
    action: null

  constructor: ->
    @navbar       = document.getElementById 'navbar'
    @footer       = document.getElementById 'footer'
    @isMobile     = /android|iphone|ipod|ipad|blackberry|mini|windows phone|kf|palm|blackberry|bb/i.test window.navigator.userAgent
    @csrfToken    = $('meta[name=csrf-token]').attr 'content'
    @isPaginated  = $('*[data-paginated]').length > 0
    @didPaginate  = new Event('did-paginate')
    @currentRoute.controller = document.body.dataset.controllerName
    @currentRoute.action = document.body.dataset.controllerAction
        
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
          'X-CSRF-Token': self.csrfToken
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
                  'X-CSRF-Token': self.csrfToken
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
        
  infiniteScroll: ->
    self       = this
    $window    = $(window)
    $container = $('*[data-paginated]')
    if @isPaginating is false and @currentPage < parseInt( $container.data('totalPages') ) and $window.scrollTop() + $window.height() >= document.body.scrollHeight - 300
      @isPaginating = true
      @currentPage++
      $.ajax
        type: 'GET'
        url: "/#{"#{$container.data('model')}".pluralize()}"
        data:
          page: @currentPage
        headers:
          'X-CSRF-Token': self.csrfToken
        success: (e, data, xhr) ->
          if $container.data('has-rows')
            $res        = $(document.createElement 'div').html(xhr.responseText)
            $row        = $(document.createElement 'div').addClass('row animated fadeInUp').css 'opacity', 0
            $lastRow    = $('.row:last-of-type')
            index       = 0
            elements    = $.makeArray $res.find('.col-sm-4')
            $lrChildren = $lastRow.find('.col-sm-4')
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
                $row.one 'webkitAnimationEnd mozAnimationEnd MSAnimationEnd oanimationend animationend', -> 
                  $row.removeClass 'animated fadeInUp'
              else if (i + 1) % 3 isnt 0 and (i + 1) is elements.length
                $container.append $row
                $row.imagesLoaded -> $row.css 'opacity', ''
          else
            $container.append xhr.responseText  
          self.isPaginating = false
          document.dispatchEvent self.didPaginate

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
        if @currentRoute.action is 'edit'
          if @currentRoute.controller is 'documents'
            Turbolinks.visit '/documents'
          else
            Turbolinks.visit window.location.pathname.replace('/edit', '')
        else
          Turbolinks.visit "/#{@currentRoute.controller}"
          
  positionFooter: =>
    $footer = $('#footer')
    if window.innerHeight < document.body.scrollHeight
      $footer.removeClass 'fixed'
    else
      $footer.addClass 'fixed'
          
$(document).on 'page:change', ->
  $body        = $('body')
  $window      = $(window)
  $buttons     = $('*[data-perform]')
  stratosphere = new Application()
  currentRoute = stratosphere.currentRoute
  
  Turbolinks.enableProgressBar()

  if currentRoute.controller isnt 'home'
    $body.addClass 'has-navbar'
    $.each $('#navbar a'), (idx, obj) ->
      $link = $(obj)
      if new RegExp("#{currentRoute.controller}-.+", 'g').test $link.data('route')
        $link.addClass 'active'
      else
        $link.removeClass 'active'
  else
    $body.removeClass 'has-navbar'
    
  if currentRoute.controller is 'music_videos' and ['show', 'edit'].indexOf currentRoute.action >= 0
    $video = $('video')
    
    $video.addClass 'video-js vjs-default-skin vjs-big-play-centered' if currentRoute.action is 'edit'
    
    $body.imagesLoaded ->
      if !!$video[0]
        videojs $video[0], {}, ->
          w = $('.container').width()
          h = Math.round (9/16) * w
          this.width w
          this.height h
          stratosphere.videoPlayer = this

  $body.imagesLoaded ->
    stratosphere.positionFooter()

  $buttons.on 'click', stratosphere.doAction
  
  $window.on 'resize', ->
    stratosphere.positionFooter()
    if !!stratosphere.videoPlayer
      w = $('.container').width()
      h = Math.round (9/16) * w
      stratosphere.videoPlayer.width w
      stratosphere.videoPlayer.height h
      
  $window.on 'scroll', ->
    $navbar = $('#navbar')
    stratosphere.infiniteScroll() if stratosphere.isPaginated
    if $window.scrollTop() > 0 and document.body.scrollHeight > $window.height()
      $navbar.addClass 'has-shadow'
    else
      $navbar.removeClass 'has-shadow'
    
  $(document).on 'did-paginate', ->
    $buttons = $('*[data-perform]')
    $buttons.off 'click', stratosphere.doAction
    $buttons.on 'click', stratosphere.doAction

  $(document).one 'page:before-unload', ->
    stratosphere.videoPlayer.dispose() if !!stratosphere.videoPlayer and typeof stratosphere.videoPlayer is 'function'
    $window.off 'resize'
    $window.off 'scroll'
    $buttons.off 'click'