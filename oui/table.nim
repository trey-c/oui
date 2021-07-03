# Copyright © 2020 Trey Cutter <treycutter@protonmail.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
#
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import tables, macros, strutils
export tables
import types
import testmyway
import utils

proc init*(table: type UiTable): UiTable =
  UiTable(count: 0, list: @[])

proc add*(table: UiTable, row: UiTableRow) =
  table.list.add(row)
  if table.table_added != nil:
    table.table_added(table.count)
  table.count.inc

proc `[]`*(table: UiTable, index: int): UiTableRow =
  assert index <= table.count
  table.list[index]

proc `$`*(table: UiTable): string =
  $table.list

proc at*(table: UiTable, index, flag: int): string =
  if index <= table.count and index != -1:
    table[index][flag]
  else:
    if index != -1:
      oui_warning "UiTable at index " & $index & " is out of range"
    $index & " unkown"

proc clear*(table: UiTable) =
  table.list.set_len(0)
  table.count = 0

iterator loop*(table: UiTable): int =
  var i = 0
  for t in table.list:
    yield i
    i.inc

macro declare_table_flags(name: untyped, args: varargs[string]) =
  var
    i = 0
    table_enum = nnkEnumTy.newTree(newEmptyNode())
  for arg in args:
    table_enum.add(
      nnkEnumFieldDef.newTree(newIdentNode(name.str_val() & arg.str_val(
      ).capitalize_ascii()), newLit(i))
    )
    i.inc
  result = nnkTypeSection.newTree(
    nnkTypeDef.newTree(
      newIdentNode(name.str_val() & "Flags"),
      newEmptyNode(),
      table_enum
    )
  )

macro declare_table_add(name: untyped, args: varargs[string]) =
  var
    add = ident("add" & name.str_val)
    add_params_defs = nnkIdentDefs.newTree()
    add_stmt = new_stmt_list()
    row = ident("row")
    table = ident("table")
  for arg in args:
    add_params_defs.add ident(arg.str_val)
  add_params_defs.add ident("string")
  add_params_defs.add new_empty_node()

  var add_params =
    nnkFormalParams.newTree(
      newEmptyNode(),
      nnkIdentDefs.newTree(
        table,
        newIdentNode("UiTable"),
        newEmptyNode()
      ),
      add_params_defs
      )
  for arg in args:
    add_stmt.add nnkAsgn.newTree(
      nnkBracketExpr.newTree(
        row,
        nnkDotExpr.newTree(
          newIdentNode(name.str_val() & arg.str_val()),
          newIdentNode("ord")
      )
    ),
      newIdentNode(arg.str_val())
    )
  result = nnkProcDef.newTree(
    nnkPostfix.newTree(
      newIdentNode("*"),
      newIdentNode("add_" & name.str_val().to_lower_ascii())
    ),
    newEmptyNode(),
    newEmptyNode(),
    add_params,
    new_empty_node(),
    new_empty_node(),
    quote do:
      var `row` = init_ordered_table[int, string]()
      `add_stmt`
      `table`.add(`row`)
  )


template decl_table*(name: untyped, args: varargs[string]) =
  declare_table_flags(name, args)
  declare_table_add(name, args)

when defined(testmyway):
  decl_table Customer, "name", "desc"

test_my_way "UiTable":
  var customers = UiTable.init()

  test "add":
    customers.add_customer("Fred", "Cool guy")
    customers.add_customer("Bob", "Lame guy")
    check: customers.count == 2
  test "[]":
    check: customers[0][ord CustomerDesc] == "Cool guy"
    check: customers[1][ord CustomerName] == "Bob"
  test "clear":
    customers.clear()
    check: customers.count == 0
