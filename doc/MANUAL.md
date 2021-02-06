## Ocicat Ui Framework's manual

> WIP

### Positioning UiNodes 

####  Centering

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

#### Anchors

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


#### Rows & Columns

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


#### Traditional Header/Body/Footer example

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
