{-# LANGUAGE DeriveDataTypeable #-}

module Main where

import Control.Monad
import qualified Data.Map as M
import Network.HostName
import System.IO
import XMonad
import qualified XMonad.Actions.GridSelect as GS
import qualified XMonad.Actions.Submap as SM
import XMonad.Hooks.DynamicLog
import qualified XMonad.Hooks.EwmhDesktops as E
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers (doFullFloat, isFullscreen)
import XMonad.Hooks.ScreenCorners
import qualified XMonad.Hooks.UrgencyHook as UH
import XMonad.Layout.NoBorders
import qualified XMonad.StackSet as SS
import XMonad.Util.EZConfig (additionalKeys)
import qualified XMonad.Util.NamedWindows as NW
import XMonad.Util.Run

-- c.f. https://pbrisbin.com/posts/using_notify_osd_for_xmonad_notifications/

data LibNotifyUrgencyHook = LibNotifyUrgencyHook deriving (Read, Show)

instance UH.UrgencyHook LibNotifyUrgencyHook where
  urgencyHook LibNotifyUrgencyHook w = do
    name <- NW.getName w
    Just idx <- fmap (SS.findTag w) $ gets windowset
    safeSpawn "notify-send" [show name, "workspace" ++ idx]

myModMask = mod4Mask

myTerminal = "alacritty"

lockScreen =
  safeSpawn "xdotool" ["mousemove", "0", "0"]
    >> spawn "sleep 0.5 && xset -display :0.0 dpms force off && slock"

myStartupHook = do
  addScreenCorner SCLowerRight lockScreen

myLayoutHook =
  smartBorders
    $ screenCornerLayoutHook
    $ avoidStruts
    $ layoutHook def

myManageHook =
  composeAll
    [ className =? "processing-app-Base" --> doFloat -- Arduino IDE
    ]

myEventHook e = do
  screenCornerEventHook e

gsConfig :: GS.GSConfig a -> GS.GSConfig a
gsConfig conf = conf {GS.gs_cellheight = 100, GS.gs_cellwidth = 800, GS.gs_font = "xft:M+ 1mn:size=10"}

-- http://ixti.net/software/2013/09/07/xmonad-action-gridselect-spawnselected-with-nice-titles.html
spawnSelected' :: [(String, String)] -> X ()
spawnSelected' lst = GS.gridselect (gsConfig GS.def) lst >>= flip whenJust spawn

apps =
  [ ("mlterm", myTerminal),
    ("firefox", "LANG=ja_JP.UTF-8 firefox"),
    ("firefox (private)", "LANG=ja_JP.UTF-8 firefox --private-window"),
    ("line", "LANG=ja_JP.UTF-8 chromium --app=chrome-extension://ophjlpahpchlmihnnnihgmmeilfjmjjc/index.html#popout"),
    ("chromium", "LANG=ja_JP.UTF-8 chromium"),
    ("chromium (incognito)", "LANG=ja_JP.UTF-8 chromium --incognito"),
    ("emacs", "emacs")
  ]

toggleMute = safeSpawn "amixer" ["-q", "sset", "Master", "toggle"]

lowerVolume = safeSpawn "amixer" ["-q", "sset", "Master", "5%-"]

raiseVolume = safeSpawn "amixer" ["-q", "sset", "Master", "5%+"]

myAdditionalKeys =
  [ ((myModMask .|. shiftMask, xK_z), lockScreen),
    ((controlMask, xK_Print), spawn "$HOME/config/bin/fscs"),
    ((0, 0x1008ff12), toggleMute), -- XF86AudioMute
    ((0, 0x1008ff11), lowerVolume), -- XF86AudioLowerVolume
    ((0, 0x1008ff13), raiseVolume), -- XF86AudioRaiseVolume
    ((0, xK_F4), safeSpawn "light" ["-S", "0.2"]),
    ((0, 0x1008ff03), safeSpawn "light" ["-U", "1"]), -- XF86MonBrightnessDown
    ((0, 0x1008ff02), safeSpawn "light" ["-A", "1"]), -- XF86MonBrightnessUp
    ((myModMask, xK_BackSpace), sendMessage NextLayout),
    ((myModMask .|. shiftMask, xK_BackSpace), spawn myTerminal),
    ((myModMask, xK_g), GS.goToSelected (gsConfig GS.def)),
    ((myModMask, xK_s), spawnSelected' apps),
    -- TODO: run from zsh (with PATH modifications)
    ((myModMask, xK_p), unsafeSpawn "PATH=$PATH:$HOME/config/bin rofi -modi run -show run -matching fuzzy"),
    ((myModMask .|. shiftMask, xK_p), unsafeSpawn "PATH=$PATH:$HOME/config/bin rofi -modi window -show window -matching fuzzy"),
    ((myModMask, xK_b), sendMessage ToggleStruts)
    -- subTabbed
    --  , ((mod4Mask .|. controlMask, xK_h), sendMessage $ pullGroup L)
    --  , ((mod4Mask .|. controlMask, xK_l), sendMessage $ pullGroup R)
    --  , ((mod4Mask .|. controlMask, xK_k), sendMessage $ pullGroup U)
    --  , ((mod4Mask .|. controlMask, xK_j), sendMessage $ pullGroup D)
    --  , ((mod4Mask .|. controlMask, xK_m), withFocused (sendMessage . MergeAll))
    --  , ((mod4Mask .|. controlMask, xK_u), withFocused (sendMessage . UnMerge))
    --  , ((modm .|. controlMask, xK_period), onGroup W.focusUp')
    --  , ((modm .|. controlMask, xK_comma), onGroup W.focusDown')
  ]

toggleStrutsKey XConfig {XMonad.modMask = modMask} = (modMask, xK_b)

getConfig hostname =
  E.ewmh
    . UH.withUrgencyHook LibNotifyUrgencyHook
    . docks
    $ def
      { clickJustFocuses = False,
        borderWidth = 1,
        terminal = myTerminal,
        modMask = myModMask,
        startupHook = myStartupHook,
        layoutHook = myLayoutHook,
        manageHook =
          (isFullscreen --> doFullFloat)
            <+> manageDocks
            <+> myManageHook
            <+> manageHook def,
        handleEventHook = myEventHook
      }
      `additionalKeys` myAdditionalKeys

main :: IO ()
main = do
  hostname <- getHostName
  let config = getConfig hostname
  xmonad config
