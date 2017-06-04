// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

// import socket from "./socket"


import {Socket} from "phoenix"

let socket = new Socket("/socket", {params: {token: window.userToken}})

socket.connect()

// Now that you are connected, you can join channels with a topic:
let channel = socket.channel("player_state_update", {})
channel.join()
    .receive("ok", resp => { console.log("Joined successfully", resp) })
    .receive("error", resp => { console.log("Unable to join", resp) })

channel.on("player_state_update", player_game_state => {
    updateGameState(player_game_state)
});

function updateGameState(player_game_state) {
    console.log(player_game_state);
    $(".js--player-money").html(~~player_game_state.money);
    $(".js--player-miners").html(player_game_state.miners);
    $.each(player_game_state.resources, function(key, value){
        var container = $('[data-player-resource="' + key + '"]');
        $(".js--player-resource", container).html(~~value);
        $(".js--player-sell-resource", container).prop("disabled", ~~value == 0);
    });
}

$(function(){
    $(".js--player-buy-miner").click(function(){
        channel.push("player_buy_miner", {});
    });

    $(".js--player-sell-resource").click(function(){
        var container = $(this).closest("[data-player-resource]");
        var resource_key = container.data('player-resource');
        console.log(resource_key);
        channel.push("player_sell_resource", {resource: resource_key});
    });
});
