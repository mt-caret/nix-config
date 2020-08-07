{-# LANGUAGE OverloadedStrings #-}

import Control.Monad ((<=<))
import Control.Monad.Trans (liftIO)
import Control.Monad.Trans.Maybe
import Data.Maybe (fromMaybe)
import Network.HostName (getHostName)
import qualified Data.Text as T
import qualified Sound.ALSA.Exception as AE
import qualified Sound.ALSA.Mixer as A
import System.Taffybar
import System.Taffybar.Context (TaffyIO, TaffybarConfig (..))
import System.Taffybar.Hooks
import System.Taffybar.SimpleConfig
import System.Taffybar.Widget
import qualified System.Taffybar.Widget.Battery as B
import qualified System.Taffybar.Widget.Generic.PollingLabel as PL
import qualified System.Taffybar.Widget.SimpleClock as SC
import qualified System.Taffybar.Widget.Text.CPUMonitor as C
import qualified System.Taffybar.Widget.Text.MemoryMonitor as M
import qualified System.Taffybar.Widget.Util as U
import qualified System.Taffybar.Widget.Windows as WI
import Text.Printf (printf)
import qualified System.Taffybar.Widget.Workspaces as W

liftMaybe :: Monad m => Maybe a -> MaybeT m a
liftMaybe = MaybeT . return

percent :: Integer -> Integer -> Integer -> Integer
percent v' lo' hi' = round $ (v - lo) / (hi - lo) * 100.0
  where
    v = fromIntegral v' :: Double
    lo = fromIntegral lo'
    hi = fromIntegral hi'

getVolumeInfo :: IO (Maybe (Integer, Bool))
getVolumeInfo =
  A.withMixer "default" $ \mixer -> runMaybeT $ do
    control <- MaybeT $ A.getControlByName mixer "Master"
    playbackVolume <- liftMaybe . A.playback $ A.volume control
    volume <- fmap toInteger . getChannel' $ A.value playbackVolume
    (minVolume, maxVolume) <- liftIO $ A.getRange playbackVolume
    --dB <- fmap toInteger . getChannel' $ A.dB playbackVolume
    switch <- getChannel' <=< liftMaybe . A.playback $ A.switch control
    return (percent volume (toInteger minVolume) (toInteger maxVolume), switch)
  where
    getChannel' = MaybeT . A.getChannel A.FrontLeft

formatVolume :: (Integer, Bool) -> T.Text
formatVolume (volume, switch) =
  T.pack $ printf "vol: %d%%%s" volume switchStr
  where
    switchStr :: String
    switchStr =
      -- https://developer.gnome.org/pygtk/stable/pango-markup-language.html
      if switch
        then "[<span foreground=\"green\">on</span>]"
        else "[<span foreground=\"red\">off</span>]"

textVolumeMonitorNew period =
  PL.pollingLabelNew period callback
  where
    callback = fromMaybe "" . fmap formatVolume <$> getVolumeInfo

bar = PL.pollingLabelNew 1.0 (return "|")

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

exampleTaffybarConfig :: String -> TaffybarConfig
exampleTaffybarConfig hostname =
  let workspaces = workspacesNew workspaceConfig
      bat = B.textBatteryNew "bat: $percentage$%($time$)"
      cpu = U.setMinWidth 70 =<< C.textCpuMonitorNew "cpu: $total$" 3.0
      mem = U.setMinWidth 100 =<< M.textMemoryMonitorNew "mem: $used$ / $total$" 3.0
      vol = U.setMinWidth 100 =<< textVolumeMonitorNew 0.1
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
                  tray,
                  bar,
                  B.batteryIconNew,
                  bat,
                  bar,
                  vol,
                  bar,
                  cpu,
                  bar,
                  mem
                ],
            barPosition = Top,
            barHeight = getBarHeight hostname,
            widgetSpacing = 0
          }
   in withBatteryRefresh
        $ withLogServer
        $ withToggleServer
        $ toTaffyConfig myConfig

getBarHeight :: String -> Int
getBarHeight "artemis" = 50
getBarHeight _ = 35

main = do
  hostname <- getHostName
  startTaffybar $ exampleTaffybarConfig hostname
