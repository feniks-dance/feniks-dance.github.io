angular.module('Feniks', []).config([
  '$interpolateProvider', ($interpolateProvider) ->
    $interpolateProvider.startSymbol('[[')
    $interpolateProvider.endSymbol(']]')
]).controller('Main', ($scope, $timeout, $window, $interval, $http) ->
  $scope.path = $scope.page = $window.location.pathname
  if $scope.path.indexOf("photo") != -1
    $scope.page = '/photo/'
  $scope.boxBlink = true
  $scope.videos = []
  changePhoto = true
  groupPhotos =
    true: 'TXa4PJIv18g',
    false: 't6G67b6D_qQ'
  $scope.groupPhoto = groupPhotos[changePhoto];
  if $scope.page == '/about/'
    $interval(->
      changePhoto = !changePhoto
      $scope.groupPhoto = groupPhotos[changePhoto];
    , 5000)

  $http.get("https://www.googleapis.com/youtube/v3/search?part=snippet&channelId=UCgUafpxg3uzUhhMHmzwIfdA&maxResults=10&order=date&key=AIzaSyCOoMERRE9_xHJ94AWLFKpgNDXXzfwqWWw").success(
    (response) ->
      angular.forEach(response.items, (video) ->
        return if !video.id.videoId
        $scope.videos.push({
          id:video.id.videoId,
          title: video.snippet.title,
          description: video.snippet.description
          img: video.snippet.thumbnails.high.url
        })
      )
      $timeout(->
        $scope.$broadcast('initColorboxVideo')
      , 100)
  ).error((error) ->
      console.info("Youtube error: ", error)
  )
  off
).directive('autoHeight', ($window) ->
  restrict: 'AC'
  link: (scope, elm, attrs) ->
    height = $window.innerHeight
    scope[attrs.autoHeight + "MinHeight"] = height - 170 + 'px'
    $window.onresize = (e) ->
      height = $window.innerHeight
      scope[attrs.autoHeight + "MinHeight"] = height - 170 + 'px'
).directive('theBox', ($interval) ->
  restrict: 'C'
  link: (scope, elm, attrs) ->
    $interval(->
      scope.boxBlink = !scope.boxBlink
    , 1000)
).directive('colorbox', ->
  restrict: 'A'
  link: (scope, elm, attrs) ->
    opts =
      rel: 'box',
      title: () ->
        return jQuery(this).attr('title') || ""
      ,
      width: "70%",
      maxHeight: "95%",
      current: "{current} из {total}"
    if attrs.colorbox == 'artists'
      opts.current = ""
    elm.find(".box").colorbox(opts)
    scope.$on('initColorboxVideo', ->
      elm.find(".youtube").colorbox(
        iframe:true
        innerWidth:640
        innerHeight:390
      )
    )
).directive('imgCenter', () ->
  {
  restrict: 'A'
  link: (scope, elm) ->
    elm.load(->
      width = this.naturalWidth
      height = this.naturalHeight
      elm.parent().css({position: "relative"})
      if width / height > 1
        elm.css(
          "position": "absolute"
          "height": "auto"
          "width": "#{elm.parent().width()}px"
          "margin-top": -height * elm.parent().width() / width / 2 + "px"
          "top": "50%"
          "left": "0"
        )
      else
        elm.css(
          "position": "absolute"
          "height": "#{elm.parent().height()}px"
          "width": "auto"
          "margin-left": -width * elm.parent().height() / height / 2 + "px"
          "left": "50%"
          "top": "0"
        )
    )
  }
)