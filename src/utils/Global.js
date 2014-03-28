/*jslint node: true, vars: true, plusplus: true, devel: true, nomen: true, indent: 4, maxerr: 50 */
define(function (require, exports, module) {
    "use strict";
    
    var Fn = Function,
        global = (new Fn("return this"))(),
        
        nodeWebkit = global.require("nw.gui");
    
    if (!global.nco) {
        global.nco = {};
    }
    
    // Backboneくんが駄々をこねるので
    // lodashをunderscore.jsの代替(window._)として割り当て
    global.underscore = global._ = require("thirdparty/lodash");
    
    // node-webkit上のnode由来のAPIをnco.nodeApiに公開
    if (global.root) {
        global.nco.nodeApi = global.root;
    }
    
    // デバッグモードで起動されたか判定し
    // nco.debugMode プロパティで結果を取得できるようにします。
    var debugMode = nodeWebkit.App.argv.indexOf("--debug") !== -1;
    Object.defineProperty(global.nco, "debugMode", {
        get: function () { return debugMode; },
        set: function () {}
    });
    
    /**
     * Node.jsモジュールを要求します。
     * @param {string} モジュール名
     */
    global.nco.require = global.require;
    
    /**
     * Ncoのコアモジュールを取得します。
     * @param {string} module モジュール名
     */
    global.nco.getModule = require;
    
    module.exports = global;
});