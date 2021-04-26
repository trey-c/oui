# Ocicat Ui Framework's manual

> WIP

## Table of contents
- [Fundamentals](#fundamentals)
- [Positioning UiNodes](#positioning-uinodes)
  * [Centering](#centering)
  * [Anchors](#anchors)
  * [Rows & Columns](#rows-&-columns)
  * [Traditional Header/Body/Footer](#traditional-headerbodyfooter-example)
- [UiNodes](#uinodes)
  * [Window](#window)
  * [Box](#box)
  * [Text](#text)
  * [Canvas](#canvas)
  * [Image](#image)
  * [Layout](#layout)
  * [OpenGl](#opengl)
- [Widgets](#widgets)
  * [Textbox](#textbox)
  * [Stack](#stack)
  * [List](#list)
- [Tables](#tables)
- [Creating widgets](#creating-widgets)
  * [Declaring](#declaring)
  * [Styling](#styling)

## Fundamentals

All **`UiNode's** use the following templates

- `w` | `h` |  `size`
- `top` | `left` | `bottom` | `right`
- `padding_top` | `padding_left` | `padding_bottom` | `padding_right`
- `color` | `visble`
- `fill` | `center` | `hcenter`
- `update` | `shown` | `hidden` | `draw_post` | `events`

**Events**

- `key_press`
- `key_release`
- `button_press`
- `button_release`
- `mouse_enter`
- `mouse_leave`
- `mouse_motion`
- `focus`
- `unfocus`

- Other events
  * `pressed`

Nodes are used like so

```nim
window:
  size 600, 400
  box:
    w 20
    h parent.h
```

**Notice how if you resize the parent; the `box`'s `h` doesn't reflect the new parent's `h`. Fix that with an `update:`**

```nim
box:
  color "#ff0000"
  id mycoolbox
  update:
    size 20, parent.h
  echo("Prints only once for " & self.name() & " on its declaration")
box:
  update:
    fill mycoolbox
```

As the `update:` name suggests, it gets called everytime there's an event. Trigger one manually with `self.trigger_update_attributes()`

## Positioning UiNodes 

###  Centering

<table>

<tr>
<td>

```nim 
box:
  color "#ff0000"
  update:
    size 200, 200
    center parent
```

</td>
<td> <img src="screenshots/center.png" width="300" height="300"></td>
</tr>

<tr>
<td>

```nim 
vcenter parent
```

</td>
<td> <img src="screenshots/vcenter.png" width="300" height="300"></td>
</tr>

<tr>
<td>

```nim 
hcenter parent
```

</td>
<td> <img src="screenshots/hcenter.png" width="300" height="300"></td>
</tr>

</table>

### Anchors

<table>

<tr>
<td>

```nim 
box:
  color "#ff0000"
  update:
    size 200, 200
    bottom parent.bottom
    right parent.right
```

</td>
<td> <img src="screenshots/bottomright.png" width="300" height="300"></td>
</tr>

<tr>
<td>

```nim 
h parent.h / 2
left parent.left
right parent.right
```

</td>
<td> <img src="screenshots/leftright.png" width="300" height="300"></td>
</tr>

</tr>

<tr>
<td>

```nim 
fill parent
```

</td>
<td> <img src="screenshots/fill.png" width="300" height="300"></td>
</tr>

<tr>
<td>

```nim 
box:
  id b1
  color "#ff0000"
  update:
    size 200, 200
    bottom parent.bottom
box:
  id b2
  color "#ff0000"
  update:
    size 100, 100
    bottom b1.top
    left b1.right
box:
  color "#ff0000"
  update:
    right parent.right
    top parent.top
    bottom b2.top
    left b2.right
```

</td>
<td> <img src="screenshots/corners.png" width="300" height="300"></td>
</tr>

</table>


### Rows & Columns

<table>

<tr>
<td>

```nim 
row:
  update:
    fill parent
  spacing 5
  for i in 0..6:
    box:
      update:
        w 100
        h 25
        center parent
      color "#ff0000"
```

</td>
<td> <img src="screenshots/row.png" width="300" height="300"></td>
</tr>

<tr>
<td>

```nim 
column:
```

</td>
<td> <img src="screenshots/column.png" width="300" height="300"></td>
</tr>

</table>


### Traditional Header/Body/Footer example

<table>

<tr>
<td>

```nim 
box:
  id header
  update:
    size parent.w, 100
  color "#ff0000"
box:
  id footer
  update:
    size parent.w, 100
    bottom parent.bottom
  color "#ff0000"
box:
  id bottom
  update:
    w parent.w
    top header.bottom
    bottom footer.top
  color "#ffffff"
  text:
    str "Body"
    update:
      fill parent
```

</td>
<td><img src="screenshots/headerbodyfooter.png" width="300" height="300"></td>
</tr>

</table>

## UiNodes

### Window

```nim
window:
  id win
  title "My Window"
  size 600, 400
```

**Notice** how the line `size 600, 400` isn't inside an `update:`

The window will not be visible until you call

```nim
win.show()
```

Below will manipulate the platform's window:

```nim
win.move(1, 1)
win.resize(100, 100)
win.hide()
```

### Box

*The most common UiNode*

```nim
box:
  color "#ff0000"
```

The box's default color is white, so it may be invisible until given a different color

And the box's `radius | opacity | border_width | border_color` can be changed using

```nim
radius 15
opacity 0.5
border_width 2
border_color "#000fff"
```

Side-specific borders can be added with `border_top` | `border_left` | `border_bottom` | `border_right`:

```nim
border_top 23:
  color rgb(123, 244, 123)
```

P.S if your curious, heres what `border_right` looks like in *oui/sugarsyntax.nim*

```nim
template border_right*(thickness: float32, inner: untyped) =
  box borderright:
    update:
      right parent.right
      size thickness, parent.h
      inner
```
### Text

```nim
text:
  str "Text drawn via nanovg"
```

You may change both the font family and size with

```nim
face "sans"
size 20
```

And also align the text with `align UiLeft | UiRight | UiTop | UiBottom | UiCenter`

```nim
valign UiBottom
halign UiRight
```

### Canvas

Heres some helpful code examples if your unfamilar with **nanovg**
https://github.com/johnnovak/nim-nanovg/blob/master/examples/demo.nim

Do not waste your time drawing outside the canvas's `w` or `h` because everything is clipped

```nim
canvas:
  update:
    fill parent
  paint:
    var vg = self.window.vg
    vg.beginPath()
    vg.rect(caretX, 0, 1.5, self.minh)
    vg.fillColor(rgb(0, 0, 250))
    vg.fill()
```

### OpenGl

*Outside 3D or 2D graphics*

```nim
opengl:
  update:
    fill parent
  render:
    glClearColor(1.0, 1.0, 1.0, 1.0)
    glClear(GL_COLOR_BUFFER_BIT)
```

### Layout


```nim
layout:
  arrange_layout:
    for child in node.children:
      child.y = 100
```

### Image

```nim
image:
  src "/home/trey/Pictures/naughtysecret.png"
  w 100
  h 100
```

## Widgets

### Textbox

*Useful for grabbing user input*

```nim
var emailtext = ""
textbox:
  update:
    size parent.w / 2, parent.h
  events:
    key_press:
      echo emailtext
do: emailtext
```

**Need to hide sensitive information such has passwords?**

```nim
do: myemailtext
do: true
```

**You wanna add an image/icon to your textbox? Move its text!**

```nim
textbox:
  image:
    id whatever
    src ...
    size 20, 20
  update:
    var txt = self.childrenp[0]
    txt.set_left(whatever.right)
    txt.padding_left = 10
  ...
```

### Stack

*Useful for creating pages*

```nim
stack:
  id mypage
  update:
    size parent.w / 2, parent.h
  box:
    color "#ff0000"
    visible true # node shown by default
  box:
    color "#00ff00"
    visible false # node hidden by default
  box:
    id box3
    color "#0000ff"
    visible false # node hidden by default
```

You switch the displayed node by calling `stack_switch`

```nim
import oui/animation

...
my_page.stack_switch(box3):
  asyncCheck my_page.slide_node(box3, UiRight)
```

Or skip out on animating the transition with the handy `discard` statement

```nim
...(box3):
  discard
```

### List

Check [Tables](#tables) first

```nim
var table = UiTable.init()
...
list:
  model table
  delegate:
    box:
      update:
        w parent.w
        h 50
      text:
       str table[self.index][ord CustomerName]
       update:
         fill parent
```

> TODO MORE

## Tables

> Usefull for displaying data

Tables are typically used and displayed with [List's](#list), and can be declared using `decl_table`

```nim
import oui/table
...
decl_table Customer, "name", "age"
``` 

Above declares both an enum, and an *add* proc. Used like so

```nim
var table = UiTable.init()
table.add_customer("Fred", "29")
table.add_customer("Bob", "4")
```

Grab data using

```nim
... self.index is 0
echo(table[self.index][ord CustomerName] & " is " & table[self.index][ord CustomerAge] & " years old"
# Prints 'Fred is 29 years old"
```

## Creating widgets

> P.S widgets are just complicated UiNodes

Heres an example of a simple **button** implementation

```nim 
decl_style button: 
  normal: rgb(241, 241, 241)
  hover: rgb(200, 200, 200)
  active: rgb(100, 100, 100)
  border: rgb(210, 210, 210)

template button*(inner: untyped, style: ButtonStyle = button_style) =
  box:
    color style.normal
    radius 10
    border_width 2
    border_color style.border
    mouse_enter:
      color style.hover
      self.queue_redraw()
    mouse_leave:
      color style.normal
      self.queue_redraw()
    button_press:
      color style.active
      self.queue_redraw()
    button_release:
      color style.hover
      self.queue_redraw()
    inner
```

**More examples can be found in the module** `oui/ui.nim`

Further sections will hopefully explain to you whats going on above; this is just a quick example

### Styling

Widgets typically have an optional `style` parameter placed in its declaration, which should always be the **last** parameter

```nim 
decl_style button: 
  normal: rgb(241, 241, 241)
  hover: rgb(200, 200, 200)
  active: rgb(100, 100, 100)
  border: rgb(210, 210, 210)
  
template ..., style: ButtonStyle = button_style)
```

The `decl_style` macro declared a named tuple called **ButtonStyle**, and a global variable with the name being **button_style** used with every button by default. Values are obviously changeable
```nim
button_style.hover = rgb(100, 0, 0)
```

Or you may swap out the default style entirely on a per-widget basis

```nim
var better_button_style: ButtonStyle
better_button_style.normal = rgb(0, 100, 0)
# ...
button:
  id btn
  update:
    size 100, 50
button:
  update:
    size 100, 50
    left btn.right
do: better_button_style
```
