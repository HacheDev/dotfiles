local M = {}

local vol = [[ str=$( pulsemixer --get-volume ); printf "$(pulsemixer --get-mute) ${str% *}\n" ]]
local net = [[ printf "$(nmcli -t connection show --active)~|~$(nmcli radio wifi)" ]]
local song = [[ printf "$(playerctl metadata xesam:title)" ]]
local artist = [[ printf "$(playerctl metadata xesam:artist)" ]]
local stat = [[ printf "$(playerctl status)" ]]
local blue = [[ bluetoothctl show | grep "Powered:" ]]
local fs = [[ df -h --output=used,size / | sed 's/G//g' ]]
local temp = [[ cat /sys/class/thermal/thermal_zone0/temp ]]
local mem = [[   
  while IFS=':k ' read -r mem1 mem2 _; do
    case "$mem1" in
      MemTotal)
        memt="$(( mem2 / 1024 ))";;
      MemAvailable)
        memu="$(( memt - mem2 / 1024))";;
    esac;
  done < /proc/meminfo;
  printf "%d %d" "$memu" "$memt"; ]]

M.play = function()
  awful.spawn.easy_async_with_shell(stat, function(status)
    awful.spawn.easy_async_with_shell(song, function(title)
      awful.spawn.easy_async_with_shell(artist, function(who)
        awesome.emit_signal('play::value', status, title, who)
      end)
    end)
  end)
end

M.mem = function ()
  awful.spawn.easy_async_with_shell(mem, function (out)
    local val = gears.string.split(out, " ")
    awesome.emit_signal('mem::value', tonumber(val[1]), tonumber(val[2]))
  end)
end

M.fs = function ()
  awful.spawn.easy_async_with_shell(fs, function (out)
    local val = gears.string.split(out, " ")
    awesome.emit_signal('fs::value', tonumber(val[6]), tonumber(val[8]))
  end)
end

M.temp = function ()
  awful.spawn.easy_async_with_shell(temp, function (out)
    awesome.emit_signal('temp::value', tonumber(out))
  end)
end

M.vol = function()
  awful.spawn.easy_async_with_shell(vol, function(out)
    local val = gears.string.split(out, " ")
    awesome.emit_signal('vol::value', tonumber(val[1]), tonumber(val[2]))
  end)
end

M.net = function()
  awful.spawn.easy_async_with_shell(net, function(out)
    local val = gears.string.split(out, "~|~")
    local v= "down"
    if val[1] ~= "" then
      v = "up"
    end
    local w = "down"
    if val[2]:match("enabled") then
      w = "up"
    end
    awesome.emit_signal('net::value', v, w)
  end)
end


M.blu = function()
  awful.spawn.easy_async_with_shell(blue, function(out)
    if out == "" then
      awesome.emit_signal('blu::value', "no")
    else
      local val = gears.string.split(out, " ")
      awesome.emit_signal('blu::value', val[2])
    end
  end)
end

gears.timer {
  timeout = 5,
  call_now = true,
  autostart = true,
  callback = function()
    M.vol()
    M.net()
    M.blu()
    M.mem()
    -- M.fs()
    M.temp()
    M.play()
  end
}

M.set_vol = function(val)
  awful.spawn.with_shell('killall pulsemixer; pulsemixer --set-volume ' .. tonumber(val))
end

M.toggle_mute = function()
  awful.spawn.with_shell('pulsemixer --toggle-mute ')
  M.vol()
end

return M
