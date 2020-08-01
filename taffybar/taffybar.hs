{-# LANGUAGE OverloadedStrings #-}

import System.Taffybar
import System.Taffybar.Context (TaffyIO, TaffybarConfig (..))
import System.Taffybar.Hooks
import System.Taffybar.SimpleConfig
import System.Taffybar.Widget
import qualified System.Taffybar.Widget.Battery as B
import qualified System.Taffybar.Widget.SimpleClock as SC
import qualified System.Taffybar.Widget.Text.CPUMonitor as C
import qualified System.Taffybar.Widget.Text.MemoryMonitor as M
import qualified System.Taffybar.Widget.Text.NetworkMonitor as N
import qualified System.Taffybar.Widget.Util as U
import qualified System.Taffybar.Widget.Windows as WI
import qualified System.Taffybar.Widget.Workspaces as W

workspaceConfig =
  W.defaultWorkspacesConfig
    { W.minIcons = 1,
      W.widgetGap = 0,
      W.showWorkspaceFn = W.hideEmpty,
      -- https://github.com/taffybar/taffybar/issues/403 workaround
      W.getWindowIconPixbuf = W.scaledWindowIconPixbufGetter W.getWindowIconPixbufFromEWMH
    }

clockConfig =
  SC.defaultClockConfig
    { SC.clockFormatString = "0%Y-%m-%d %H:%M"
    }

windowsConfig =
  WI.WindowsConfig
    { WI.getMenuLabel = WI.truncatedGetMenuLabel 70,
      WI.getActiveLabel = WI.truncatedGetActiveLabel 70
    }

exampleTaffybarConfig :: TaffybarConfig
exampleTaffybarConfig =
  let workspaces = workspacesNew workspaceConfig
      bat = B.textBatteryNew "$percentage$ ($time$)"
      cpu = U.setMinWidth 80 =<< C.textCpuMonitorNew "cpu: $total$" 1.0
      mem = U.setMinWidth 100 =<< M.textMemoryMonitorNew "mem: $used$ / $total$" 1.0
      net = U.setMinWidth 160 =<< N.networkMonitorNew N.defaultNetFormat Nothing
      clock = SC.textClockNewWith clockConfig
      layout = layoutNew defaultLayoutConfig
      windowsW = WI.windowsNew windowsConfig
      tray = sniTrayNew
      myConfig =
        defaultSimpleTaffyConfig
          { startWidgets =
              workspaces : map (>>= buildContentsBox) [layout, windowsW],
            endWidgets =
              map
                (>>= buildContentsBox)
                [ clock,
                  B.batteryIconNew,
                  bat,
                  tray,
                  cpu,
                  mem,
                  net
                ],
            barPosition = Top,
            barHeight = 35,
            widgetSpacing = 0
          }
   in withBatteryRefresh
        $ withLogServer
        $ withToggleServer
        $ toTaffyConfig myConfig

main = startTaffybar exampleTaffybarConfig
