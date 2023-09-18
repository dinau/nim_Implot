import std/[math]
import imgui

type
  ImU32* = cuint


const IMPLOT_AUTO_COL* =  ImVec4(x: 0,y: 0,z: 0,w: -1)

# define CHECKBOX_FLAG(flags, flag) ImGui::CheckboxFlags(#flag, (unsigned int*)&flags, flag)
template CHECKBOX_FLAG*(flags, flag: untyped) =
  igCheckboxFlags($flag, cast[ptr int32](addr flags), flag.int32)

const RAND_MAX* = 0x7FFF.int
template RandomRange*[T](vmin, vmax: T): T =
  let scale: T = T(rand(RAND_MAX)) / T(RAND_MAX)
  vmin + scale * (vmax - vmin)

#// utility structure for realtime plot
#-----------------
# ScrollingBuffer TODO: Memory managemant
#-----------------
type
  ScrollingBuffer* = ref object
    MaxSize*: int32
    Offset*: int32
    Data*: seq[ImVec2]

proc newScrollingBuffer*(max_size: int32 = 2000): ScrollingBuffer =
  result.new
  result.MaxSize = max_size
  result.Offset =  0
  result.Data = newSeqOfCap[ImVec2](max_size)

proc AddPoint*(self: var ScrollingBuffer, x, y: float32) =
  if self.Data.len < self.MaxSize:
    self.Data.add ImVec2(x: x, y: y)
  else:
    self.Data[self.Offset] = ImVec2(x: x, y: y)
    self.Offset = (self.Offset + 1) mod self.MaxSize

proc Erase*(self:var ScrollingBuffer) =
  if self.Data.len > 0:
    self.Data = @[] #self.Data.shrink(0); TODO
    self.Offset = 0

#// utility structure for realtime plot
#-----------------
# RollingBuffer     TODO: Memory mangagement
#-----------------
type
  RollingBuffer* = ref object
    Span*: cfloat
    Data*: seq[ImVec2]

proc newRollingBuffer*(): RollingBuffer =
  result.new
  result.Span = 10.0f
  result.Data = newSeqOfCap[ImVec2](2000)

proc AddPoint*(self: var RollingBuffer, x, y:cfloat) =
  var xmod = x mod self.Span
  if  (self.Data.len > 0)  and (xmod < self.Data[self.Data.len - 1].x):
     self.Data = @[] #self.Data.shrink(0); TODO
  self.Data.add ImVec2(x: xmod, y: y)


