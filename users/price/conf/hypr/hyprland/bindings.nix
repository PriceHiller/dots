{ ... }:
{
  wayland.windowManager.hyprland.extraConfig = # hyprlang
    ''
      # --- MOUSE ---
      bindm = SUPER,mouse:272,movewindow
      bindm = SUPER,mouse:273,resizewindow

      # --- RESIZE ---
      bind = SUPER,R,submap,resize # will switch to a submap called resize

      submap = resize # will start a submap called "resize"

      binde = ,right,resizeactive,50 0
      binde = ,left,resizeactive,-50 0
      binde = ,up,resizeactive,0 -50
      binde = ,down,resizeactive,0 50

      binde = ,l,resizeactive,50 0
      binde = ,h,resizeactive,-50 0
      binde = ,k,resizeactive,0 -50
      binde = ,j,resizeactive,0 50

      bind = ,escape,submap,reset # use reset to go back to the global submap
      submap = reset # will reset the submap, meaning end the current one and return to the global one.

      # --- Move Window ---
      bind = SUPER,M,submap,move_window

      submap = move_window

      bind = ,right,movewindow,r
      bind = ,left,movewindow,l
      bind = ,up,movewindow,u
      bind = ,down,movewindow,d

      bind = ,l,movewindow,r
      bind = ,h,movewindow,l
      bind = ,k,movewindow,u
      bind = ,j,movewindow,d

      bind = ,escape,submap,reset
      submap = reset

      bind = ALT,v,exec,cd "''${XDG_CONFIG_HOME}/wofi" && cliphist list | wofi --dmenu --width=1000px --style "cliphist.css" --height=90% -D halign=left | cliphist decode | wl-copy
      bind = SUPERALT,v,exec,cd "''${XDG_CONFIG_HOME}/wofi" && cliphist list | wofi --dmenu --width=1000px --style "cliphist.css" --height=90% -D halign=left | cliphist delete
      bind = SUPER,RETURN,exec,neovide --fork -- +term
      bind = SUPERSHIFT,RETURN,exec,neovide --fork
      bind = SUPERCTRL,RETURN,exec,xdg-open "http://"
      bind = SUPER,SPACE,exec,wofi --show drun
      bind = SUPER,F,fullscreen
      bind = SUPER,Q,killactive,
      bind = SUPER,A,togglefloating,
      bind = SUPER,D,exec,makoctl dismiss -a
      bind = SUPERSHIFT,Q,exec,hyprlock
      bind = SUPERSHIFT,M,exit

      # --- Screen Captures ---
      # May be videos or screenshots
      bind = SUPER,S,exec,grim -g "$(slurp)" - | swappy -f - -o - | wl-copy
      bind = CTRLSUPER,S,exec,grim -g "$(slurp)" - | wl-copy --type image/png
      bind = SUPERSHIFT,S,exec,screen-cap
      bind = SUPERSHIFT,A,exec,screen-cap gif

      # Mediakey bindings as taken from `wev`
      bindl = ,XF86AudioPrev,exec,playerctl previous
      bindl = ,XF86AudioNext,exec,playerctl next
      bindl = ,XF86AudioPlay,exec,playerctl play-pause
      bindel= ,XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
      bindel= ,XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
      bindl= ,XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
      binde = ,XF86MonBrightnessUp,exec,brightnessctl s 5%+
      binde = ,XF86MonBrightnessDown,exec,brightnessctl s 5%-

      bind = SUPER,left,movefocus,l
      bind = SUPER,right,movefocus,r
      bind = SUPER,up,movefocus,u
      bind = SUPER,down,movefocus,d

      bind = SUPER,h,movefocus,l
      bind = SUPER,l,movefocus,r
      bind = SUPER,k,movefocus,u
      bind = SUPER,j,movefocus,d

      # --- Workspaces ---

      bind = SUPERCTRL,left,exec,${./scripts/focus-workspace-mon.bash} $(( $(hyprctl monitors -j | jq -c '.[] | select(.focused) | .activeWorkspace.id') - 1 ))
      bind = SUPERCTRL,right,exec,${./scripts/focus-workspace-mon.bash} $(( $(hyprctl monitors -j | jq -c '.[] | select(.focused) | .activeWorkspace.id') + 1 ))
      bind = SUPERCTRL,h,exec,${./scripts/focus-workspace-mon.bash} $(( $(hyprctl monitors -j | jq -c '.[] | select(.focused) | .activeWorkspace.id') - 1 ))
      bind = SUPERCTRL,l,exec,${./scripts/focus-workspace-mon.bash} $(( $(hyprctl monitors -j | jq -c '.[] | select(.focused) | .activeWorkspace.id') + 1 ))

      bind = SUPERALT,left,exec,${./scripts/move-workspace-mon.bash} $(( $(hyprctl monitors -j | jq -c '.[] | select(.focused) | .activeWorkspace.id') - 1 )) 1
      bind = SUPERALT,right,exec,${./scripts/move-workspace-mon.bash} $(( $(hyprctl monitors -j | jq -c '.[] | select(.focused) | .activeWorkspace.id') + 1 )) 1
      bind = SUPERALT,h,exec,${./scripts/move-workspace-mon.bash} $(( $(hyprctl monitors -j | jq -c '.[] | select(.focused) | .activeWorkspace.id') - 1 )) 1
      bind = SUPERALT,l,exec,${./scripts/move-workspace-mon.bash} $(( $(hyprctl monitors -j | jq -c '.[] | select(.focused) | .activeWorkspace.id') + 1 )) 1

      bind = SUPERCTRLALT,left,exec,${./scripts/move-workspace-mon.bash} $(( $(hyprctl monitors -j | jq -c '.[] | select(.focused) | .activeWorkspace.id') - 1 ))
      bind = SUPERCTRLALT,right,exec,${./scripts/move-workspace-mon.bash} $(( $(hyprctl monitors -j | jq -c '.[] | select(.focused) | .activeWorkspace.id') + 1 ))
      bind = SUPERCTRLALT,h,exec,${./scripts/move-workspace-mon.bash} $(( $(hyprctl monitors -j | jq -c '.[] | select(.focused) | .activeWorkspace.id') - 1 ))
      bind = SUPERCTRLALT,l,exec,${./scripts/move-workspace-mon.bash} $(( $(hyprctl monitors -j | jq -c '.[] | select(.focused) | .activeWorkspace.id') + 1 ))

      bind = SUPER,1,exec,${./scripts/focus-workspace-mon.bash} 1
      bind = SUPER,2,exec,${./scripts/focus-workspace-mon.bash} 2
      bind = SUPER,3,exec,${./scripts/focus-workspace-mon.bash} 3
      bind = SUPER,4,exec,${./scripts/focus-workspace-mon.bash} 4
      bind = SUPER,5,exec,${./scripts/focus-workspace-mon.bash} 5
      bind = SUPER,6,exec,${./scripts/focus-workspace-mon.bash} 6
      bind = SUPER,7,exec,${./scripts/focus-workspace-mon.bash} 7
      bind = SUPER,8,exec,${./scripts/focus-workspace-mon.bash} 8
      bind = SUPER,9,exec,${./scripts/focus-workspace-mon.bash} 9

      bind = SUPERCTRL,1,exec,${./scripts/move-workspace-mon.bash} 1
      bind = SUPERCTRL,2,exec,${./scripts/move-workspace-mon.bash} 2
      bind = SUPERCTRL,3,exec,${./scripts/move-workspace-mon.bash} 3
      bind = SUPERCTRL,4,exec,${./scripts/move-workspace-mon.bash} 4
      bind = SUPERCTRL,5,exec,${./scripts/move-workspace-mon.bash} 5
      bind = SUPERCTRL,6,exec,${./scripts/move-workspace-mon.bash} 6
      bind = SUPERCTRL,7,exec,${./scripts/move-workspace-mon.bash} 7
      bind = SUPERCTRL,8,exec,${./scripts/move-workspace-mon.bash} 8
      bind = SUPERCTRL,9,exec,${./scripts/move-workspace-mon.bash} 9
    '';
}
