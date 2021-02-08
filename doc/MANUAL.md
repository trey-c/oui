# Ocicat Ui Framework's manual

> WIP

## Table of content

- [Creating widgets](#creating-widgets)
  * [Styling](#styling)
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

## Creating widgets

> P.S widgets are just UiNodes

Heres an example of a simple **button** implementation

```nim 
decl_style button: 
  normal: "#212121"
  hover: "#313113"
  active: "#555555"
template button*(id, inner: untyped, style: ButtonStyle = button_style) = 
  box id:
    color style.normal
    events:
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
template button*(inner: untyped) =
  node_without_id button, inner
```

**More examples can be found in the module oui/ui**

Further sections can also explain whats going on above. This is just to show you
a quick example

### Styling

Widgets typicaly have an optional `style` paramater placed in its declaration, and shall always be the **last** parameter

```nim 
decl_style button: 
  normal: "#212121"
..., style: ButtonStyle = button_style) = 
```

The `decl_style` macro declared a named tuple called **ButtonStyle**, and a global variable with the name being **button_style** used for every button that can be modified

```nim
button_style.hover = "#ff0000"
```

Or you may swap out the default style entirely on a per widget basis

```nim
var better_button_style: ButtonStyle
better_button_style.normal = "#00ff00"
# ...
button btn1:
  update:
    size 100, 50
button btn2, better_button_style:
  update:
    size 100, 50
    left btn1.right
```

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
box b1:
  color "#ff0000"
  update:
    size 200, 200
    bottom parent.bottom
box b2:
  color "#ff0000"
  update:
    size 100, 100
    bottom b1.top
    left b1.right
box b3:
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
box header:
  update:
    size parent.w, 100
  color "#ff0000"
box footer:
  update:
    size parent.w, 100
    bottom parent.bottom
  color "#ff0000"
box body:
  update:
    w parent.w
    top header.bottom
    bottom footer.top
  color "#ffffff"
  text:
    text "Body"
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
window win:
  title "My Window"
  size 600, 400
```

**Notice** how the line `size 600, 400` isn't inside an `update:`

The window will not be visible until you call
```nim
win.show()
```

### Box

*The most common UiNode*

```nim
box:
  color "#ff0000"
```

The box's default color is white, so it may be invisible until you give it a different color

### Text

```nim
text:
  text "Text drawn pango"
```

You may change both the font family and size by calling `family`

```nim
family "Sans Bold 27"
```

And also align the text with `align UiLeft | UiRight | UiTop | UiBottom | UiCenter`

```nim
valign UiBottom
halign UiRight
```

### Canvas

*The framework using cairo for all drawing* 

Heres a helpful tutorial if your unfamilar with **cairo**: https://www.cairographics.org/tutorial/

```nim
import cairo

canvas:
  update:
    fill parent
  paint:
    var ctx = self.surface.create()
    ...
```

### Layout

> TODO

### Image

> TODO