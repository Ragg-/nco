_           = require "underscore"
Marionette  = require "marionette"

# NcoAPI          = require "nco/nco"
# ChannelManager  = require "nco/ChannelManager"
# NcoConfigure    = require "nco/config"

NsenChannels = require "app/NsenChannels"

module.exports =
class ShellView extends Marionette.ItemView
    template: require "./view.jade"

    ui      :
        channel : ".NcoShell_nelchan_select"
        close   : ".NcoShell_ctrl .close"
        max     : ".NcoShell_ctrl .maximize"
        min     : ".NcoShell_ctrl .minimize"
        pin     : ".NcoShell_ctrl .pin"

    events  :
        "change @ui.channel": "_onChangeChannel"
        "click @ui.close"   : "_onClickClose"
        "click @ui.max"     : "_onClickMaximize"
        "click @ui.min"     : "_onClickMinimize"
        "click @ui.pin"     : "_onClickPin"


    initialize : ->
        app.onDidChangeChannel =>
            @_didChangeChannel()

        # @listenTo ChannelManager, "channelChanged", @_didChangeChannel
        # @listenTo NcoAPI, "changeAlwaysOnTop", @_onPinStateChanged

    onRender : ->
        # チャンネル一覧をセレクトボックスへ設定
        template = _.template "<option value='<%- id %>'><%- name %>"
        @ui.channel.html _.map(NsenChannels, (obj, index) -> template(obj)).join("")

        channelId = app.config.get "nco.lastSelectChannel"
        @ui.channel.find("option").each (i, el) =>
            console.log el.value, channelId
            if el.value is channelId
                @ui.channel[0].selectedIndex = i
                false


    _didChangeChannel : (name, id) ->
        self = @
        @ui.channel.find("option").each (i) ->
            if this.value is id
                self.ui.channel[0].selectedIndex = i
                return false

        id = id.replace(/^nsen\//, "")
        @$el
            .find ".NcoShell"
            .removeClass "ch-vocaloid ch-toho ch-nicoindies ch-sing ch-play ch-pv ch-hotaru ch-allgenre"
            .addClass "ch-#{id}"


    _onPinStateChanged  : (state) ->
        # @ui.pin.toggleClass "fixed", state


    _onClickClose       : ->
        app.command.dispatch "window:close"


    _onClickMaximize    : ->
        app.command.dispatch "window:maximize"


    _onClickMinimize    : ->
        app.command.dispatch "window:minimize"


    _onClickPin         : ->
        app.command.dispatch "window:toggle-always-on-top"
        console.log app.currentWindow.isAlwaysOnTop()
        @ui.pin.toggleClass "fixed", app.currentWindow.isAlwaysOnTop()


    _onChangeChannel    : ->
        app.command.dispatch "channel:change", @ui.channel.val()
