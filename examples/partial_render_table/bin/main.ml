open! Core
open! Bonsai_web
open Bonsai.Let_syntax
module PRT_example = Bonsai_partial_render_table_example

let component ~theme_picker =
  let%sub ( form_view
          , { themed; show_position; row_height; num_rows; cell_based_highlighting } )
    =
    PRT_example.Layout_form.component
  in
  let%sub data =
    let%arr num_rows = num_rows in
    PRT_example.Row.many_random num_rows
  in
  let%sub { table
          ; focus_attr
          ; set_column_width
          ; lock_focus
          ; unlock_focus
          ; focus_is_locked
          }
    =
    match%sub cell_based_highlighting with
    | false ->
      let base =
        PRT_example.component
          ~focus_kind:`Row
          ~should_show_position:show_position
          ~row_height
          data
      in
      (match%sub themed with
       | false -> base ~theming:`Legacy_don't_use_theme
       | true -> base ~theming:`Themed)
    | true ->
      let base =
        PRT_example.component
          ~focus_kind:`Cell
          ~should_show_position:show_position
          ~row_height
          data
      in
      (match%sub themed with
       | false -> base ~theming:`Legacy_don't_use_theme
       | true -> base ~theming:`Themed)
  in
  let%sub toggle_focus_lock_button =
    let%sub on_click =
      let%arr focus_is_locked = focus_is_locked
      and lock_focus = lock_focus
      and unlock_focus = unlock_focus in
      if focus_is_locked then unlock_focus else lock_focus
    in
    let%sub theme = View.Theme.current in
    let%arr on_click = on_click
    and focus_is_locked = focus_is_locked
    and theme = theme in
    let text = if focus_is_locked then "Unlock focus" else "Lock focus" in
    View.button theme ~on_click text
  in
  let%sub form_view =
    let%sub width_form = PRT_example.Column_width_form.component ~set_column_width in
    let%arr form_view = form_view
    and width_form = width_form in
    View.vbox [ form_view; width_form ]
  in
  let%arr form_view = form_view
  and table = table
  and focus_attr = focus_attr
  and theme_picker = theme_picker
  and toggle_focus_lock_button = toggle_focus_lock_button in
  Vdom.Node.div
    ~attrs:[ focus_attr ]
    [ theme_picker; form_view; toggle_focus_lock_button; table ]
;;

let component_with_theme =
  let%sub theme, theme_picker = Bonsai_web_ui_gallery.Theme_picker.component () in
  View.Theme.set_for_app theme (component ~theme_picker)
;;

let () = Bonsai_web.Start.start component_with_theme
