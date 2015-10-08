Request = global.require "request-promise"

module.exports =
class Player
    constructor : ->
        @_mp4player = document.createElement("video")
        @_mp4player.style.display = "none"
        @_mp4player.autoplay = true

        @_handleEvents()
        @_handleNsenEvents()

    _handleEvents : ->
        $ =>
            document.body.appendChild(@_mp4player)

        app.nsenStream.onDidChangeStream =>
            @_handleNsenEvents()

        app.config.observe "nco.player.enabled", (enabled) =>
            if enabled is no
                @_mp4player.pause()
            else
                @_loadMovie()

            return

        app.config.observe "nco.player.volume", (volume) =>
            @_mp4player.volume = volume

    _handleNsenEvents : ->
        channel = app.nsenStream.getStream()
        return unless channel?

        channel.onDidChangeMovie (movie) =>
            return if app.config.get("nco.player.enabled", no) is no
            @_loadMovie()


    _loadMovie : ->
        nicoSession = app.getSession()
        channel = app.nsenStream.getStream()
        movie = channel?.getCurrentVideo()

        return unless nicoSession? or channel? or movie?
        return if app.config.get("nco.player.enabled", false) is false

        Request.get
            resolveWithFullResponse : true
            url : "http://www.nicovideo.jp/watch/#{movie.id}"
            jar : nicoSession.cookie
        .then (res) =>
            browserSession = app.currentWindow.browserWindow.webContents.session
            cookies = @_translateToughCookieToElectronSettable(nicoSession.cookie.getCookies("http://www.nicovideo.jp/"))
            cookies.forEach (cookie) ->
                browserSession.cookies.set cookie, (err) ->
                    console.error err if err?

            movie.fetchGetFlv()

        .then (result) =>
            switch movie.get("movieType")
                when "mp4"
                    @_mp4player.src = result.url
                    @_mp4player.play()

                when "flv"
                    @_flvPlayer.setAttribute("data", result.url)

        .catch =>
            console.log arguments


    _translateToughCookieToElectronSettable : (cookies) ->
        cookies.map (cookie) ->
            {
                url : "http://" + cookie.domain
                name : cookie.key
                value : cookie.value
                domain : cookie.domain
                path : cookie.path
                secure : false
                session : false
                expirationDate : +cookie.expires
            }