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
import types

proc init*(model: type UiModel): UiModel =
  UiModel(count: 0, list: @[])

proc add*(model: UiModel, table: UiModelTable) =
  model.list.add(table)
  if model.table_added != nil:
    model.table_added(model.count)
  model.count.inc

proc `[]`*(model: UiModel, index: int): UiModelTable =
  assert index <= model.count
  model.list[index]

proc `$`*(model: UiModel): string =
  $model.list

proc at*(model: UiModel, index, flag: int): string =
  assert index <= model.count
  model[index][flag]

proc clear*(model: UiModel) = 
  model.list.set_len(0)
  model.count = 0

macro declare_model_flags(name: string, args: varargs[string]) =
  var 
    i = 0
    model_enum = nnkEnumTy.newTree(newEmptyNode())
  for arg in args:
    model_enum.add(
      nnkEnumFieldDef.newTree(newIdentNode(name.str_val() & arg.str_val().capitalize_ascii()), newLit(i))
    )
    i.inc
  result = nnkTypeSection.newTree(
    nnkTypeDef.newTree(
      newIdentNode(name.str_val() & "Flags"),
      newEmptyNode(),
      model_enum
    )
  )

macro declare_model_add(name: string, args: varargs[string]) =
  var 
    add = ident("add" & name.str_val)
    add_params_defs = nnkIdentDefs.newTree()
    add_stmt = new_stmt_list()
    add_table = ident("table")
    model = ident("model")
  for arg in args:
    add_params_defs.add ident(arg.str_val)
  add_params_defs.add ident("string")
  add_params_defs.add new_empty_node()

  var add_params = 
    nnkFormalParams.newTree(
      newEmptyNode(),
      nnkIdentDefs.newTree(
        model,
        newIdentNode("UiModel"),
        newEmptyNode()
      ),
      add_params_defs
      )
  for arg in args:
    add_stmt.add nnkAsgn.newTree(
      nnkBracketExpr.newTree(
        add_table,
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
      var `add_table` = init_ordered_table[int, string]()
      `add_stmt`
      `model`.add(`add_table`)
  )


template declare_model*(name: string, args: varargs[string]) =
  declare_model_flags(name, args)
  declare_model_add(name, args)

when defined(testing) and is_main_module:
  import unittest

  declare_model("Customer", "name", "desc")
  
  proc main() =
    suite "UiModel":
      var model = UiModel.init()

      test "add":
        model.add_customer("Fred", "Cool guy")
        model.add_customer("Bob", "Lame guy")
        check: model.count == 2
      test "[]":
        check: model[0][ord CustomerDesc] == "Cool guy"
        check: model[1][ord CustomerName] == "Bob"
      test "clear":
        model.clear()
        check: model.count == 0
  main()
