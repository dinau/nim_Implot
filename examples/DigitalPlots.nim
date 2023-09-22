import std/[strutils, math]
import imgui
import implot
import utils

#---------------------
# demo_DigitalPlots*()
#---------------------
proc demo_DigitalPlots*() =
  var
    paused{.global.} = false
    dataDigital{.global.} : array[2,ScrollingBuffer]
    dataAnalog {.global.} : array[2,ScrollingBuffer]
    showDigital{.global.} = [true, false]
    showAnalog{.global.} =  [true, false]
  once:
    dataDigital = [newScrollingBuffer(), newScrollingBuffer()]
    dataAnalog =  [newScrollingBuffer(), newScrollingBuffer()]

  igBulletText("Digital plots do not respond to Y drag and zoom, so that")
  igIndent()
  igText("you can drag analog plots over the rising/falling digital edge.")
  igUnindent()

  var label: string # char[32]
  igCheckbox("digital_0", addr showDigital[0])
  igSameLine()
  igCheckbox("digital_1", addr showDigital[1])
  igSameLine()
  igCheckbox("analog_0", addr showAnalog[0])
  igSameLine()
  igCheckbox("analog_1", addr showAnalog[1])

  var t{.global.} = 0.float32
  if not paused:
    t += igGetIO().deltaTime
    #//digital signal values
    if showDigital[0]:
      dataDigital[0].AddPoint(t, (sin(2*t) > 0.45).int.tofloat)
    if showDigital[1]:
      dataDigital[1].AddPoint(t, (sin(2*t) < 0.45).int.tofloat)
    # //Analog signal values
    if showAnalog[0]:
      dataAnalog[0].AddPoint(t, sin(2*t))
    if showAnalog[1]:
      dataAnalog[1].AddPoint(t, cos(2*t))

  if ipBeginPlot("##Digital"):
    defer: ipEndPlot()
    ipSetupAxisLimits(ImAxis.X1, (t - 10.0).cfloat64, t.cfloat64
      , (if paused: ImPlotCond.Once else: ImPlotCond.Always))
    ipSetupAxisLimits(ImAxis.Y1, -1.cfloat64, 1.cfloat64)
    for i in 0..<2:
      if showDigital[i] and (dataDigital[i].Data.len() > 0):
        label = "digital_$#" % [$i]
        ipPlotDigital(label.cstring
          , addr dataDigital[i].Data[0].x
          , addr dataDigital[i].Data[0].y
          , dataDigital[i].Data.len()
          , 0.ImPlotDigitalFlags
          , dataDigital[i].Offset
          , 2 * sizeof(float32))
    for i in 0..<2:
      if showAnalog[i]:
        label = "analog_$#" % [$i]
        if dataAnalog[i].Data.len() > 0:
          ipPlotLine(label.cstring
            , addr dataAnalog[i].Data[0].x
            , addr dataAnalog[i].Data[0].y
            , dataAnalog[i].Data.len()
            , 0.ImPlotLineFlags
            , dataAnalog[i].Offset
            , 2 * sizeof(float32))
